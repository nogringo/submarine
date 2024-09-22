import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/note/note_editor/note_editor_controller.dart';

class NoteEditorPage extends StatelessWidget {
  final NoteVersion? noteVersion;

  const NoteEditorPage({super.key, this.noteVersion});

  @override
  Widget build(BuildContext context) {
    Get.put(NoteEditorController(
      noteVersion: noteVersion,
    ));

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
            onPressed: NoteEditorController.to.save,
            child: Text(noteVersion == null ? "Create" : "Save"),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: NoteEditorController.to.titleController,
              textCapitalization: TextCapitalization.sentences,
              style: Get.textTheme.headlineMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Title",
              ),
            ),
            Expanded(
              child: TextField(
                controller: NoteEditorController.to.contentController,
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

class TitleView extends StatelessWidget {
  const TitleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: NoteEditorController.to.titleController,
          textCapitalization: TextCapitalization.sentences,
          style: Get.textTheme.displaySmall,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none,
            filled: true,
            fillColor: Get.theme.colorScheme.secondaryContainer,
            hintText: "Title",
          ),
        ),
      ),
    );
  }
}
