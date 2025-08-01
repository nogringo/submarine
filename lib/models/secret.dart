import 'package:submarine/models/field.dart';

class Secret {
  final String? id;
  final String? title;
  final List<Field>? fields;
  final List<String>? urls;
  final String? note;

  Secret({this.id, this.title, this.fields, this.urls, this.note});

  factory Secret.fromJson(Map<String, dynamic> json) {
    return Secret(
      id: json['id'],
      title: json['title'],
      fields: (json['fields'] as List?)?.map((e) => Field.fromJson(e)).toList(),
      urls: (json['urls'] as List?)?.map((e) => e.toString()).toList(),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (fields != null) 'fields': fields!.map((e) => e.toJson()).toList(),
      if (urls != null) 'urls': urls,
      if (note != null) 'note': note,
    };
  }
}
