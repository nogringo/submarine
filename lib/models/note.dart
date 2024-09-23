import 'package:submarine/end_to_end_encryption.dart';

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

  bool search(String part) {
    return history.last.search(part);
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
  })  : id = id ?? hashString(DateTime.now().microsecondsSinceEpoch.toString()),
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

  bool search(String part) {
    final partLowerCase = part.toLowerCase();

    if (name.toLowerCase().contains(partLowerCase)) {
      return true;
    }

    if (content.toLowerCase().contains(partLowerCase)) {
      return true;
    }

    return false;
  }
}
