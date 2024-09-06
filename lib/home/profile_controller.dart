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

  void removeNostrRelay(String nostrRelay) {
    Get.dialog(AlertDialog(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Relay deletion"),
          CloseButton(),
        ],
      ),
      content: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "You are about to delete "),
            TextSpan(
              text: nostrRelay,
              style: TextStyle(color: Get.theme.colorScheme.primary),
            ),
            const TextSpan(text: '. Do you want to continue ?'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text("Undo"),
        ),
        FilledButton(
          onPressed: () {
            Repository.to.removeNostrRelay(nostrRelay);
            Get.back();
          },
          child: const Text("Delete"),
        ),
      ],
    ));
  }

  copyPublicKey() async {
    await Clipboard.setData(
      ClipboardData(text: Repository.to.nostrKey!.public),
    );

    publicKeyCopied = true;
    await Future.delayed(const Duration(seconds: 4));
    publicKeyCopied = false;
  }
}
