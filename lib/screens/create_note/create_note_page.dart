import 'package:flutter/material.dart';

class CreateNotePage extends StatelessWidget {
  const CreateNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Note"),
        actions: [
          FilledButton(onPressed: () {}, child: Text("Create")),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Note',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
              ),
              expands: true,
              minLines: null,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
