import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EncryptorController extends GetxController {
  static EncryptorController get to => Get.find();

  TextEditingController plainTextController = TextEditingController();
  TextEditingController encryptedTextController = TextEditingController();

  String get plainText => plainTextController.text;
  String get encryptedText => encryptedTextController.text;
}
