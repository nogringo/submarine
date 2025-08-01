import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class CreateNotePage extends StatelessWidget {
  const CreateNotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
            title: Text("New Note"),
            actions: [
              FilledButton(onPressed: () {}, child: Text("Create")),
              SizedBox(width: 8),
              if (!kIsWeb && GetPlatform.isDesktop)
                SizedBox(
                  width: 154,
                  child: WindowCaption(
                    brightness: Theme.of(context).brightness,
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          ),
        ),
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
