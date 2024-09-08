import 'package:submarine/models/item.dart';

class CustomField extends Item {
  Map<String, FieldValue> fields;

  CustomField({
    required super.name,
    required this.fields,
    super.id,
    super.date,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      fields: (json['content'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          FieldValue.fromJson(value),
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': "CustomField",
      'name': name,
      'content': fields.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

enum FieldType { text, totp, hidden }

class FieldValue {
  FieldType fieldType;
  String value;

  FieldValue(this.fieldType, this.value);

  factory FieldValue.fromJson(Map<String, dynamic> json) {
    return FieldValue(
      FieldType.values
          .firstWhere((e) => e.toString() == 'FieldType.${json['fieldType']}'),
      json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldType': fieldType.toString().split('.').last,
      'value': value,
    };
  }
}
