import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:submarine/repository.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  TextEditingController newNostrRelayController = TextEditingController();
  bool _publicKeyCopied = false;

  String get newNostrRelay => newNostrRelayController.text;

  bool get publicKeyCopied => _publicKeyCopied;
  set publicKeyCopied(bool value) {
    _publicKeyCopied = value;
    update();
  }

  addNostrRelay() {
    bool isAdded = Repository.to.addNostrRelay(newNostrRelay);
    if (isAdded) newNostrRelayController.text = "";
  }

  copyPublicKey() async {
    publicKeyCopied = true;

    await Clipboard.setData(
      ClipboardData(text: Repository.to.nostrKey!.public),
    );

    await Future.delayed(const Duration(seconds: 4));
    publicKeyCopied = false;
  }
}
