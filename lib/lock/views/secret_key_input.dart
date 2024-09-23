import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/lock/lock_controller.dart';

class SecretKeyInput extends StatelessWidget {
  const SecretKeyInput({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LockController>(builder: (c) {
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
    });
  }
}
