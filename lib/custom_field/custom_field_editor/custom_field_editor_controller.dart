import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/database.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/functions.dart';
import 'package:submarine/models/custom_field.dart';
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

    AppDatabase.to.insertNostrEvent(NostrEventData(
      id: event.id,
      pubkey: event.pubkey,
      createdAt: DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000),
      kind: event.kind,
      tags: convertTagsToJson(event.tags),
      content: event.content,
      sig: event.sig,
    ));

    Get.back();
  }
}
