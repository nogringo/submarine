import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:submarine/end_to_end_encryption.dart';
import 'package:submarine/models/nostr_relay.dart';
import 'package:submarine/nostr_relay_manager.dart';
import 'package:submarine/repository.dart';
import 'package:toastification/toastification.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  TextEditingController newNostrRelayController = TextEditingController();
  bool _publicKeyCopied = false;

  String get newNostrRelay => newNostrRelayController.text;

  bool get publicKeyCopied => _publicKeyCopied;
  set publicKeyCopied(bool value) {
    _publicKeyCopied = value;
    update();
  }

  addNostrRelay() async {
    final RegExp nostrRegex = RegExp(
      r'^(ws|wss):\/\/[a-zA-Z0-9.-]+(:[0-9]+)?(\/.*)?$',
    );
    final isNostrRelay = nostrRegex.hasMatch(newNostrRelay);

    if (!isNostrRelay) return;

    final isar = Isar.getInstance()!;

    final foundRelay = (await isar.nostrRelays
            .filter()
            .pubkeyEqualTo(Repository.to.nostrKey!.public)
            .findAll())
        .firstWhereOrNull((element) => element.url == newNostrRelay);

    if (foundRelay != null) return;

    NostrRelay nostrRelay = NostrRelay(
      Repository.to.nostrKey!.public,
      encryptText(newNostrRelay, Repository.to.secretKey!),
    );

    await isar.writeTxn(() async {
      await isar.nostrRelays.put(nostrRelay);
    });

    Repository.to.nostrRelaysManager[nostrRelay.id] =
        NostrRelayManager(nostrRelay.id);

    newNostrRelayController.text = "";
  }

  void removeNostrRelay(NostrRelay nostrRelay) {
    Get.dialog(AlertDialog(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Relay deletion"),
          CloseButton(),
        ],
      ),
      content: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: "You are about to delete "),
            TextSpan(
              text: nostrRelay.url,
              style: TextStyle(color: Get.theme.colorScheme.primary),
            ),
            const TextSpan(text: '. Do you want to continue ?'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text("Undo"),
        ),
        FilledButton(
          onPressed: () async {
            final isar = Isar.getInstance()!;

            await isar.writeTxn(() async {
              await isar.nostrRelays.delete(nostrRelay.id);
            });

            await Repository.to.nostrRelaysManager[nostrRelay.id]!.disconnect();
            Repository.to.nostrRelaysManager.remove(nostrRelay.id);

            Get.back();
          },
          child: const Text("Delete"),
        ),
      ],
    ));
  }

  copyPublicKey() async {
    await Clipboard.setData(
      ClipboardData(text: Repository.to.nostrKey!.public),
    );

    publicKeyCopied = true;
    await Future.delayed(const Duration(seconds: 4));
    publicKeyCopied = false;
  }

  void import() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["json", "pgp"],
    );

    if (result == null) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text("No file selected"),
        alignment: Alignment.bottomRight,
        autoCloseDuration: const Duration(seconds: 4),
      );
      return;
    }

    //  {
    //   final file = File(result.files.single.path!);
    //   EndToEndEncryption.encryptFile(
    //       result.files.single.path!,
    //       Repository.to.secretKey!,
    //       "${File(result.files.single.path!).parent.path}/encrypted.enc");
    // } else {
    //   // User canceled the picker
    // }
  }

  void export() async {
    String? result = await FilePicker.platform.saveFile(
      fileName: "Submarine.txt",
    );
    print(result);

    // if (result != null) {
    //   final file = File(result.files.single.path!);
    //   EndToEndEncryption.encryptFile(result.files.single.path!, Repository.to.secretKey!, "${File(result.files.single.path!).parent.path}/encrypted.enc");
    // } else {
    //   // User canceled the picker
    // }
  }
}
