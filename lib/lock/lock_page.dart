import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/lock/lock_controller.dart';

class LockPage extends StatelessWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LockController());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
              GetBuilder<LockController>(builder: (c) {
                return TextField(
                  controller: c.passwordController,
                  obscureText: !c.showPassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outlined),
                    labelText: "Secret key",
                    suffixIcon: IconButton(
                      onPressed: c.togglePasswordVisibility,
                      icon: Icon(
                        c.showPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    errorText: [
                      null,
                      "You secret key can't be less than ${LockController.passwordMinimumLength} characters",
                    ][c.secretKeyError],
                  ),
                  onChanged: (_) => c.secretKeyChanged(),
                  onSubmitted: (_) => c.open(),
                );
              }),
              const Spacer(),
              GetBuilder<LockController>(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
