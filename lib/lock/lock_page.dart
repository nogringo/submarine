import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/constants.dart';
import 'package:submarine/lock/layouts/desktop_layout.dart';
import 'package:submarine/lock/layouts/mobile_layout.dart';
import 'package:submarine/lock/lock_controller.dart';

class LockPage extends StatelessWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LockController());
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth > mobileWidth) {
          return const DesktopLayout();
        }
        return const MobileLayout();
      },),
    );
  }
}
