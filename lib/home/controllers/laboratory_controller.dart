import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/repository.dart';
import 'package:toastification/toastification.dart';

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
      LaboratoryController.to.plainText,
      Repository.to.secretKey!,
    );

    await Clipboard.setData(ClipboardData(text: encryptedData));

    encryptedPlaiTextCopied = true;
    await Future.delayed(const Duration(seconds: 4));
    encryptedPlaiTextCopied = false;
  }

  void chooseFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result == null) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text("No file selected"),
        alignment: Alignment.bottomRight,
        autoCloseDuration: const Duration(seconds: 4),
      );
      return;
    }

    // for (PlatformFile file in result.files) {
      
    // }
  }
}
