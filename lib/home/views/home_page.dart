import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/custom_field/custom_field_editor/custom_field_editor_page.dart';
import 'package:submarine/home/controllers/laboratory_controller.dart';
import 'package:submarine/home/controllers/home_controller.dart';
import 'package:submarine/home/controllers/profile_controller.dart';
import 'package:submarine/home/views/expandable_fab.dart';
import 'package:submarine/home/views/items_view.dart';
import 'package:submarine/home/views/laboratory_view.dart';
import 'package:submarine/home/views/list_app_bar.dart';
import 'package:submarine/home/views/profile_view.dart';
import 'package:submarine/note/note_editor/note_editor_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(LaboratoryController());
    Get.put(ProfileController());

    return GetBuilder<HomeController>(builder: (c) {
      return Scaffold(
        appBar: [
          const ListAppBar(),
          AppBar(
            title: const Text("Laboratory"),
          ),
          AppBar(
            title: const Text("Profile"),
          )
        ][c.pageIndex],
        body: [
          const ItemsView(),
          const LaboratoryView(),
          const ProfileView()
        ][c.pageIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: c.pageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: HomeController.to.onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.list),
              label: "Items",
            ),
            NavigationDestination(
              icon: Icon(Icons.shield_outlined),
              label: "Laboratory",
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              label: "Profile",
            ),
          ],
        ),
        floatingActionButton: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: c.pageIndex == 0
              ? ExpandableFab(
                  distance: 56,
                  children: [
                    ActionButton(
                      onPressed: () {
                        Get.to(() => const CustomFieldEditorPage());
                      },
                      icon: const Icon(Icons.dashboard_customize_outlined),
                    ),
                    ActionButton(
                      onPressed: () {
                        Get.to(() => const NoteEditorPage());
                      },
                      icon: const Icon(Icons.note_add_outlined),
                    ),
                  ],
                )
              : null,
        ),
      );
    });
  }
}
