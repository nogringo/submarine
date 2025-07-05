import 'package:submarine/models/otp_field.dart';
import 'package:submarine/models/secret_text_field.dart';
import 'package:submarine/models/text_field.dart';

abstract class Field {
  final String name;
  final String kind;

  Field({required this.name, required this.kind});

  factory Field.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'];
    switch (kind) {
      case 'text':
        return TextField.fromJson(json);
      case 'secret':
        return SecretTextField.fromJson(json);
      case 'otp':
        return OTPField.fromJson(json);
      default:
        throw Exception('Unknown field type: $kind');
    }
  }

  Map<String, dynamic> toJson();
}