import 'package:uuid/uuid.dart';

class Note {
  List<NoteVersion> history;

  bool get wasEdited => history.length > 1;

  Note(this.history);

  String get id => history.last.id;
  DateTime get date => history.last.date;
  String get name => history.last.name;
  String get content => history.last.content;

  // factory Note.fromJson(Map<String, dynamic> json) {
  //   return Note(
  //     (json['history'] as List).map((e) => NoteVersion.fromJson(e)).toList(),
  //   );
  // }

  Map<String, dynamic> toJson() {
    return {
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}

class NoteVersion {
  final String id;
  final DateTime date;
  final String name;
  final String content;

  NoteVersion({
    required this.name,
    required this.content,
    String? id,
    DateTime? date,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  factory NoteVersion.fromJson(Map<String, dynamic> json) {
    return NoteVersion(
      id: json['id'],
      date: DateTime.parse(json['date']),
      name: json['name'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': "Note",
      'id': id,
      'date': DateTime.now().toIso8601String(),
      'name': name,
      'content': content,
    };
  }

  bool isSameVersion(NoteVersion noteVersion) {
    // Compare names
    if (name != noteVersion.name) {
      return false;
    }

    // Compare contents
    if (content != noteVersion.content) {
      return false;
    }

    return true;
  }
}
