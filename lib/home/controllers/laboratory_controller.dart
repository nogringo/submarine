import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/repository.dart';

class LaboratoryController extends GetxController {
  static LaboratoryController get to => Get.find();

  TextEditingController plainTextController = TextEditingController();
  TextEditingController encryptedTextController = TextEditingController();
  bool _encryptedPlaiTextCopied = false;

  String get plainText => plainTextController.text;
  String get encryptedText => encryptedTextController.text;

  bool get encryptedPlaiTextCopied => _encryptedPlaiTextCopied;
  set encryptedPlaiTextCopied(bool value) {
    _encryptedPlaiTextCopied = value;
    update();
  }

  copyEncryptedPlainText() async {
    final encryptedData = encryptText(
      plainText,
      Repository.to.secretKey!,
    );

    await Clipboard.setData(ClipboardData(text: encryptedData));

    encryptedPlaiTextCopied = true;
    await Future.delayed(const Duration(seconds: 4));
    encryptedPlaiTextCopied = false;
  }

  void encryptedTextChanged(String value) async {
    LaboratoryController.to.update();
    try {
      String decryptedText = decryptText(
        LaboratoryController.to.encryptedText,
        Repository.to.secretKey!,
      );

      try {
        final jsonObject = jsonDecode(decryptedText);
        const encoder = JsonEncoder.withIndent('  ');
        decryptedText = encoder.convert(jsonObject);
      } catch (e) {
        // 
      }

      plainTextController.text = decryptedText;
    } catch (e) {
      //
    }
  }
}
