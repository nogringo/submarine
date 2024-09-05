import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/home/views/home_page.dart';
import 'package:submarine/repository.dart';

class LockController extends GetxController {
  static LockController get to => Get.find();

  static const int passwordMinimumLength = 8;

  TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  int secretKeyError = 0;

  String get password => passwordController.text;

  bool get showPassword => _showPassword;
  set showPassword(bool value) {
    _showPassword = value;
    update();
  }

  secretKeyChanged() {
    secretKeyError = 0;
    update();
  }

  togglePasswordVisibility() {
    showPassword = !showPassword;
  }

  open() async {
    if (password.length < passwordMinimumLength) {
      secretKeyError = 1;
      update();
      return;
    }

    Repository.to.secretKey = await EndToEndEncryption.derivatePassword(password);

    Get.off(() => const HomePage());
  }
}
