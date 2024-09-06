import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/lock/lock_page.dart';
import 'package:submarine/models/note.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  final box = GetStorage();
  int onUserActivityCallCount = 0;

  SecretKey? _secretKey;
  Keychain? nostrKey;

  late List<String> nostrRelays = storedNostrRelays;

  List<Note> notes = [];

  SecretKey? get secretKey => _secretKey;
  set secretKey(SecretKey? value) {
    _secretKey = value;

    Repository.to.secretKey!.extractBytes().then(
      (bytes) {
        nostrKey = Keychain(Uint8List.fromList(bytes)
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join(''));
      },
    );

    getNotesFromLocalStorage().then((value) {
      notes = value;
      update();
    });
  }

  List<String> get storedNostrRelays {
    final list = box.read("nostrRelays") ?? [];
    return List<String>.from(list);
  }

  set storedNostrRelays(List<String> value) {
    box.write("nostrRelays", value);
  }

  int get automaticLockAfter => box.read("automaticLockAfter") ?? 2;
  set automaticLockAfter(int value) {
    box.write("automaticLockAfter", value);
    update();
  }

  Future<List<Note>> getNotesFromLocalStorage() async {
    String? encryptedStoredNotes = box.read("notes");
    if (encryptedStoredNotes == null) return [];
    String storedNotes = await EndToEndEncryption.decryptText(
      encryptedStoredNotes,
      secretKey!,
    );
    List<dynamic> map = jsonDecode(storedNotes);
    List<Note> notes = map.map((item) => Note.fromJson(item)).toList();
    return notes;
  }

  saveNotes() async {
    String encodedNotes = jsonEncode(
      notes.map((note) => note.toJson()).toList(),
    );
    String encryptedNotes = await EndToEndEncryption.encryptText(
      encodedNotes,
      secretKey!,
    );
    box.write("notes", encryptedNotes);
  }

  bool addNostrRelay(String newNostrRelay) {
    if (!isNostrServer(newNostrRelay)) return false;
    if (nostrRelays.contains(newNostrRelay)) return false;

    nostrRelays.add(newNostrRelay);
    update();
    storedNostrRelays = nostrRelays;

    return true;
  }

  void removeNostrRelay(String nostrRelay) {
    nostrRelays.remove(nostrRelay);
    update();
    storedNostrRelays = nostrRelays;
  }

  void createNote(Note note) {
    notes.insert(0, note);
    update();
    saveNotes();
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
}

bool isNostrServer(String url) {
  final RegExp nostrRegex = RegExp(
    r'^(ws|wss):\/\/[a-zA-Z0-9.-]+(:[0-9]+)?(\/.*)?$',
  );
  return nostrRegex.hasMatch(url);
}
