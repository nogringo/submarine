import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/constants.dart';
import 'package:submarine/home/controllers/laboratory_controller.dart';
import 'package:submarine/home/controllers/home_controller.dart';
import 'package:submarine/home/controllers/profile_controller.dart';
import 'package:submarine/home/views/items_view.dart';
import 'package:submarine/home/views/laboratory_view.dart';
import 'package:submarine/home/views/list_app_bar.dart';
import 'package:submarine/home/views/profile_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(LaboratoryController());
    Get.put(ProfileController());

    final destinations = [
      {
        'label': 'Items',
        'icon': Icons.list,
      },
      {
        'label': 'Laboratory',
        'icon': Icons.shield_outlined,
      },
      {
        'label': 'Profile',
        'icon': Icons.person_outlined,
      },
    ];

    final navigationRailDestinations = destinations
        .map(
          (e) => NavigationRailDestination(
            icon: Icon(e['icon'] as IconData),
            label: Text(e['label'] as String),
          ),
        )
        .toList();

    final navigationBarDestinations = destinations
        .map(
          (e) => NavigationDestination(
            icon: Icon(e['icon'] as IconData),
            label: e['label'] as String,
          ),
        )
        .toList();

    return GetBuilder<HomeController>(builder: (c) {
      final appBar = [
        const ListAppBar(),
        AppBar(
          title: const Text("Laboratory"),
        ),
        AppBar(
          title: const Text("Profile"),
        )
      ][c.pageIndex];

      final pageContent = [
        const ItemsView(),
        const LaboratoryView(),
        const ProfileView()
      ][c.pageIndex];

      Widget navigationBarWidget = NavigationBar(
        selectedIndex: c.pageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: HomeController.to.onDestinationSelected,
        destinations: navigationBarDestinations,
      );

      return LayoutBuilder(builder: (context, constraints) {
        bool isMobile = constraints.maxWidth <= mobileWidth;

        late Widget body;
        if (isMobile) {
          body = pageContent;
        } else {
          body = Row(
            children: [
              NavigationRail(
                labelType: NavigationRailLabelType.selected,
                groupAlignment: 0,
                destinations: navigationRailDestinations,
                selectedIndex: c.pageIndex,
                onDestinationSelected: HomeController.to.onDestinationSelected,
              ),
              Expanded(child: pageContent),
            ],
          );
        }

        return Scaffold(
          appBar: appBar,
          body: body,
          bottomNavigationBar: isMobile ? navigationBarWidget : null,
        );
      });
    });
  }
}
