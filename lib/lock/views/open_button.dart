import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/lock/lock_controller.dart';

class OpenButton extends StatelessWidget {
  const OpenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LockController>(
      builder: (c) {
        return FilledButton(
          onPressed: c.opening ? null : LockController.to.open,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: c.opening ? 0 : 1,
                  child: const Text("Open"),
                ),
                Opacity(
                  opacity: c.opening ? 1 : 0,
                  child: const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
