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
    this.creationDate,
    this.revisionDate,
    this.deletedDate,
    this.archivedDate,
  }) : fields = fields ?? [],
       passwordHistory = passwordHistory ?? [],
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
  DateTime? creationDate;
  DateTime? revisionDate;
  DateTime? deletedDate;
  DateTime? archivedDate;
  final Map<String, dynamic> _source;

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
    'creationDate': formatDate(creationDate),
    'revisionDate': formatDate(revisionDate),
    'deletedDate': formatDate(deletedDate),
    'archivedDate': formatDate(archivedDate),
  });
}
