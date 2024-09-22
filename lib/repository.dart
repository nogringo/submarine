import 'dart:convert';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/lock/lock_page.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/nostr_relay.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/nostr_relay_manager.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  final box = GetStorage();
  int onUserActivityCallCount = 0;

  Map<int, NostrRelayManager> nostrRelaysManager = {};

  Uint8List? _secretKey;
  Keychain? nostrKey;

  List items = [];

  Isar get isar => Isar.getInstance()!;

  Uint8List? get secretKey => _secretKey;
  set secretKey(Uint8List? value) {
    _secretKey = value;

    nostrKey = Keychain(
      _secretKey!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(''),
    );

    listenNostrEvents();
  }

  int get automaticLockAfter => box.read("automaticLockAfter") ?? 2;
  set automaticLockAfter(int value) {
    box.write("automaticLockAfter", value);
    update();
  }

  void listenNostrEvents() {
    final nostrEventChanged = isar.nostrEvents.watchLazy();
    nostrEventChanged.listen((_) => fillItems());
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

  connectToNostr() async {
    final nostrRelays = await isar.nostrRelays
        .filter()
        .pubkeyEqualTo(Repository.to.nostrKey!.public)
        .findAll();

    for (NostrRelay nostrRelay in nostrRelays) {
      nostrRelaysManager[nostrRelay.id] = NostrRelayManager(nostrRelay.id);
    }
  }

  onUserActivity() async {
    onUserActivityCallCount++;
    await Future.delayed(Duration(minutes: automaticLockAfter));

    onUserActivityCallCount--;
    if (onUserActivityCallCount > 0) return;

    bool isSubmarineOpen = _secretKey != null;
    if (isSubmarineOpen) lock();
  }

  lock() {
    _secretKey = null;
    nostrKey = null;

    Get.offAll(() => const LockPage());
  }

  void sendNostrEvent(String serializedEvent) {
    for (NostrRelayManager relay in nostrRelaysManager.values) {
      relay.sendItem(serializedEvent);
    }
  }

  syncWithNostr() async {
    final nostrRelays = await isar.nostrRelays
        .filter()
        .pubkeyEqualTo(Repository.to.nostrKey!.public)
        .findAll();
    final nostrEvents = await isar.nostrEvents.where().findAll();

    for (NostrRelay nostrRelay in nostrRelays) {
      for (NostrEvent nostrEvent in nostrEvents) {
        final isEventStored = nostrEvent.nostrRelays.contains(nostrRelay);
        if (isEventStored) continue;

        nostrRelaysManager[nostrRelay.id]!.sendItem(nostrEvent.serializedEvent);
      }
    }
  }
}
