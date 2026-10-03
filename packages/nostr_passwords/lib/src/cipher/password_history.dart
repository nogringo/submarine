import 'json.dart';

class PasswordHistory {
  PasswordHistory({required this.password, this.lastUsedDate})
    : _source = const {};

  PasswordHistory.fromJson(Map<String, dynamic> json)
    : password = json['password'] ?? '',
      lastUsedDate = parseDate(json['lastUsedDate']),
      _source = json;

  String password;
  DateTime? lastUsedDate;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'password': password,
    'lastUsedDate': formatDate(lastUsedDate),
  });
}
