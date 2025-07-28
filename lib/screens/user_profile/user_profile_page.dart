import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:submarine/repository.dart';
import 'package:window_manager/window_manager.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
            title: const Text('Profile'),
            actions: [
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 550),
            child: NUserProfile(ndk: Repository.to.ndk),
          ),
        ),
      ),
      // TODO import secrets
      // TODO export secrets
      // TODO number of secrets
    );
  }
}
