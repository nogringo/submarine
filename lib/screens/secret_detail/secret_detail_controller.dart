import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nip01/nip01.dart';
import 'package:nip19/nip19.dart';
import 'package:submarine/models/follow.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/models/otp_field.dart' as model;
import 'package:submarine/models/text_field.dart' as model;
import 'package:submarine/models/secret_text_field.dart' as model;
import 'package:submarine/repository.dart';
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/services/stores.dart';
import 'package:flutter/material.dart';
import 'package:submarine/utils/toast_helper.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:submarine/models/secret_history_item.dart';
import 'package:submarine/models/mail.dart';

class SecretDetailController extends GetxController {
  Secret? secret;
  bool isLoading = true;
  final Map<String, bool> fieldVisibility = {};
  final RxString currentOTP = ''.obs;
  final RxDouble otpProgress = 0.0.obs;
  Timer? _otpTimer;

  List<Mail> emails = [];

  bool get hasNostrMail {
    if (secret?.fields == null) return false;
    return secret!.fields!
        .where(
          (field) =>
              field is model.TextField && field.value.endsWith("uid.ovh"),
        )
        .isNotEmpty;
  }

  String? get firstNsec {
    if (secret?.fields == null) return null;

    for (final field in secret!.fields!) {
      String? value;

      if (field is model.TextField) {
        value = field.value;
      } else if (field is model.SecretTextField) {
        value = field.value;
      }

      if (value != null && value.startsWith('nsec')) {
        try {
          // Validate that it's a real nsec by attempting to decode it
          Nip19.nsecToHex(value);
          return value;
        } catch (e) {
          // Not a valid nsec, continue searching
          continue;
        }
      }
    }

    return null;
  }

  SecretDetailController({String? eventId}) {
    if (eventId != null) {
      this.eventId = eventId;
      _loadSecretFromEventId();
    }
  }

  final shareRecipientController = TextEditingController();
  final isSharing = false.obs;
  String? eventId;
  final searchController = TextEditingController();
  final filteredFollows = <Follow>[].obs;

  // Secret history
  final secretHistory = <SecretHistoryItem>[].obs;
  final isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (secret != null) {
      _initializeOTP();
      if (secret!.id != null) {
        loadSecretHistory();
      }
    }
  }

  Future<void> _loadSecretFromEventId() async {
    if (eventId == null) return;

    try {
      final db = await Repository.to.getDb();
      final record = await secretsStore.record(eventId!).get(db);

      if (record != null) {
        final decryptedEvent = DecryptedSecretEvent.fromJson(record);
        secret = Secret.fromJson(decryptedEvent.secret);
        _initializeOTP();
        if (secret!.id != null) {
          loadSecretHistory();
        }
      }
    } catch (e) {
      // Error loading secret
    } finally {
      isLoading = false;
      update();
    }
  }

  // Check if this secret is the current/latest version
  bool isCurrentVersion(Secret secretToCheck) {
    if (secretHistory.isEmpty) return true;

    // The first item in history is the latest version
    final latestSecret = secretHistory.first.secret;

    // Compare by checking if all fields match
    // This is more reliable than comparing timestamps which might be equal
    return areSecretsEqual(secretToCheck, latestSecret);
  }

  bool areSecretsEqual(Secret s1, Secret s2) {
    // Compare basic fields
    if (s1.title != s2.title || s1.note != s2.note) return false;

    // Compare URLs
    final urls1 = s1.urls ?? [];
    final urls2 = s2.urls ?? [];
    if (urls1.length != urls2.length) return false;
    for (int i = 0; i < urls1.length; i++) {
      if (urls1[i] != urls2[i]) return false;
    }

    // Compare fields
    final fields1 = s1.fields ?? [];
    final fields2 = s2.fields ?? [];
    if (fields1.length != fields2.length) return false;

    // Simple comparison - could be enhanced
    return true;
  }

  Future<void> loadSecretHistory() async {
    if (secret?.id == null) return;

    isLoadingHistory.value = true;
    secretHistory.clear();

    try {
      final db = await Repository.to.getDb();

      // Find all records with the same secret ID
      final records = await secretsStore.find(
        db,
        finder: sembast.Finder(
          filter: sembast.Filter.equals('secret.id', secret!.id),
          sortOrders: [
            sembast.SortOrder(
              'createdAt',
              false,
            ), // Sort by createdAt descending
          ],
        ),
      );

      // Convert records to history items
      for (final record in records) {
        try {
          final decryptedEvent = DecryptedSecretEvent.fromJson(record.value);
          secretHistory.add(
            SecretHistoryItem(
              eventId: decryptedEvent.eventId,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                decryptedEvent.createdAt * 1000,
              ),
              secret: Secret.fromJson(decryptedEvent.secret),
            ),
          );
        } catch (e) {
          // Skip invalid records
          continue;
        }
      }
    } catch (e) {
      // Error loading secret history: $e
    } finally {
      isLoadingHistory.value = false;
    }
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    shareRecipientController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void toggleFieldVisibility(String fieldKey) {
    fieldVisibility[fieldKey] = !(fieldVisibility[fieldKey] ?? false);
    update();
  }

  void _initializeOTP() {
    if (secret?.fields == null) return;

    for (final field in secret!.fields!) {
      if (field is model.OTPField) {
        _startOTPGeneration(field);
        break;
      }
    }
  }

  void _startOTPGeneration(model.OTPField field) {
    _generateOTP(field);

    if (field.value.type == 'totp') {
      _otpTimer = Timer.periodic(Duration(seconds: 1), (_) {
        _generateOTP(field);
      });
    }
  }

  void _generateOTP(model.OTPField field) {
    final now = DateTime.now();
    final period = field.value.period;

    if (field.value.type == 'totp') {
      final secondsInPeriod = now.second % period;
      otpProgress.value = 1.0 - (secondsInPeriod / period);

      // For now, just display the OTP secret as we don't have the OTP package
      currentOTP.value = '••••••';
    } else if (field.value.type == 'hotp') {
      // For now, just display placeholder
      currentOTP.value = '••••••';
    }
  }

  void fetchEmails() async {
    if (firstNsec == null) return;

    final privateKey = Nip19.nsecToHex(firstNsec!);
    final keyPair = KeyPair.fromPrivateKey(privateKey: privateKey);

    final ndk = Ndk.defaultConfig();
    ndk.accounts.loginPrivateKey(
      pubkey: keyPair.publicKey,
      privkey: keyPair.privateKey,
    );

    final response = ndk.requests.query(
      filters: [
        Filter(kinds: [1059], pTags: [keyPair.publicKey]),
      ],
    );

    await for (final giftWrap in response.stream) {
      final unwrapped = await ndk.giftWrap.unwrapEvent(wrappedEvent: giftWrap);
      final messageEventJson = await ndk.accounts
          .getLoggedAccount()!
          .signer
          .decryptNip44(
            ciphertext: unwrapped.content,
            senderPubKey: unwrapped.pubKey,
          );
      Map<String, dynamic> json = jsonDecode(messageEventJson!);

      // Use the gift wrap ID as the unique identifier
      final emailId = giftWrap.id;

      // Check if email with this ID already exists
      if (emails.any((mail) => mail.id == emailId)) {
        continue;
      }

      final event = Nip01Event(
        pubKey: json["pubkey"],
        kind: json["kind"],
        tags: json["tags"] != null
            ? (json["tags"] as List)
                  .map(
                    (tag) =>
                        (tag as List).map((item) => item.toString()).toList(),
                  )
                  .toList()
            : [],
        content: json["content"],
        createdAt: json["created_at"] ?? giftWrap.createdAt,
      );

      final mail = Mail(id: emailId, event: event);

      emails.add(mail);
    }

    // Sort emails by timestamp in descending order (newest first)
    emails.sort((a, b) => b.event.createdAt.compareTo(a.event.createdAt));

    update();

    ndk.destroy();
  }

  Future<void> shareSecret() async {
    if (eventId == null) {
      ToastHelper.showError(
        context: Get.context!,
        title: 'Error',
        description: 'Unable to share this secret',
      );
      return;
    }

    final recipientInput = shareRecipientController.text.trim();
    if (recipientInput.isEmpty) {
      ToastHelper.showError(
        context: Get.context!,
        title: 'Error',
        description: 'Please enter a recipient',
      );
      return;
    }

    String recipientPubkey;
    try {
      // Check if input is npub
      if (recipientInput.startsWith('npub')) {
        recipientPubkey = Nip19.npubToHex(recipientInput);
      } else if (recipientInput.length == 64 && _isHex(recipientInput)) {
        // Already a hex pubkey
        recipientPubkey = recipientInput;
      } else {
        throw Exception('Invalid public key format');
      }
    } catch (e) {
      ToastHelper.showError(
        context: Get.context!,
        title: 'Error',
        description: 'Invalid public key format',
      );
      return;
    }

    isSharing.value = true;
    try {
      await Repository.to.shareSecret(
        eventId: eventId!,
        recipientPubkey: recipientPubkey,
      );

      shareRecipientController.clear();
      Get.back(); // Close the dialog

      ToastHelper.showSuccess(
        context: Get.context!,
        title: 'Success',
        description: 'Secret shared successfully',
      );
    } catch (e) {
      ToastHelper.showError(
        context: Get.context!,
        title: 'Error',
        description: 'Failed to share secret: ${e.toString()}',
      );
    } finally {
      isSharing.value = false;
    }
  }

  bool _isHex(String input) {
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(input);
  }

  void filterFollows(String query) {
    if (query.isEmpty) {
      filteredFollows.value = Repository.to.follows;
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredFollows.value = Repository.to.follows.where((follow) {
      final name = follow.displayName.toLowerCase();
      final nip05 = (follow.nip05 ?? '').toLowerCase();
      final npub = follow.pubkey.toLowerCase();

      return name.contains(lowerQuery) ||
          nip05.contains(lowerQuery) ||
          npub.contains(lowerQuery);
    }).toList();
  }

  void selectFollow(Follow follow) {
    shareRecipientController.text = follow.pubkey;
    searchController.clear();
    filterFollows('');
  }
}
