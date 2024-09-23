import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:submarine/constants.dart';
import 'package:submarine/home/controllers/profile_controller.dart';
import 'package:submarine/models/nostr_relay.dart';
import 'package:submarine/repository.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        const AutomaticLock(),
        const SizedBox(height: 12),
        const NostrRelays(),
        const SizedBox(height: 12),
        const PublicKey(),
        const SizedBox(height: 12),
        // ImportExport(), // TODO add import export features
        const Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("1.0.0", textAlign: TextAlign.center),
        ),
      ].map((e) => ItemWrapper(e)).toList(),
    );
  }
}

class ItemWrapper extends StatelessWidget {
  final Widget child;

  const ItemWrapper(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: tabletWidth),
        child: child,
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GetBuilder<Repository>(builder: (c) {
                return DropdownButton<int>(
                  value: c.automaticLockAfter,
                  borderRadius: BorderRadius.circular(8),
                  underline: Container(),
                  onChanged: (int? automaticLockAfter) {
                    if (automaticLockAfter == null) return;
                    c.automaticLockAfter = automaticLockAfter;
                  },
                  items:
                      [1, 2, 5, 10, 30].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child:
                            Text("After $value minute${value > 1 ? "s" : ""}"),
                      ),
                    );
                  }).toList(),
                );
              }),
              IconButton(
                color: Get.theme.colorScheme.primary,
                onPressed: Repository.to.lock,
                icon: const Icon(Icons.lock_outlined),
              ),
            ],
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
            "The public key is like your username, you can share it with anyone. Relay need it to store your data.",
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
                    color: Get.theme.colorScheme.primary,
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
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
              child: Text(
                "Nostr relays",
                style: Get.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Your relays are the place where your encrypted data are stored.",
                style: Get.textTheme.labelLarge,
              ),
            ),
            StreamBuilder(
              stream: Isar.getInstance()!.nostrRelays.watchLazy(),
              builder: (context, snapshot) {
                return Column(
                  children: Isar.getInstance()!
                      .nostrRelays
                      .filter()
                      .pubkeyEqualTo(Repository.to.nostrKey!.public)
                      .findAllSync()
                      .map(
                        (nostrRelay) => ListTile(
                          title: SelectableText(
                            nostrRelay.url,
                          ),
                          trailing: IconButton(
                            color: Get.theme.colorScheme.primary,
                            onPressed: () {
                              ProfileController.to.removeNostrRelay(nostrRelay);
                            },
                            icon: const Icon(Icons.cancel_outlined),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              child: TextField(
                controller: ProfileController.to.newNostrRelayController,
                autocorrect: false,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  hintText: "wss://new.nostr.relay/",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => ProfileController.to.addNostrRelay(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
