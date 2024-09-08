import 'package:get/get.dart';

enum PageContent { list, laboratory, profile }

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  PageContent _pageContent = PageContent.list;

  PageContent get pageContent => _pageContent;
  set pageContent(PageContent value) {
    if (pageContent == value) return;
    _pageContent = value;
    update();
  }
}