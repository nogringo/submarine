import 'package:submarine/end_to_end_encryption.dart';

class CustomField {
  List<CustomFieldVersion> history;

  bool get wasEdited => history.length > 1;

  CustomField(this.history);

  String get id => history.last.id;
  DateTime get date => history.last.date;
  String get name => history.last.name;
  List<Field> get fields => history.last.fields;

  // factory CustomField.fromJson(Map<String, dynamic> json) {
  //   return CustomField(
  //     (json['history'] as List).map((e) => CustomFieldVersion.fromJson(e)).toList(),
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'history': history.map((e) => e.toJson()).toList(),
    };
  }

  bool search(String part) {
    return history.last.search(part);
  }
}

class CustomFieldVersion {
  final String id;
  final DateTime date;
  final String name;
  final List<Field> fields;

  CustomFieldVersion({
    required this.name,
    required this.fields,
    String? id,
    DateTime? date,
  })  : id = id ?? hashString(DateTime.now().microsecondsSinceEpoch.toString()),
        date = date ?? DateTime.now();

  factory CustomFieldVersion.fromJson(Map<String, dynamic> json) {
    return CustomFieldVersion(
      id: json['id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      fields: (json['fields'] as List).map((e) => Field.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': "CustomField",
      'id': id,
      'date': DateTime.now().toIso8601String(),
      'name': name,
      'fields': fields.map((e) => e.toJson()).toList(),
    };
  }

  bool isSameVersion(CustomFieldVersion customFieldVersion) {
    // Compare names
    if (name != customFieldVersion.name) {
      return false;
    }

    // Compare fields list length
    if (fields.length != customFieldVersion.fields.length) {
      return false;
    }

    // Compare each field
    for (int i = 0; i < fields.length; i++) {
      if (!fields[i].isSameField(customFieldVersion.fields[i])) {
        return false;
      }
    }

    return true;
  }

  bool search(String part) {
    final partLowerCase = part.toLowerCase();

    if (name.toLowerCase().contains(partLowerCase)) {
      return true;
    }

    for (var field in fields) {
      if (field.name.toLowerCase().contains(partLowerCase)) {
        return true;
      }

      if (field.value.toLowerCase().contains(partLowerCase)) {
        return true;
      }
    }

    return false;
  }
}

class Field {
  bool hidden;
  String name;
  String value;

  Field({required this.name, required this.value, this.hidden = false});

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      name: json['name'],
      value: json['value'],
      hidden: json['hidden'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'name': name,
      'value': value,
    };

    if (hidden) json['hidden'] = true;

    return json;
  }

  Field clone() {
    return Field.fromJson(toJson());
  }

  bool isSameField(Field other) {
    return name == other.name && value == other.value && hidden == other.hidden;
  }
}
