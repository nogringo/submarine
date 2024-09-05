import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nostr/nostr.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  final box = GetStorage();
  int _automaticLockAfter = 2;
  SecretKey? _secretKey;
  Keychain? nostrKey;

  late List<String> nostrRelays = storedNostrRelays;

  int get automaticLockAfter => _automaticLockAfter;
  set automaticLockAfter(int value) {
    _automaticLockAfter = value;
    update();
  }

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
  }

  List<String> get storedNostrRelays {
    final list = box.read("nostrRelays") ?? [];
    return List<String>.from(list);
  }

  set storedNostrRelays(List<String> value) {
    box.write("nostrRelays", value);
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
}

bool isNostrServer(String url) {
  final RegExp nostrRegex =
      RegExp(r'^(ws|wss):\/\/[a-zA-Z0-9.-]+(:[0-9]+)?(\/.*)?$');
  return nostrRegex.hasMatch(url);
}
