import 'json.dart';

extension type const SecureNoteType(int value) {
  static const generic = SecureNoteType(0);
}

class SecureNote {
  SecureNote({this.type = SecureNoteType.generic}) : _source = const {};

  SecureNote.fromJson(Map<String, dynamic> json)
    : type = SecureNoteType(json['type'] ?? 0),
      _source = json;

  SecureNoteType type;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {'type': type.value});
}
