import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/home/controllers/laboratory_controller.dart';

class LaboratoryView extends StatelessWidget {
  const LaboratoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: LaboratoryController.to.plainTextController,
            maxLines: null,
            decoration: const InputDecoration(
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
            onChanged: LaboratoryController.to.encryptedTextChanged,
          ),
          // TODO add encrypt decrypt files features
          // IconButton(onPressed: null, icon: Container()),
          // FilledButton.icon(
          //   onPressed: LaboratoryController.to.chooseFiles,
          //   label: const Text("Choose a file"),
          // ),
        ],
      ),
    );
  }
}

// TODO add a field forcustom encryption decrytion key
