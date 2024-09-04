import 'package:flutter/material.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/home/encryptor_controller.dart';
import 'package:submarine/repository.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

class EncryptorView extends StatelessWidget {
  const EncryptorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: EncryptorController.to.plainTextController,
          maxLines: null,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_open_outlined),
            labelText: "Text",
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () async {
                final encryptedData = await EndToEndEncryption.encryptText(
                  EncryptorController.to.plainText,
                  Repository.to.symmetricKey!,
                );

                await Clipboard.setData(ClipboardData(text: encryptedData));

                toastification.show(
                  style: ToastificationStyle.simple,
                  title: const Text("Encrypted text copied"),
                  alignment: Alignment.bottomCenter,
                  autoCloseDuration: const Duration(seconds: 4),
                  borderRadius: BorderRadius.circular(12.0),
                  applyBlurEffect: true,
                );
              },
              icon: const Icon(Icons.copy),
            ),
            IconButton(
              onPressed: () {
                EncryptorController.to.plainTextController.text = '';
              },
              icon: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
        TextField(
          controller: EncryptorController.to.encryptedTextController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outlined),
            labelText: "Encrypted text",
            suffixIcon: IconButton(
              onPressed: () {
                EncryptorController.to.encryptedTextController.text = '';
              },
              icon: const Icon(Icons.backspace_outlined),
            ),
          ),
          onChanged: (value) async {
            try {
              final decryptedText = await EndToEndEncryption.decryptText(
                EncryptorController.to.encryptedText,
                Repository.to.symmetricKey!,
              );

              EncryptorController.to.plainTextController.text = decryptedText;
            } catch (e) {
              //
            }
          },
        ),
      ],
    );
  }
}
