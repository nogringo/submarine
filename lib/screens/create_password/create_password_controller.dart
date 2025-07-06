import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:sembast/sembast.dart';
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/create_password/new_field_dialog.dart';
import 'package:submarine/services/database_service.dart';
import 'package:submarine/services/stores.dart';

class CreatePasswordController extends GetxController {
  static CreatePasswordController get to => Get.find();

  bool isCreatingPassword = false;

  final titleController = TextEditingController();
  List<CustomField> fields = [
    CustomField(name: "Username"),
    CustomField(name: "Password", visible: false),
  ];
  bool isReorderMode = false;
  List<TextEditingController> websites = [];
  final newWebsiteController = TextEditingController(text: "https://");
  final noteController = TextEditingController();

  void newField(String name, {bool visible = true}) {
    fields.add(CustomField(name: name, visible: visible));
    update();
  }

  void showNewFieldDialog() {
    Get.dialog(
      NewFieldDialog(
        onAdd: (name, visible) => newField(name, visible: visible),
      ),
    );
  }

  void add2FA() {}

  void toggleReorderMode() {
    isReorderMode = !isReorderMode;
    update();
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = fields.removeAt(oldIndex);
    fields.insert(newIndex, item);
    update();
  }

  void addWebsite() {
    final newWebsite = newWebsiteController.text.trim();
    if (newWebsite.isNotEmpty) {
      // Check if website already exists
      final existingWebsites = websites
          .map((controller) => controller.text)
          .toList();
      if (!existingWebsites.contains(newWebsite)) {
        websites.add(TextEditingController(text: newWebsite));
        newWebsiteController.text = "https://";
        update();
      }
    }
  }

  void removeWebsite(TextEditingController website) {
    websites.remove(website);
    website.dispose();
    update();
  }

  void createPassword() async {
    isCreatingPassword = true;
    update();

    Map<String, dynamic> passwordJson = {};

    passwordJson["id"] = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();

    final title = titleController.text.trim();
    if (title.isNotEmpty) passwordJson["title"] = title;

    final fieldsWithValue = fields.where(
      (field) => field.value.text.trim().isNotEmpty,
    );
    if (fieldsWithValue.isNotEmpty) {
      passwordJson["fields"] = fieldsWithValue.map((field) {
        return {
          "name": field.name.trim(),
          "kind": field.visible ? "text" : "secret",
          "value": field.value.text.trim(),
        };
      }).toList();
    }

    if (websites.isNotEmpty) {
      passwordJson["urls"] = websites
          .map((website) => website.text.trim())
          .toList();
    }

    final note = noteController.text.trim();
    if (note.isNotEmpty) passwordJson["note"] = note;

    final loggedAccount = Repository.to.ndk.accounts.getLoggedAccount()!;
    final pubkey = loggedAccount.pubkey;
    String encryptedPassword = (await loggedAccount.signer.encryptNip44(
      plaintext: jsonEncode(passwordJson),
      recipientPubKey: pubkey,
    ))!;

    final nostrEvent = Nip01Event(
      pubKey: pubkey,
      kind: 4111,
      tags: [],
      content: encryptedPassword,
    );

    await loggedAccount.signer.sign(nostrEvent);

    await secretsStore
        .record(nostrEvent.id)
        .put(
          await DatabaseService().database,
          DecryptedSecretEvent(
            eventId: nostrEvent.id,
            createdAt: nostrEvent.createdAt,
            secret: passwordJson,
          ).toJson(),
        );

    Repository.to.ndk.broadcast.broadcast(nostrEvent: nostrEvent);

    Get.back();
  }
}

class CustomField {
  String name;
  TextEditingController value;
  bool visible;

  CustomField({
    this.name = "",
    TextEditingController? value,
    this.visible = true,
  }) : value = value ?? TextEditingController();
}
