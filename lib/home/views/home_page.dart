import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/home/encryptor_controller.dart';
import 'package:submarine/home/home_controller.dart';
import 'package:submarine/home/views/encryptor_view.dart';
import 'package:submarine/home/views/list_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(EncryptorController());
    return GetBuilder<HomeController>(
      builder: (c) {
        return Scaffold(
          appBar: {
            PageContent.list: const ListAppBar(),
            PageContent.encryptor: AppBar(
              title: const Text("Encryptor"),
            ),
            PageContent.profile: AppBar(
              title: const Text("Profile"),
            ),
          }[c.pageContent],
          body: {
            PageContent.list: Container(),
            PageContent.encryptor: const EncryptorView(),
            PageContent.profile: Container(),
          }[c.pageContent],
          bottomNavigationBar: BottomAppBar(
            child: GetBuilder<HomeController>(builder: (c) {
              return Row(
                children: [
                  IconButton(
                    color: c.pageContent == PageContent.list
                        ? Get.theme.colorScheme.primary
                        : null,
                    onPressed: () => c.pageContent = PageContent.list,
                    icon: const Icon(Icons.list),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    color: c.pageContent == PageContent.encryptor
                        ? Get.theme.colorScheme.primary
                        : null,
                    onPressed: () => c.pageContent = PageContent.encryptor,
                    icon: const Icon(Icons.shield_outlined),
                  ),
                  const Spacer(),
                  IconButton(
                    color: c.pageContent == PageContent.profile
                        ? Get.theme.colorScheme.primary
                        : null,
                    onPressed: () => c.pageContent = PageContent.profile,
                    icon: const Icon(Icons.person_outlined),
                  ),
                ],
              );
            }),
          ),
        );
      }
    );
  }
}
