import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TitleView extends StatelessWidget {
  const TitleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Image.asset(
          "./assets/logo_512_circle.png",
          height: 100,
        ),
        const SizedBox(height: 16),
        Text(
          "Open the Submarine",
          textAlign: TextAlign.center,
          style: Get.textTheme.titleLarge,
        ),
        const Text(
          "Enter your secret key",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
