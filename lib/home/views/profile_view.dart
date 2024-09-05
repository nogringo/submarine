import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:submarine/home/profile_controller.dart';
import 'package:submarine/repository.dart';
import 'package:toastification/toastification.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: const [
        AutomaticLock(),
        SizedBox(height: 12),
        NostrRelays(),
        SizedBox(height: 12),
        PublicKey(),
        Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("1.0.0", textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class AutomaticLock extends StatelessWidget {
  const AutomaticLock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Automatic lock",
            style: Get.textTheme.titleLarge,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GetBuilder<Repository>(builder: (c) {
              return DropdownButton<int>(
                value: c.automaticLockAfter,
                borderRadius: BorderRadius.circular(8),
                underline: Container(),
                onChanged: (int? automaticLockAfter) {
                  if (automaticLockAfter == null) return;
                  c.automaticLockAfter = automaticLockAfter;
                },
                items: [1, 2, 5, 30].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text("After $value minute${value > 1 ? "s" : ""}"),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class PublicKey extends StatelessWidget {
  const PublicKey({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Public key",
            style: Get.textTheme.titleLarge,
          ),
          Text(
            "The public key is like your username, you can share it with anyone.",
            style: Get.textTheme.labelLarge,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  Repository.to.nostrKey!.public,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GetBuilder<ProfileController>(
                builder: (c) {
                  return IconButton(
                    onPressed: c.copyPublicKey,
                    icon: Icon(c.publicKeyCopied ? Icons.check : Icons.copy),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NostrRelays extends StatelessWidget {
  const NostrRelays({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: GetBuilder<Repository>(builder: (_) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Nostr relays",
              style: Get.textTheme.titleLarge,
            ),
            ...Repository.to.nostrRelays.map(
              (nostrRelay) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      nostrRelay,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Repository.to.removeNostrRelay(nostrRelay);
                    },
                    icon: const Icon(Icons.cancel_outlined),
                  ),
                ],
              ),
            ),
            TextField(
              controller: ProfileController.to.newNostrRelayController,
              decoration: const InputDecoration(
                hintText: "wss://new.nostr.relay/",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => ProfileController.to.addNostrRelay,
            ),
          ],
        );
      }),
    );
  }
}
