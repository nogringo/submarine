import 'package:flutter/foundation.dart';
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
  int _secretKeyError = 0;
  bool _opening = false;

  String get password => passwordController.text;

  bool get showPassword => _showPassword;
  set showPassword(bool value) {
    _showPassword = value;
    update();
  }

  int get secretKeyError => _secretKeyError;
  set secretKeyError(int value) {
    _secretKeyError = value;
    update();
  }

  bool get opening => _opening;
  set opening(bool value) {
    _opening = value;
    update();
  }

  secretKeyChanged() {
    secretKeyError = 0;
  }

  togglePasswordVisibility() {
    showPassword = !showPassword;
  }

  open() async {
    if (password.length < passwordMinimumLength) {
      secretKeyError = 1;
      return;
    }

    opening = true;

    Repository.to.secretKey = await compute(generateKey, password);
    Repository.to.connectToNostr();

    Get.off(() => const HomePage());
  }
}
