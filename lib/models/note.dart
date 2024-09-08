import 'package:submarine/models/item.dart';

class Note extends Item {
  String content;

  Note({required super.name, required this.content, super.id, super.date});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      content: json['content'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': "Note",
      'name': name,
      'content': content,
    };
  }
}
