import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/home/encryptor_controller.dart';
import 'package:submarine/repository.dart';

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
          onChanged: (value) {
            EncryptorController.to.update();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: null, icon: Container()),
              GetBuilder<EncryptorController>(builder: (c) {
                return Visibility(
                  visible: c.plainText.isNotEmpty,
                  child: IconButton(
                    onPressed: c.copyEncryptedPlainText,
                    icon: Icon(
                      c.encryptedPlaiTextCopied ? Icons.check : Icons.copy,
                    ),
                  ),
                );
              }),
              GetBuilder<EncryptorController>(builder: (c) {
                return Visibility(
                  visible: c.plainText.isNotEmpty,
                  child: IconButton(
                    onPressed: () {
                      EncryptorController.to.plainTextController.text = '';
                    },
                    icon: const Icon(Icons.backspace_outlined),
                  ),
                );
              }),
            ],
          ),
        ),
        TextField(
          controller: EncryptorController.to.encryptedTextController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outlined),
            labelText: "Encrypted text",
            suffixIcon: GetBuilder<EncryptorController>(
              builder: (c) {
                return Visibility(
                  visible: c.encryptedText.isNotEmpty,
                  child: IconButton(
                    onPressed: () {
                      EncryptorController.to.encryptedTextController.text = '';
                    },
                    icon: const Icon(Icons.backspace_outlined),
                  ),
                );
              }
            ),
          ),
          onChanged: (value) async {
            EncryptorController.to.update();
            try {
              final decryptedText = await EndToEndEncryption.decryptText(
                EncryptorController.to.encryptedText,
                Repository.to.secretKey!,
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
