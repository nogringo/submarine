import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/note/note_editor/note_editor_page.dart';
import 'package:submarine/note/note_history/note_history_page.dart';
import 'package:submarine/note/note_viewer/note_viewer_controller.dart';

class NoteViewerPage extends StatelessWidget {
  final Note note;
  final NoteVersion? noteVersion;

  const NoteViewerPage({super.key, required this.note, this.noteVersion});

  @override
  Widget build(BuildContext context) {
    Get.put(NoteViewerController(note));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        title: IconButton.filledTonal(
          onPressed: Get.back,
          icon: const Icon(Icons.close),
        ),
        actions: [
          if (noteVersion == null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: () {
                  Get.to(() => NoteEditorPage(noteVersion: note.history.last));
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Edit"),
              ),
            ),
          IconButton.filled(
            onPressed: NoteViewerController.to.copyNote,
            icon: GetBuilder<NoteViewerController>(builder: (c) {
              return Icon(
                c.isNoteCopied ? Icons.check : Icons.copy,
                color: Get.theme.colorScheme.onPrimary,
              );
            }),
          ),
          const SizedBox(width: 8),
          if (noteVersion == null && false)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filled(
                onPressed: NoteViewerController.to.deleteNote,
                icon: Icon(
                  Icons.delete_outlined,
                  color: Get.theme.colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          SelectableText(
            note.name,
            style: Get.textTheme.headlineMedium,
          ),
          SelectableText(note.content),
          const SizedBox(height: 16),
          
          if (noteVersion == null) HistoryView(note: note),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
    required this.note,
  });

  final Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (note.wasEdited)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Row(
                children: [
                  const Text("Modified"),
                  const SizedBox(width: 8),
                  Badge(
                    label: Text(
                      (note.history.length - 1).toString(),
                      style: TextStyle(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    backgroundColor: Get.theme.colorScheme.primaryContainer,
                  ),
                ],
              ),
              subtitle: Text(DateFormat().format(note.date)),
            ),
          ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text("Created"),
            subtitle: Text(
              DateFormat().format(note.history.first.date),
            ),
          ),
          if (note.wasEdited)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.tonal(
                onPressed: () {
                  Get.to(
                    () => NoteHistoryPage(
                      note: note,
                    ),
                  );
                },
                child: const Text("View item history"),
              ),
            ),
        ],
      ),
    );
  }
}

class FieldView extends StatelessWidget {
  final Field field;

  const FieldView(this.field, {super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Get.theme.colorScheme.secondaryContainer,
      child: ListTile(
        title: Text(
          field.name,
          style: const TextStyle(fontSize: 12.0),
        ),
        subtitle: GetBuilder<NoteViewerController>(builder: (c) {
          bool hideFieldValue =
              field.hidden && !c.visibleFields.contains(field);
          return Text(hideFieldValue ? '●' * 8 : field.value);
        }),
        trailing: field.hidden
            ? IconButton(
                onPressed: () =>
                    NoteViewerController.to.toogleFieldVisibility(field),
                icon: const Icon(Icons.visibility),
              )
            : null,
        onTap: () async {
          await Clipboard.setData(
            ClipboardData(text: field.value),
          );

          // TODO show toast with "${field.name} copied"
        },
      ),
    );
  }
}

// TODO add feature: copy encrypted item