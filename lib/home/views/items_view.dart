import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/models/nostr_event.dart';
import 'package:submarine/models/note.dart';
import 'package:submarine/repository.dart';

class ItemsView extends StatelessWidget {
  const ItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Isar.getInstance()!.nostrEvents.watchLazy(),
      builder: (context, snapshot) {
        return ListView(
          children: Isar.getInstance()!.nostrEvents.where().findAllSync().map(
            (e) {
              final note = Note.fromJson(
                jsonDecode(decryptText(e.content, Repository.to.secretKey!)),
              );
              return ListTile(
                title: Text(note.name),
                subtitle: Text(note.content),
              );
            },
          ).toList(),
        );
      },
    );
  }
}
