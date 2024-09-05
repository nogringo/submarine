import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/repository.dart';

class DocumentView extends StatelessWidget {
  const DocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Repository>(builder: (c) {
      return ListView(
        children: Repository.to.notes
            .map(
              (note) => ListTile(
                title: Text(note.name),
                subtitle: Text(
                  note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
      );
    });
  }
}
