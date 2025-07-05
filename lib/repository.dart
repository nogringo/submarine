import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ndk/config/bootstrap_relays.dart';
import 'package:ndk/ndk.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:submarine/get_database.dart';
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/no_event_verifier.dart';
import 'package:nip01/nip01.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';
import 'package:submarine/services/database_service.dart';
import 'package:submarine/services/stores.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  late final Ndk ndk;

  NdkResponse? subscription;

  String? get publicKey => ndk.accounts.getPublicKey();

  Future<void> loadApp() async {
    await _initNdk();

    final privateKey = await FlutterSecureStorage().read(key: "privateKey");

    if (privateKey == null) return;

    await signInWithPrivateKey(privateKey);
  }

  Future<void> _initNdk() async {
    final db = await getDatabase();
    ndk = Ndk(
      NdkConfig(
        eventVerifier: NoEventVerifier(),
        cache: SembastCacheManager(db),
        bootstrapRelays: kDebugMode
            ? ["wss://bwcervpt.mooo.com/"]
            : DEFAULT_BOOTSTRAP_RELAYS,
      ),
    );
  }

  Future<void> signInWithPrivateKey(
    String privateKey, {
    bool storelocaly = false,
  }) async {
    if (storelocaly) {
      await FlutterSecureStorage().write(key: "privateKey", value: privateKey);
    }

    final keyPair = KeyPair.fromPrivateKey(privateKey: privateKey);

    ndk.accounts.loginPrivateKey(
      pubkey: keyPair.publicKey,
      privkey: keyPair.privateKey,
    );

    listenEvents();
  }

  Future<void> logOut() async {
    final db = await DatabaseService().database;

    await Future.wait([
      stopListeningEvents(),
      FlutterSecureStorage().delete(key: "privateKey"),
      secretsStore.delete(db),
    ]);
    ndk.accounts.logout();
  }

  void listenEvents() async {
    await stopListeningEvents();

    subscription = ndk.requests.subscription(
      filters: [
        Filter(kinds: [5, 34567], authors: [publicKey!]),
        Filter(kinds: [34567], pTags: [publicKey!]),
      ],
      cacheRead: true,
      cacheWrite: true,
    );

    await for (final event in subscription!.stream) {
      if (event.kind == 5) {
        final targetEventsIds = event.getTags("e");
        final db = await DatabaseService().database;

        // Remove secrets where eventId is in targetEventsIds
        await secretsStore.delete(
          db,
          finder: sembast.Finder(
            filter: sembast.Filter.inList('eventId', targetEventsIds),
          ),
        );

        // Add deleted event IDs to store
        for (final eventId in targetEventsIds) {
          await deletedEventsStore.record(eventId).put(db, {'id': eventId});
        }
        continue;
      }

      if (await deletedEventsStore
          .record(event.id)
          .exists(await DatabaseService().database)) {
        continue;
      }

      final decryptedContent = await ndk.accounts
          .getLoggedAccount()!
          .signer
          .decryptNip44(ciphertext: event.content, senderPubKey: event.pubKey);

      if (decryptedContent == null) continue;

      Map<String, dynamic> secretJson = jsonDecode(decryptedContent);

      secretsStore
          .record(event.id)
          .put(
            await DatabaseService().database,
            DecryptedSecretEvent(
              eventId: event.id,
              createdAt: event.createdAt,
              secret: secretJson,
            ).toJson(),
          );
    }
  }

  Future<void> stopListeningEvents() async {
    if (subscription == null) return;
    await ndk.requests.closeSubscription(subscription!.requestId);
  }
}
