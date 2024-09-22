import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/custom_field/custom_field_viewer/custom_field_viewer_page.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/note/note_viewer/note_viewer_page.dart';
import 'package:submarine/repository.dart';

class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Repository>(builder: (c) {
      return ListView.builder(
        itemCount: c.items.length,
        itemBuilder: (_, i) {
          final item = c.items[i];

          if (item is Note) {
            Note note = item;

            Widget? subtitle;
            if (note.content.isNotEmpty) {
              subtitle = Text(
                note.content,
                maxLines: 1,
              );
            }

            return ListTile(
              leading: const Icon(Icons.text_snippet_outlined),
              title: Text(note.name),
              subtitle: subtitle,
              onTap: () {
                Get.to(() => NoteViewerPage(note: note));
              },
            );
          }

          if (item is CustomField) {
            CustomField customField = item;

            return ListTile(
              leading: const Icon(Icons.grid_view_outlined),
              title: Text(customField.name),
              onTap: () {
                Get.to(() => CustomFieldViewerPage(customField: customField));
              },
            );
          }

          return null;
        },
      );
    });
  }
}
