import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/home/laboratory_controller.dart';
import 'package:submarine/home/home_controller.dart';
import 'package:submarine/home/profile_controller.dart';
import 'package:submarine/home/views/document_view.dart';
import 'package:submarine/home/views/laboratory_view.dart';
import 'package:submarine/home/views/list_app_bar.dart';
import 'package:submarine/home/views/profile_view.dart';
import 'package:submarine/note/note_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(LaboratoryController());
    Get.put(ProfileController());
    return GetBuilder<HomeController>(
      builder: (c) {
        return Scaffold(
          appBar: {
            PageContent.list: const ListAppBar(),
            PageContent.laboratory: AppBar(
              title: const Text("Laboratory"),
            ),
            PageContent.profile: AppBar(
              title: const Text("Profile"),
            ),
          }[c.pageContent],
          body: {
            PageContent.list: const DocumentView(),
            PageContent.laboratory: const LaboratoryView(),
            PageContent.profile: const ProfileView(),
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
                    onPressed: () {
                      Get.to(() => const NotePage());
                    },
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    color: c.pageContent == PageContent.laboratory
                        ? Get.theme.colorScheme.primary
                        : null,
                    onPressed: () => c.pageContent = PageContent.laboratory,
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
