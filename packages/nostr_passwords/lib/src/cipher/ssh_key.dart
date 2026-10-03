import 'json.dart';

class SshKey {
  SshKey({
    required this.privateKey,
    required this.publicKey,
    required this.keyFingerprint,
  }) : _source = const {};

  SshKey.fromJson(Map<String, dynamic> json)
    : privateKey = json['privateKey'] ?? '',
      publicKey = json['publicKey'] ?? '',
      keyFingerprint = json['keyFingerprint'] ?? '',
      _source = json;

  String privateKey;
  String publicKey;
  String keyFingerprint;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'privateKey': privateKey,
    'publicKey': publicKey,
    'keyFingerprint': keyFingerprint,
  });
}
