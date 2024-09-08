import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/home/controllers/laboratory_controller.dart';
import 'package:submarine/home/controllers/home_controller.dart';
import 'package:submarine/home/controllers/profile_controller.dart';
import 'package:submarine/home/views/items_view.dart';
import 'package:submarine/home/views/laboratory_view.dart';
import 'package:submarine/home/views/list_app_bar.dart';
import 'package:submarine/home/views/profile_view.dart';
import 'package:submarine/note/note_page.dart';
import 'package:submarine/repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(LaboratoryController());
    Get.put(ProfileController());

    return GetBuilder<HomeController>(builder: (c) {
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
          PageContent.list: const ItemsView(),
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
                MenuAnchorExample(),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Repository.to.syncWithNostr();
          },
        ),
      );
    });
  }
}

enum SampleItem { itemOne, itemTwo, itemThree }

class MenuAnchorExample extends StatefulWidget {
  const MenuAnchorExample({super.key});

  @override
  State<MenuAnchorExample> createState() => _MenuAnchorExampleState();
}

class _MenuAnchorExampleState extends State<MenuAnchorExample> {
  SampleItem? selectedMenu;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.add),
          tooltip: 'Show menu',
        );
      },
      menuChildren: List<MenuItemButton>.generate(
        3,
        (int index) => MenuItemButton(
          onPressed: () =>
              setState(() => selectedMenu = SampleItem.values[index]),
          child: Text('Item ${index + 1}'),
        ),
      ),
    );
  }
}
