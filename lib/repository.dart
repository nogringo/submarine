import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/api.dart';
import 'package:submarine/database.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/functions.dart';
import 'package:submarine/lock/lock_page.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/note.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  final box = GetStorage();
  Timer? inactivityTimer;

  Uint8List? _secretKey;
  Keychain? nostrKey;

  List items = [];
  List filteredItems = [];

  Uint8List? get secretKey => _secretKey;
  set secretKey(Uint8List? value) {
    _secretKey = value;

    if (_secretKey == null) {
      nostrKey = null;
    } else {
      nostrKey = Keychain(
        _secretKey!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(''),
      );
      listenNostrEvents();
    }
  }

  int get automaticLockAfter => box.read("automaticLockAfter") ?? 2;
  set automaticLockAfter(int value) {
    box.write("automaticLockAfter", value);
    update();
  }

  void listenNostrEvents() {
    final nostrEventChanged = AppDatabase.to.watchNostrEventsByPubkey(
      nostrKey!.public,
    );
    nostrEventChanged.listen((_) {
      fillItems();
      sendUnsyncedNostrEvents();
    });
    fillItems();
  }

  void fillItems() async {
    final nostrEvents = await AppDatabase.to.getEventsForPubkey(
      nostrKey!.public,
    );

    Map<String, dynamic> mergedItems = {};
    for (var e in nostrEvents) {
      final json = jsonDecode(decryptText(
        e.content,
        secretKey!,
      ));

      if (json['type'] == "Note") {
        if (mergedItems[json["id"]] == null) {
          mergedItems[json["id"]] = Note([]);
        }
        Note note = mergedItems[json["id"]];
        note.history.add(NoteVersion.fromJson(json));
      } else if (json['type'] == "CustomField") {
        if (mergedItems[json["id"]] == null) {
          mergedItems[json["id"]] = CustomField([]);
        }
        CustomField customField = mergedItems[json["id"]];
        customField.history.add(CustomFieldVersion.fromJson(json));
      }
    }

    items = mergedItems.values.toList();
    update();
  }

  onUserActivity() async {
    inactivityTimer?.cancel();
    inactivityTimer = Timer(Duration(minutes: automaticLockAfter), () {
      bool isSubmarineOpen = _secretKey != null;
      if (isSubmarineOpen) lock();
    });
  }

  lock() {
    _secretKey = null;

    Get.offAll(() => const LockPage());
  }

  void fetchNostrEvents() async {
    final nostrRelays = await AppDatabase.to.getAllNostrRelays();

    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(kinds: [1], authors: [Repository.to.nostrKey!.public])
    ]);

    for (var nostrRelay in nostrRelays) {
      final events = await nostrFetchEvents(
        requestWithFilter.serialize(),
        nostrRelay.url,
      );
      for (var e in events) {
        final event = Event.fromJson(jsonDecode(e));
        NostrEventData? nostrEvent = await AppDatabase.to.findNostrEventById(
          event.id,
        );

        final nostrEventNotFound = nostrEvent == null;
        if (nostrEventNotFound) {
          nostrEvent = NostrEventData(
            id: event.id,
            pubkey: event.pubkey,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              event.createdAt * 1000,
            ),
            kind: event.kind,
            tags: convertTagsToJson(event.tags),
            content: event.content,
            sig: event.sig,
          );
          AppDatabase.to.insertNostrEvent(nostrEvent);
        }

        AppDatabase.to.insertRelayEventLink(event.id, nostrRelay.url);
      }
    }
  }

  Future<List<String>> getLocalUnsyncedEvents() async {
    final nostrRelays = await AppDatabase.to.getAllNostrRelays();
    final nostrEvents = await AppDatabase.to.getEventsForPubkey(
      nostrKey!.public,
    );

    Set<String> results = {};
    for (var nostrRelay in nostrRelays) {
      for (var nostrEvent in nostrEvents) {
        final isEventStored = await AppDatabase.to.isEventStoredOnRelay(
          nostrEvent.id,
          nostrRelay.url,
        );
        if (isEventStored) continue;

        results.add(decryptText(nostrEvent.content, secretKey!));
      }
    }

    return results.toList();
  }

  void sendUnsyncedNostrEvents() async {
    final nostrRelays = await AppDatabase.to.getAllNostrRelays();
    final nostrEvents = await AppDatabase.to.getEventsForPubkey(
      nostrKey!.public,
    );

    for (var nostrRelay in nostrRelays) {
      for (var nostrEvent in nostrEvents) {
        final isEventStored = await AppDatabase.to.isEventStoredOnRelay(
          nostrEvent.id,
          nostrRelay.url,
        );
        if (isEventStored) continue;

        nostrSendEvent(
          Event(
            nostrEvent.id,
            nostrEvent.pubkey,
            nostrEvent.createdAt.millisecondsSinceEpoch ~/ 1000,
            nostrEvent.kind,
            convertJsonToTags(nostrEvent.tags),
            nostrEvent.content,
            nostrEvent.sig,
          ).serialize(),
          nostrRelay.url,
        );
      }
    }
  }

  void search(String value) {
    filteredItems = [];

    for (var item in items) {
      if (item.search(value)) filteredItems.add(item);
    }

    update();
  }
}
