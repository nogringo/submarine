import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:submarine/home/controllers/profile_controller.dart';
import 'package:submarine/models/nostr_relay.dart';
import 'package:submarine/repository.dart';

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
        SizedBox(height: 12),
        // ImportExport(), // TODO add import export features
        Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("1.0.0", textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

class ImportExport extends StatelessWidget {
  const ImportExport({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: DefaultTabController(
        length: 2,
        child: SizedBox(
          height: 200, // TODO remove this SizedBox
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                dividerHeight: 0,
                splashFactory: NoSplash.splashFactory,
                tabs: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text("Import"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text("Export"),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.tonal(
                            onPressed: ProfileController.to.import,
                            child: const Text("Choose a file"),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SwitchListTile(
                            value: true,
                            title: const Text("Encrypt data"),
                            onChanged: (value) {},
                          ),
                          FilledButton.tonal(
                            onPressed: ProfileController.to.export,
                            child: const Text("Export"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                  items: [1, 2, 5, 30].map<DropdownMenuItem<int>>((int value) {
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
            Text(
              "Your relays are the place where your encrypted data are stored.",
              style: Get.textTheme.labelLarge,
            ),
            StreamBuilder(
              stream: Isar.getInstance()!.nostrRelays.watchLazy(),
              builder: (context, snapshot) {
                return Column(
                  children: Isar.getInstance()!
                      .nostrRelays
                      .where()
                      .findAllSync()
                      .map(
                        (nostrRelay) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                nostrRelay.url,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            IconButton(
                              color: Get.theme.colorScheme.primary,
                              onPressed: () {
                                ProfileController.to
                                    .removeNostrRelay(nostrRelay);
                              },
                              icon: const Icon(Icons.cancel_outlined),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
            TextField(
              controller: ProfileController.to.newNostrRelayController,
              autocorrect: false,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: "wss://new.nostr.relay/",
                border: InputBorder.none,
              ),
              onSubmitted: (_) => ProfileController.to.addNostrRelay(),
            ),
          ],
        );
      }),
    );
  }
}
