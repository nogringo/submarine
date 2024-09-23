import 'package:get/get.dart';

enum PageContent { list, laboratory, profile }

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  int _pageIndex = 0;

  int get pageIndex => _pageIndex;
  set pageIndex(int value) {
    if (pageIndex == value) return;
    _pageIndex = value;
    update();
  }

  void onDestinationSelected(int value) {
    pageIndex = value;
  }
}