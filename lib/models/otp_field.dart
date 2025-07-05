import 'package:submarine/models/field.dart';
import 'package:submarine/models/otp_value.dart';

class OTPField extends Field {
  final OTPValue value;

  OTPField({
    required super.name,
    required this.value,
  }) : super(kind: 'otp');

  factory OTPField.fromJson(Map<String, dynamic> json) {
    return OTPField(
      name: json['name'],
      value: OTPValue.fromJson(json['value']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'kind': kind,
      'value': value.toJson(),
    };
  }
}