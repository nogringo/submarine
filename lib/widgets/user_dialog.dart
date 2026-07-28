import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/repository.dart';

void showUserDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          top: kToolbarHeight,
          right: 8,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(32),
            child: Container(
              constraints: BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              padding: EdgeInsets.all(20),
              child: _UserDialogContent(),
            ),
          ),
        ),
      ],
    ),
  );
}

class _UserDialogContent extends StatelessWidget {
  const _UserDialogContent();

  @override
  Widget build(BuildContext context) {
    final ndkFlutter = Get.find<NdkFlutter>();
    final ndk = ndkFlutter.ndk;
    final currentPubkey = ndk.accounts.getPublicKey();
    final hasMultipleAccounts = ndk.accounts.accounts.keys.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NPicture(
          ndkFlutter: ndkFlutter,
          pubkey: currentPubkey,
          circleAvatarRadius: 40,
        ),
        SizedBox(height: 8),
        Center(
          child: NName(
            ndkFlutter: ndkFlutter,
            pubkey: currentPubkey,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 32),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            Get.toNamed(AppRoutes.userProfile);
          },
          child: Text('Settings'),
        ),
        SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            if (hasMultipleAccounts) {
              Get.toNamed(AppRoutes.switchAccount);
            } else {
              Get.toNamed(AppRoutes.signIn);
            }
          },
          child: Text(
            hasMultipleAccounts
                ? 'Switch or Add Account'
                : 'Add Another Account',
          ),
        ),
        SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            Repository.to.logOut();
          },
          child: Text('Sign Out'),
        ),
      ],
    );
  }
}
