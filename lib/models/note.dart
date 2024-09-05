import 'package:uuid/uuid.dart';

class Note {
  String id;
  DateTime date;
  String name;
  String content;

  Note({required this.name, required this.content, String? id, DateTime? date})
      : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'name': name,
      'content': content,
    };
  }
}
