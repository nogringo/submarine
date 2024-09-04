import 'package:cryptography/cryptography.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  final box = GetStorage();
  SecretKey? symmetricKey;
}
