import 'attachment.dart';
import 'bank_account.dart';
import 'drivers_license.dart';
import 'field.dart';
import 'identity.dart';
import 'json.dart';
import 'login.dart';
import 'passport.dart';
import 'password_history.dart';
import 'payment_card.dart';
import 'secure_note.dart';
import 'ssh_key.dart';

extension type const CipherType(int value) {
  static const login = CipherType(1);
  static const secureNote = CipherType(2);
  static const card = CipherType(3);
  static const identity = CipherType(4);
  static const sshKey = CipherType(5);
  static const bankAccount = CipherType(6);
  static const driversLicense = CipherType(7);
  static const passport = CipherType(8);
}

extension type const CipherRepromptType(int value) {
  static const none = CipherRepromptType(0);
  static const password = CipherRepromptType(1);
}

/// The data of an item: a Bitwarden cipher, as in Bitwarden's JSON export.
class Cipher {
  Cipher({
    required this.type,
    required this.name,
    this.notes,
    this.favorite = false,
    this.reprompt = CipherRepromptType.none,
    this.folderId,
    List<Field>? fields,
    this.login,
    this.secureNote,
    this.card,
    this.identity,
    this.sshKey,
    this.bankAccount,
    this.driversLicense,
    this.passport,
    List<PasswordHistory>? passwordHistory,
    List<Attachment>? attachments,
    this.creationDate,
    this.revisionDate,
    this.deletedDate,
    this.archivedDate,
  }) : fields = fields ?? [],
       passwordHistory = passwordHistory ?? [],
       attachments = attachments ?? [],
       _source = const {} {
    creationDate ??= DateTime.now().toUtc();
    revisionDate ??= creationDate;
  }

  Cipher.fromJson(Map<String, dynamic> json)
    : type = CipherType(json['type']),
      name = json['name'] ?? '',
      notes = json['notes'],
      favorite = json['favorite'] ?? false,
      reprompt = CipherRepromptType(json['reprompt'] ?? 0),
      folderId = json['folderId'],
      fields = parseList(json['fields'], Field.fromJson),
      login = parseObject(json['login'], Login.fromJson),
      secureNote = parseObject(json['secureNote'], SecureNote.fromJson),
      card = parseObject(json['card'], PaymentCard.fromJson),
      identity = parseObject(json['identity'], Identity.fromJson),
      sshKey = parseObject(json['sshKey'], SshKey.fromJson),
      bankAccount = parseObject(json['bankAccount'], BankAccount.fromJson),
      driversLicense = parseObject(
        json['driversLicense'],
        DriversLicense.fromJson,
      ),
      passport = parseObject(json['passport'], Passport.fromJson),
      passwordHistory = parseList(
        json['passwordHistory'],
        PasswordHistory.fromJson,
      ),
      attachments = parseList(json['attachments'], Attachment.fromJson),
      creationDate = parseDate(json['creationDate']),
      revisionDate = parseDate(json['revisionDate']),
      deletedDate = parseDate(json['deletedDate']),
      archivedDate = parseDate(json['archivedDate']),
      _source = json;

  CipherType type;
  String name;
  String? notes;
  bool favorite;
  CipherRepromptType reprompt;
  String? folderId;
  List<Field> fields;
  Login? login;
  SecureNote? secureNote;
  PaymentCard? card;
  Identity? identity;
  SshKey? sshKey;
  BankAccount? bankAccount;
  DriversLicense? driversLicense;
  Passport? passport;
  List<PasswordHistory> passwordHistory;
  List<Attachment> attachments;
  DateTime? creationDate;
  DateTime? revisionDate;
  DateTime? deletedDate;
  DateTime? archivedDate;
  final Map<String, dynamic> _source;

  /// In the trash.
  bool get isDeleted => deletedDate != null;

  bool get isArchived => archivedDate != null;

  /// What Bitwarden shows under the name: a login's username, a card's brand
  /// and last digits, and so on.
  String? get subtitle => switch (type) {
    CipherType.login => _loginSubtitle(login),
    CipherType.card => _cardSubtitle(card),
    CipherType.identity => _joinPresent([
      identity?.firstName,
      identity?.lastName,
    ], ' '),
    CipherType.sshKey => sshKey?.keyFingerprint,
    CipherType.bankAccount => bankAccount?.bankName,
    CipherType.driversLicense => _joinPresent([
      _joinPresent([driversLicense?.firstName, driversLicense?.lastName], ' '),
      driversLicense?.issuingState,
    ], ', '),
    CipherType.passport => _joinPresent([
      _joinPresent([passport?.givenName, passport?.surname], ' '),
      passport?.issuingCountry,
    ], ', '),
    _ => null,
  };

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'type': type.value,
    'name': name,
    'notes': notes,
    'favorite': favorite,
    'reprompt': reprompt.value,
    'folderId': folderId,
    'fields': [for (final field in fields) field.toJson()],
    'login': login?.toJson(),
    'secureNote': secureNote?.toJson(),
    'card': card?.toJson(),
    'identity': identity?.toJson(),
    'sshKey': sshKey?.toJson(),
    'bankAccount': bankAccount?.toJson(),
    'driversLicense': driversLicense?.toJson(),
    'passport': passport?.toJson(),
    'passwordHistory': [for (final entry in passwordHistory) entry.toJson()],
    // Left out, as in Bitwarden's export, until the item has a file.
    'attachments': attachments.isEmpty && _source['attachments'] == null
        ? null
        : [for (final attachment in attachments) attachment.toJson()],
    'creationDate': formatDate(creationDate),
    'revisionDate': formatDate(revisionDate),
    'deletedDate': formatDate(deletedDate),
    'archivedDate': formatDate(archivedDate),
  });
}

String? _loginSubtitle(Login? login) {
  final username = login?.username;
  if ((username == null || username.isEmpty) &&
      (login?.fido2Credentials.isNotEmpty ?? false)) {
    return login!.fido2Credentials.first.userName;
  }
  return username;
}

String? _cardSubtitle(PaymentCard? card) {
  final number = card?.number;
  if (number == null || number.length < 4) return card?.brand;
  // Amex numbers end on 5 digits.
  final digits = number.length >= 5 && number.startsWith(RegExp('3[47]'))
      ? 5
      : 4;
  final brand = card?.brand ?? '';
  return '${brand.isEmpty ? '' : '$brand, '}'
      '*${number.substring(number.length - digits)}';
}

String _joinPresent(Iterable<String?> parts, String separator) => [
  for (final part in parts)
    if (part != null && part.isNotEmpty) part,
].join(separator);
