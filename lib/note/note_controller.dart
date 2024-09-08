import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/repository.dart';

class NoteController extends GetxController {
  static NoteController get to => Get.find();

  Note? note;

  TextEditingController nameController;
  TextEditingController contentController;

  String get name => nameController.text;
  String get content => contentController.text;

  NoteController({this.note})
      : nameController = TextEditingController(text: note?.name),
        contentController = TextEditingController(text: note?.content);

  save() async {
    final newNote = Note(name: name, content: content);

    final encryptedNote = encryptText(
      jsonEncode(newNote.toJson()),
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

    Repository.to.sendNostrEvent(serializedEvent);

    Get.back();
  }
}
