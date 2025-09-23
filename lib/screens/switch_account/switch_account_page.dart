import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_widgets/widgets/n_switch_account.dart';
import 'package:submarine/app_routes.dart';
import 'package:window_manager/window_manager.dart';

class SwitchAccountPage extends StatelessWidget {
  const SwitchAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
            title: Text('Switch Account'),
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
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: NSwitchAccount(
                ndk: Get.find<Ndk>(),
                onAccountRemove: (pubkey) {},
                onAccountSwitch: (pubkey) {
                  Get.offAllNamed(AppRoutes.passwordManager);
                },
                onAddAccount: () {
                  Get.toNamed(AppRoutes.signIn);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
