import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nip01/nip01.dart';
import 'package:nip19/nip19.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/models/otp_field.dart' as model;
import 'package:submarine/models/text_field.dart' as model;
import 'package:submarine/models/secret_text_field.dart' as model;

class SecretDetailController extends GetxController {
  static SecretDetailController get to => Get.find();

  final Secret secret;
  final Map<String, bool> fieldVisibility = {};
  final RxString currentOTP = ''.obs;
  final RxDouble otpProgress = 0.0.obs;
  Timer? _otpTimer;

  List<Nip01Event> emails = [];

  bool get hasNostrMail {
    if (secret.fields == null) return false;
    return secret.fields!
        .where(
          (field) =>
              field is model.TextField && field.value.endsWith("uid.ovh"),
        )
        .isNotEmpty;
  }

  String? get firstNsec {
    if (secret.fields == null) return null;

    for (final field in secret.fields!) {
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

  SecretDetailController({required this.secret});

  @override
  void onInit() {
    super.onInit();
    _initializeOTP();
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    super.onClose();
  }

  void toggleFieldVisibility(String fieldKey) {
    fieldVisibility[fieldKey] = !(fieldVisibility[fieldKey] ?? false);
    update();
  }

  void _initializeOTP() {
    if (secret.fields == null) return;

    for (final field in secret.fields!) {
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
      final email = Nip01Event(
        pubKey: json["pubkey"],
        kind: json["kind"],
        tags: [],
        content: json["content"],
      );
      emails.addIf(emails.where((e) => e.id == email.id).isEmpty, email);
    }

    // Sort emails by timestamp in descending order (newest first)
    emails.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    update();

    ndk.destroy();
  }
}
