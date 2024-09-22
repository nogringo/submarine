import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/note/note_viewer/note_viewer_page.dart';

class NoteHistoryPage extends StatelessWidget {
  final Note note;

  const NoteHistoryPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: ListView.builder(
        itemCount: note.history.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(DateFormat().format(note.history[i].date)),
            onTap: () {
              Get.to(
                () => NoteViewerPage(
                  note: note,
                  noteVersion: note.history[i],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
