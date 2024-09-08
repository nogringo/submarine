import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/note/note_controller.dart';

class NotePage extends StatelessWidget {
  final Note? note;

  const NotePage({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    Get.put(NoteController(note: note));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        title: IconButton.filledTonal(
          onPressed: Get.back,
          icon: const Icon(Icons.close),
        ),
        actions: [
          FilledButton(
            onPressed: NoteController.to.save,
            child: const Text("Save"),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: NoteController.to.nameController,
              textCapitalization: TextCapitalization.sentences,
              style: Get.textTheme.headlineMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Title",
              ),
            ),
            Expanded(
              child: TextField(
                controller: NoteController.to.contentController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Note",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
