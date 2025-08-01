import 'dart:convert';

import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:submarine/get_database.dart';
import 'package:submarine/models/decrypted_event.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';
import 'package:submarine/models/follow.dart';
import 'package:submarine/services/database_service.dart';
import 'package:submarine/services/stores.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  late final Ndk ndk;

  NdkResponse? subscription;

  final follows = <Follow>[].obs;
  final isLoadingFollows = false.obs;

  String? get publicKey => ndk.accounts.getPublicKey();

  Future<void> loadApp() async {
    await _initNdk();
    await nRestoreLastSession(Repository.to.ndk);
  }

  Future<void> _initNdk() async {
    final db = await getDatabase();
    ndk = Ndk(
      NdkConfig(
        eventVerifier: Bip340EventVerifier(),
        cache: SembastCacheManager(db),
      ),
    );
  }

  Future<void> shareSecret({
    required String eventId,
    required String recipientPubkey,
  }) async {
    // Get the secret from local storage
    final db = await DatabaseService().database;
    final record = await secretsStore.record(eventId).get(db);

    if (record == null) {
      throw Exception('Secret not found');
    }

    final decryptedEvent = DecryptedSecretEvent.fromJson(record);
    final secretJson = jsonEncode(decryptedEvent.secret);

    // Encrypt the secret using recipient's public key
    final encryptedContent = await ndk.accounts
        .getLoggedAccount()!
        .signer
        .encryptNip44(plaintext: secretJson, recipientPubKey: recipientPubkey);

    if (encryptedContent == null) {
      throw Exception('Failed to encrypt secret');
    }

    // Create event with p tag for recipient
    final event = Nip01Event(
      kind: 4111,
      tags: [
        ["d", decryptedEvent.secret['id'] ?? eventId],
        ["p", recipientPubkey],
      ],
      content: encryptedContent,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      pubKey: publicKey!,
    );

    // Sign and publish the event
    await ndk.accounts.getLoggedAccount()!.signer.sign(event);
    ndk.broadcast.broadcast(nostrEvent: event);
  }

  Future<void> loadFollows() async {
    if (publicKey == null) return;

    isLoadingFollows.value = true;
    follows.clear(); // Clear existing follows to get fresh data

    try {
      final response = ndk.requests.query(
        filters: [
          Filter(kinds: [3], authors: [publicKey!], limit: 1),
        ],
        cacheRead: false, // Don't read from cache to get latest
      );

      await for (final event in response.stream) {
        final followList = <Follow>[];
        for (final tag in event.tags) {
          if (tag.length >= 2 && tag[0] == 'p') {
            final pubkey = tag[1];
            String? relay;
            String? petname;

            if (tag.length > 2) relay = tag[2];
            if (tag.length > 3) petname = tag[3];

            followList.add(
              Follow(pubkey: pubkey, relay: relay, petname: petname),
            );
          }
        }

        follows.value = followList;

        // Fetch metadata for follows
        await _fetchFollowsMetadata();
        break;
      }
    } catch (e) {
      // Error loading follows: $e
    } finally {
      isLoadingFollows.value = false;
    }
  }

  Future<void> _fetchFollowsMetadata() async {
    if (follows.isEmpty) return;

    final pubkeys = follows.map((f) => f.pubkey).toList();
    final response = ndk.requests.query(
      filters: [
        Filter(kinds: [0], authors: pubkeys),
      ],
      cacheRead: false, // Get latest metadata
    );

    await for (final event in response.stream) {
      try {
        final metadata = jsonDecode(event.content);
        final followIndex = follows.indexWhere((f) => f.pubkey == event.pubKey);
        if (followIndex != -1) {
          follows[followIndex] = follows[followIndex].copyWith(
            name: metadata['name'] ?? metadata['display_name'],
            picture: metadata['picture'],
            nip05: metadata['nip05'],
          );
        }
      } catch (e) {
        // Error parsing metadata: $e
      }
    }
  }

  void listenEvents() async {
    await stopListeningEvents();

    subscription = ndk.requests.subscription(
      filters: [
        Filter(kinds: [5, 4111], authors: [publicKey!]),
        Filter(kinds: [4111], pTags: [publicKey!]),
      ],
      cacheRead: true,
      cacheWrite: true,
    );

    await for (final event in subscription!.stream) {
      if (event.kind == 5) {
        final targetEventsIds = event.getTags("e");
        final db = await DatabaseService().database;

        // Remove secrets where eventId is in targetEventsIds
        secretsStore.delete(
          db,
          finder: sembast.Finder(
            filter: sembast.Filter.inList('eventId', targetEventsIds),
          ),
        );

        // Add deleted event IDs to store
        for (final eventId in targetEventsIds) {
          deletedEventsStore.record(eventId).put(db, {'id': eventId});
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
