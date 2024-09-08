import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/home/controllers/laboratory_controller.dart';
import 'package:submarine/repository.dart';

class LaboratoryView extends StatelessWidget {
  const LaboratoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: LaboratoryController.to.plainTextController,
          maxLines: null,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_open_outlined),
            labelText: "Text",
          ),
          onChanged: (value) {
            LaboratoryController.to.update();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: null, icon: Container()),
              GetBuilder<LaboratoryController>(builder: (c) {
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
              GetBuilder<LaboratoryController>(builder: (c) {
                return Visibility(
                  visible: c.plainText.isNotEmpty,
                  child: IconButton(
                    onPressed: () {
                      LaboratoryController.to.plainTextController.text = '';
                      LaboratoryController.to.update();
                    },
                    icon: const Icon(Icons.backspace_outlined),
                  ),
                );
              }),
            ],
          ),
        ),
        TextField(
          controller: LaboratoryController.to.encryptedTextController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outlined),
            labelText: "Encrypted text",
            suffixIcon: GetBuilder<LaboratoryController>(builder: (c) {
              return Visibility(
                visible: c.encryptedText.isNotEmpty,
                child: IconButton(
                  onPressed: () {
                    LaboratoryController.to.encryptedTextController.text = '';
                    LaboratoryController.to.plainTextController.text = '';
                    LaboratoryController.to.update();
                  },
                  icon: const Icon(Icons.backspace_outlined),
                ),
              );
            }),
          ),
          onChanged: (value) async {
            LaboratoryController.to.update();
            try {
              final decryptedText = decryptText(
                LaboratoryController.to.encryptedText,
                Repository.to.secretKey!,
              );

              LaboratoryController.to.plainTextController.text = decryptedText;
            } catch (e) {
              //
            }
          },
        ),
        // TODO add encrypt decrypt files features
        // IconButton(onPressed: null, icon: Container()),
        // FilledButton.icon(
        //   onPressed: LaboratoryController.to.chooseFiles,
        //   label: const Text("Choose a file"),
        // ),
      ],
    );
  }
}
