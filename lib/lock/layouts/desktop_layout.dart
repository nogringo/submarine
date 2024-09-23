import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/constants.dart';
import 'package:submarine/lock/views/open_button.dart';
import 'package:submarine/lock/views/secret_key_input.dart';
import 'package:submarine/lock/views/title_view.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.5),
      child: LayoutBuilder(builder: (context, constraints) {
        return ListView(
          padding: EdgeInsets.symmetric(
              horizontal: (Get.width - mobileWidth) / 2 + 8),
          shrinkWrap: true,
          children: const [
            TitleView(),
            SecretKeyInput(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: OpenButton(),
            ),
          ],
        );
      }),
    );
  }
}
