import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/repository.dart';

class CustomFieldEditorController extends GetxController {
  static CustomFieldEditorController get to => Get.find();

  CustomFieldVersion? customFieldVersion;

  TextEditingController titleController = TextEditingController();
  List<Field> fields = [];
  Set<Field> visibleFields = {};

  TextEditingController newFieldNameController = TextEditingController();
  TextEditingController newFieldValueController = TextEditingController();
  bool isNewFieldHidden = false;

  CustomFieldEditorController({this.customFieldVersion}) {
    if (customFieldVersion == null) return;
    titleController = TextEditingController(text: customFieldVersion!.name);
    fields = customFieldVersion!.fields.map((e) => e.clone()).toList();
  }

  addNewField() {
    final newField = Field(
      name: newFieldNameController.text,
      value: newFieldValueController.text,
      hidden: isNewFieldHidden,
    );

    fields.add(newField);

    newFieldNameController.text = "";
    newFieldValueController.text = "";

    update();
  }

  toogleFieldVisibility(Field field) {
    bool removed = visibleFields.remove(field);
    if (!removed) visibleFields.add(field);
    update();
  }

  removeField(Field field) {
    fields.remove(field);
    update();
  }

  save() async {
    final newCustomFieldVersion = CustomFieldVersion(
      id: customFieldVersion?.id,
      name: titleController.text,
      fields: fields,
    );

    if (customFieldVersion != null) {
      if (customFieldVersion!.isSameVersion(newCustomFieldVersion)) {
        Get.back();
        return;
      }
    }

    final encryptedCustomField = encryptText(
      jsonEncode(newCustomFieldVersion.toJson()),
      Repository.to.secretKey!,
    );

    final event = Event.from(
      kind: 1,
      content: encryptedCustomField,
      privkey: Repository.to.nostrKey!.private,
    );

    final serializedEvent = event.serialize();

    final isar = Isar.getInstance()!;
    await isar.writeTxn(() async {
      await isar.nostrEvents.put(NostrEvent(serializedEvent));
    });

    Get.back();
  }
}
