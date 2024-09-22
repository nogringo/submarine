import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/repository.dart';

class NoteViewerController extends GetxController {
  static NoteViewerController get to => Get.find();

  Note note;
  Set<Field> visibleFields = {};
  bool _isNoteCopied = false;

  bool get isNoteCopied => _isNoteCopied;
  set isNoteCopied(bool value) {
    _isNoteCopied = value;
    update();
  }

  NoteViewerController(this.note);

  toogleFieldVisibility(Field field) {
    bool removed = visibleFields.remove(field);
    if (!removed) visibleFields.add(field);
    update();
  }

  void copyNote() async {
    final encryptedNote = encryptText(
      jsonEncode(note.toJson()),
      Repository.to.secretKey!,
    );

    await Clipboard.setData(ClipboardData(text: encryptedNote));

    isNoteCopied = true;
    await Future.delayed(const Duration(seconds: 4));
    isNoteCopied = false;
  }

  void deleteNote() async {
    final encryptedContent = encryptText(
      jsonEncode({
        "action": "delete",
        "id": note.id,
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
