import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/config.dart';
import 'package:submarine/repository.dart';
import 'package:window_manager/window_manager.dart';

class SigninPage extends StatelessWidget {
  const SigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("$appTitle sign in", style: Get.textTheme.displaySmall),
                SizedBox(height: 16),
                NLogin(
                  ndk: Repository.to.ndk,
                  enableNip05Login: false,
                  enableNpubLogin: false,
                  nostrConnect: NostrConnect(
                    relays: ["wss://relay.nsec.app", "wss://offchain.pub"],
                    appName: appTitle,
                  ),
                  onLoggedIn: () {
                    // Start listening to events after login
                    Repository.to.listenEvents();
                    Get.offAllNamed(AppRoutes.passwordManager);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
