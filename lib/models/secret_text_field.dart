import 'package:submarine/models/field.dart';

class SecretTextField extends Field {
  final String value;

  SecretTextField({
    required super.name,
    required this.value,
  }) : super(kind: 'secret');

  factory SecretTextField.fromJson(Map<String, dynamic> json) {
    return SecretTextField(
      name: json['name'],
      value: json['value'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'kind': kind,
      'value': value,
    };
  }
}