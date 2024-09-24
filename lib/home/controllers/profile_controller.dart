import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:submarine/database.dart';
import 'package:submarine/repository.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  Set<String> onlineRelays = {};
  TextEditingController newNostrRelayController = TextEditingController();
  bool _publicKeyCopied = false;

  String get newNostrRelay => newNostrRelayController.text;

  bool get publicKeyCopied => _publicKeyCopied;
  set publicKeyCopied(bool value) {
    _publicKeyCopied = value;
    update();
  }

  addNostrRelay() async {
    final RegExp nostrRegex = RegExp(
      r'^(ws|wss):\/\/[a-zA-Z0-9.-]+(:[0-9]+)?(\/.*)?$',
    );
    final isNostrRelay = nostrRegex.hasMatch(newNostrRelay);

    if (!isNostrRelay) return;

    AppDatabase.to.insertNostrRelay(NostrRelayData(url: newNostrRelay));

    newNostrRelayController.text = "";
  }

  void removeNostrRelay(NostrRelayData nostrRelay) {
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
              text: nostrRelay.url,
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
          onPressed: () async {
            await AppDatabase.to.deleteNostrRelay(nostrRelay.url);

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
