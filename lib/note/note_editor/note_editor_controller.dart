import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/database.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/functions.dart';
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
