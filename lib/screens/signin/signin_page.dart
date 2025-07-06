import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nip19/nip19.dart';
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
                TextField(
                  decoration: InputDecoration(labelText: "Nsec"),
                  onChanged: (nsec) async {
                    String privateKey;
                    try {
                      privateKey = Nip19.nsecToHex(nsec);
                    } catch (e) {
                      return;
                    }

                    await Repository.to.signInWithPrivateKey(
                      privateKey,
                      storelocaly: true,
                    );

                    Get.offNamed(AppRoutes.passwordManager);
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
