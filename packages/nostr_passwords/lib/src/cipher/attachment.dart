import 'json.dart';

/// A file attached to an item, stored encrypted on the vault's Blossom
/// servers. Bitwarden's fields, with [sha256] in place of its `url`.
class Attachment {
  Attachment({
    required this.id,
    required this.fileName,
    required this.key,
    required this.size,
    required this.sha256,
  }) : _source = const {};

  Attachment.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? '',
      fileName = json['fileName'] ?? '',
      key = json['key'] ?? '',
      size = json['size'] ?? '',
      sha256 = json['sha256'] ?? '',
      _source = json;

  String id;
  String fileName;

  /// The base64 of the file's AES-256-GCM key.
  String key;

  /// The size of the encrypted file in bytes, a string as in Bitwarden.
  String size;

  /// The hex SHA-256 of the encrypted file, its address on Blossom.
  String sha256;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'id': id,
    'fileName': fileName,
    'key': key,
    'size': size,
    'sha256': sha256,
  });
}
