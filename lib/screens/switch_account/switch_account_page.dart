import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/repository.dart';
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
                ndkFlutter: Get.find<NdkFlutter>(),
                onAccountRemove: (pubkey) {},
                onAccountSwitch: (pubkey) async {
                  await Repository.to.switchAccount(pubkey);
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
