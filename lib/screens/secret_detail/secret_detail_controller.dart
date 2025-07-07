import 'dart:async';
import 'package:get/get.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/models/otp_field.dart' as model;

class SecretDetailController extends GetxController {
  final Secret secret;
  final Map<String, bool> fieldVisibility = {};
  final RxString currentOTP = ''.obs;
  final RxDouble otpProgress = 0.0.obs;
  Timer? _otpTimer;

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
}