import 'package:uuid/uuid.dart';

class Note {
  String id;
  DateTime date;
  String title;
  String? content;
  Note? history;

  // UUID generator
  static const Uuid _uuid = Uuid();

  // Constructor
  Note({
    String? id,
    DateTime? date,
    required this.title,
    this.content,
    this.history,
  })  : id = id ?? _uuid.v4(), // Generate UUIDv4 if not provided
        date = date ?? DateTime.now();

  // Factory constructor to create from JSON
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      content: json['content'],
      history: json['history'] != null ? Note.fromJson(json['history']) : null,
    );
  }

  // Convert Note object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'history': history?.toJson(),
    };
  }

  
}
