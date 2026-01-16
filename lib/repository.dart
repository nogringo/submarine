import 'dart:convert';

import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:submarine/functions/get_user_database.dart';
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/models/follow.dart';
import 'package:submarine/services/stores.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  NdkResponse? ownEventsSubscription;
  NdkResponse? taggedEventsSubscription;

  final follows = <Follow>[].obs;
  final isLoadingFollows = false.obs;

  Ndk get ndk => Get.find<Ndk>();
  String? get publicKey => ndk.accounts.getPublicKey();

  Map<String, sembast.Database> dbs = {};

  // sembast.Database get db => dbs[ndk.accounts.getPublicKey()!]!;

  Future<sembast.Database> getDb([String? pubkey]) async {
    pubkey ??= ndk.accounts.getPublicKey();

    if (pubkey == null) throw "pubkey is null";

    sembast.Database? db = dbs[pubkey];

    if (db == null) {
      db = await getUserDatabase(pubkey);
      dbs[pubkey] = db;
    }

    return db;
  }

  Future<void> loadApp() async {
    await nRestoreAccounts(Repository.to.ndk);

    // Start listening to events if user is logged in
    if (publicKey != null) {
      listenEvents();
    }
  }

  Future<void> shareSecret({
    required String eventId,
    required String recipientPubkey,
  }) async {
    final record = await secretsStore.record(eventId).get(await getDb());

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
        filter: Filter(kinds: [3], authors: [publicKey!], limit: 1),

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
      filter: Filter(kinds: [0], authors: pubkeys),

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

    ownEventsSubscription = ndk.requests.subscription(
      filter: Filter(kinds: [5, 4111], authors: [publicKey!]),
      cacheRead: true,
      cacheWrite: true,
    );

    taggedEventsSubscription = ndk.requests.subscription(
      filter: Filter(kinds: [4111], pTags: [publicKey!]),
      cacheRead: true,
      cacheWrite: true,
    );

    _processSubscription(ownEventsSubscription!);
    _processSubscription(taggedEventsSubscription!);
  }

  void _processSubscription(NdkResponse subscription) async {
    await for (final event in subscription.stream) {
      if (event.kind == 5) {
        final targetEventsIds = event.getTags("e");

        // Remove secrets where eventId is in targetEventsIds
        secretsStore.delete(
          await getDb(),
          finder: sembast.Finder(
            filter: sembast.Filter.inList('eventId', targetEventsIds),
          ),
        );

        // Add deleted event IDs to store
        for (final eventId in targetEventsIds) {
          deletedEventsStore.record(eventId).put(await getDb(), {
            'id': eventId,
          });
        }
        continue;
      }

      if (await deletedEventsStore.record(event.id).exists(await getDb())) {
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
            await getDb(),
            DecryptedSecretEvent(
              eventId: event.id,
              createdAt: event.createdAt,
              secret: secretJson,
            ).toJson(),
          );
    }
  }

  Future<void> stopListeningEvents() async {
    await Future.wait([
      if (ownEventsSubscription != null)
        ndk.requests.closeSubscription(ownEventsSubscription!.requestId),
      if (taggedEventsSubscription != null)
        ndk.requests.closeSubscription(taggedEventsSubscription!.requestId),
    ]);
    ownEventsSubscription = null;
    taggedEventsSubscription = null;
  }

  Future<void> switchAccount(String newPubkey) async {
    // Stop listening to old account's events
    await stopListeningEvents();

    // Clear local data
    follows.clear();

    // Clear database for old account
    await secretsStore.delete(await getDb());
    await deletedEventsStore.delete(await getDb());

    // The NDK account switch is handled by the NSwitchAccount widget
    // After switching, start listening to new account's events
    if (publicKey != null) {
      listenEvents();
    }
  }

  Future<void> logOut() async {
    // Stop listening to events
    await stopListeningEvents();

    // Clear local data
    follows.clear();

    // Log out from NDK accounts
    ndk.accounts.logout();

    // Clear database
    await secretsStore.delete(await getDb());
    await deletedEventsStore.delete(await getDb());

    // Navigate to sign in page
    Get.offAllNamed('/sign-in');
  }
}
