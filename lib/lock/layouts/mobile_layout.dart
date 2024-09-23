import 'package:flutter/material.dart';
import 'package:submarine/lock/views/open_button.dart';
import 'package:submarine/lock/views/secret_key_input.dart';
import 'package:submarine/lock/views/title_view.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: const [
              TitleView(),
              SecretKeyInput(),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: OpenButton(),
        ),
      ],
    );
  }
}