import 'package:submarine/models/field.dart';

class TextField extends Field {
  final String value;

  TextField({required super.name, required this.value}) : super(kind: 'text');

  factory TextField.fromJson(Map<String, dynamic> json) {
    return TextField(name: json['name'], value: json['value']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'name': name, 'kind': kind, 'value': value};
  }
}
