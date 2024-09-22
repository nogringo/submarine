import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/repository.dart';

class NoteEditorController extends GetxController {
  static NoteEditorController get to => Get.find();

  NoteVersion? noteVersion;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  NoteEditorController({this.noteVersion}) {
    if (noteVersion == null) return;
    titleController = TextEditingController(text: noteVersion!.name);
    contentController = TextEditingController(text: noteVersion!.content);
  }

  save() async {
    final newNoteVersion = NoteVersion(
      id: noteVersion?.id,
      name: titleController.text,
      content: contentController.text,
    );

    if (noteVersion != null) {
      if (noteVersion!.isSameVersion(newNoteVersion)) {
        Get.back();
        return;
      }
    }

    final encryptedNote = encryptText(
      jsonEncode(newNoteVersion.toJson()),
      Repository.to.secretKey!,
    );

    final event = Event.from(
      kind: 1,
      content: encryptedNote,
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
