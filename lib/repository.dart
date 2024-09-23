import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/api.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/lock/lock_page.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/nostr_relay.dart';
import 'package:submarine/models/note.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  final box = GetStorage();
  Timer? inactivityTimer;

  Uint8List? _secretKey;
  Keychain? nostrKey;

  List items = [];
  List filteredItems = [];

  Isar get isar => Isar.getInstance()!;

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
    final nostrEventChanged = isar.nostrEvents.watchLazy();
    nostrEventChanged.listen((_) {
      fillItems();
      sendUnsyncedNostrEvents();
    });
    fillItems();
  }

  void fillItems() async {
    final nostrEvents = await Isar.getInstance()!
        .nostrEvents
        .filter()
        .pubkeyEqualTo(nostrKey!.public)
        .findAll();

    Map<String, dynamic> mergedItems = {};
    for (NostrEvent e in nostrEvents) {
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
    final nostrRelays = await isar.nostrRelays
        .filter()
        .pubkeyEqualTo(Repository.to.nostrKey!.public)
        .findAll();

    Request requestWithFilter = Request(generate64RandomHexChars(), [
      Filter(kinds: [1], authors: [Repository.to.nostrKey!.public])
    ]);

    for (NostrRelay nostrRelay in nostrRelays) {
      final events = await nostrFetchEvents(
        requestWithFilter.serialize(),
        nostrRelay.url,
      );
      for (var e in events) {
        final event = Event.fromJson(jsonDecode(e));
        NostrEvent? nostrEvent =
            await isar.nostrEvents.filter().idEqualTo(event.id).findFirst();

        final nostrEventNotFound = nostrEvent == null;
        if (nostrEventNotFound) {
          nostrEvent = NostrEvent(event.serialize());
          await isar.writeTxn(() async {
            await isar.nostrEvents.put(nostrEvent!);
          });
        }

        nostrEvent.nostrRelays.add(nostrRelay);
        await isar.writeTxn(() async {
          await nostrEvent!.nostrRelays.save();
        });
      }
    }
  }

  Future<List<String>> getLocalUnsyncedEvents() async {
    final nostrRelays = await isar.nostrRelays
        .filter()
        .pubkeyEqualTo(Repository.to.nostrKey!.public)
        .findAll();
    final nostrEvents = await isar.nostrEvents
        .filter()
        .pubkeyEqualTo(Repository.to.nostrKey!.public)
        .findAll();

    Set<String> results = {};
    for (NostrRelay nostrRelay in nostrRelays) {
      for (NostrEvent nostrEvent in nostrEvents) {
        final isEventStored = nostrEvent.nostrRelays.contains(nostrRelay);
        if (isEventStored) continue;

        results.add(decryptText(nostrEvent.content, secretKey!));
      }
    }

    return results.toList();
  }

  void sendUnsyncedNostrEvents() async {
    final nostrRelays = await isar.nostrRelays
        .filter()
        .pubkeyEqualTo(Repository.to.nostrKey!.public)
        .findAll();
    final nostrEvents = await isar.nostrEvents
        .filter()
        .pubkeyEqualTo(Repository.to.nostrKey!.public)
        .findAll();

    for (NostrRelay nostrRelay in nostrRelays) {
      for (NostrEvent nostrEvent in nostrEvents) {
        final isEventStored = nostrEvent.nostrRelays.contains(nostrRelay);
        if (isEventStored) continue;

        nostrSendEvent(nostrEvent.serializedEvent, nostrRelay.url);
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
