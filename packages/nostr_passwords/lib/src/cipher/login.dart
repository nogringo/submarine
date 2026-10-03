import 'json.dart';

extension type const UriMatchStrategy(int value) {
  static const domain = UriMatchStrategy(0);
  static const host = UriMatchStrategy(1);
  static const startsWith = UriMatchStrategy(2);
  static const exact = UriMatchStrategy(3);
  static const regularExpression = UriMatchStrategy(4);
  static const never = UriMatchStrategy(5);
}

class Login {
  Login({
    List<LoginUri>? uris,
    this.username,
    this.password,
    this.totp,
    List<Fido2Credential>? fido2Credentials,
  }) : uris = uris ?? [],
       fido2Credentials = fido2Credentials ?? [],
       _source = const {};

  Login.fromJson(Map<String, dynamic> json)
    : uris = parseList(json['uris'], LoginUri.fromJson),
      username = json['username'],
      password = json['password'],
      totp = json['totp'],
      fido2Credentials = parseList(
        json['fido2Credentials'],
        Fido2Credential.fromJson,
      ),
      _source = json;

  List<LoginUri> uris;
  String? username;
  String? password;
  String? totp;
  List<Fido2Credential> fido2Credentials;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'uris': [for (final uri in uris) uri.toJson()],
    'username': username,
    'password': password,
    'totp': totp,
    'fido2Credentials': [
      for (final credential in fido2Credentials) credential.toJson(),
    ],
  });
}

class LoginUri {
  LoginUri(this.uri, {this.match}) : _source = const {};

  LoginUri.fromJson(Map<String, dynamic> json)
    : uri = json['uri'],
      match = json['match'] == null ? null : UriMatchStrategy(json['match']),
      _source = json;

  String? uri;
  UriMatchStrategy? match;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() =>
      mergeJson(_source, {'uri': uri, 'match': match?.value});
}

/// Bitwarden exports every value of a passkey as a string, `counter` and
/// `discoverable` included.
class Fido2Credential {
  Fido2Credential({
    required this.credentialId,
    required this.keyType,
    required this.keyAlgorithm,
    required this.keyCurve,
    required this.keyValue,
    required this.rpId,
    this.userHandle,
    this.userName,
    required this.counter,
    this.rpName,
    this.userDisplayName,
    required this.discoverable,
    this.creationDate,
  }) : _source = const {};

  Fido2Credential.fromJson(Map<String, dynamic> json)
    : credentialId = json['credentialId'] ?? '',
      keyType = json['keyType'] ?? '',
      keyAlgorithm = json['keyAlgorithm'] ?? '',
      keyCurve = json['keyCurve'] ?? '',
      keyValue = json['keyValue'] ?? '',
      rpId = json['rpId'] ?? '',
      userHandle = json['userHandle'],
      userName = json['userName'],
      counter = json['counter'] ?? '',
      rpName = json['rpName'],
      userDisplayName = json['userDisplayName'],
      discoverable = json['discoverable'] ?? 'false',
      creationDate = parseDate(json['creationDate']),
      _source = json;

  String credentialId;
  String keyType;
  String keyAlgorithm;
  String keyCurve;
  String keyValue;
  String rpId;
  String? userHandle;
  String? userName;
  String counter;
  String? rpName;
  String? userDisplayName;
  String discoverable;
  DateTime? creationDate;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'credentialId': credentialId,
    'keyType': keyType,
    'keyAlgorithm': keyAlgorithm,
    'keyCurve': keyCurve,
    'keyValue': keyValue,
    'rpId': rpId,
    'userHandle': userHandle,
    'userName': userName,
    'counter': counter,
    'rpName': rpName,
    'userDisplayName': userDisplayName,
    'discoverable': discoverable,
    'creationDate': formatDate(creationDate),
  });
}
