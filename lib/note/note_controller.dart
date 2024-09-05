import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/repository.dart';

class NoteController extends GetxController {
  static NoteController get to => Get.find();

  TextEditingController nameController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  String get name => nameController.text;
  String get content => contentController.text;

  save() {
    Note note = Note(name: name, content: content);

    Repository.to.createNote(note);

    Get.back();
  }
}