import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/repository.dart';

class CustomFieldViewerController extends GetxController {
  static CustomFieldViewerController get to => Get.find();

  CustomField customField;
  Set<Field> visibleFields = {};
  bool _isCustomFieldCopied = false;

  bool get isCustomFieldCopied => _isCustomFieldCopied;
  set isCustomFieldCopied(bool value) {
    _isCustomFieldCopied = value;
    update();
  }

  CustomFieldViewerController(this.customField);

  toogleFieldVisibility(Field field) {
    bool removed = visibleFields.remove(field);
    if (!removed) visibleFields.add(field);
    update();
  }

  void copyCustomField() async {
    final encryptedCustomField = encryptText(
      jsonEncode(customField.toJson()),
      Repository.to.secretKey!,
    );

    await Clipboard.setData(ClipboardData(text: encryptedCustomField));

    isCustomFieldCopied = true;
    await Future.delayed(const Duration(seconds: 4));
    isCustomFieldCopied = false;
  }

  void deleteCustomField() async {
    final encryptedContent = encryptText(
      jsonEncode({
        "action": "delete",
        "id": customField.id,
      }),
      Repository.to.secretKey!,
    );

    final event = Event.from(
      kind: 1,
      content: encryptedContent,
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
