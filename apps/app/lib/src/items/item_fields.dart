import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';

enum FieldKind {
  text,

  /// Hidden until shown.
  secret,

  /// A secret whose digits and special characters stand out once shown.
  password,

  /// A TOTP key, shown as its current code.
  totp,

  url,
  mono,

  /// Shown as is, nothing to copy.
  info,
}

class FieldRow {
  const FieldRow(this.label, this.value, [this.kind = FieldKind.text]);

  final String label;
  final String value;
  final FieldKind kind;

  bool get copyable => kind != FieldKind.info && kind != FieldKind.totp;
}

/// The fields of [cipher]'s type, without the empty ones. Notes, custom fields
/// and password history are apart.
List<FieldRow> typeFields(AppLocalizations l10n, Cipher cipher) {
  final rows = <FieldRow>[];
  void add(String label, String? value, [FieldKind kind = FieldKind.text]) {
    if (value != null && value.trim().isNotEmpty) {
      rows.add(FieldRow(label, value, kind));
    }
  }

  switch (cipher.type) {
    case CipherType.login:
      final login = cipher.login;
      add(l10n.username, login?.username);
      add(l10n.password, login?.password, FieldKind.password);
      add(l10n.verificationCode, login?.totp, FieldKind.totp);
      for (final uri in login?.uris ?? const <LoginUri>[]) {
        add(l10n.website, uri.uri, FieldKind.url);
      }
      for (final passkey in login?.fido2Credentials ?? const []) {
        final created = passkey.creationDate;
        add(
          l10n.passkey,
          created == null
              ? passkey.rpId
              : l10n.passkeyCreated(created.toLocal()),
          FieldKind.info,
        );
      }
    case CipherType.card:
      final card = cipher.card;
      add(l10n.cardholderName, card?.cardholderName);
      add(l10n.cardBrand, switch (card?.brand) {
        final brand? => cardBrandLabel(l10n, brand),
        null => null,
      });
      add(l10n.cardNumber, card?.number, FieldKind.secret);
      add(l10n.cardExpiration, _expiration(card?.expMonth, card?.expYear));
      add(l10n.cardCode, card?.code, FieldKind.secret);
    case CipherType.identity:
      final identity = cipher.identity;
      add(
        l10n.fullName,
        _join([
          identity?.title,
          identity?.firstName,
          identity?.middleName,
          identity?.lastName,
        ], ' '),
      );
      add(l10n.username, identity?.username);
      add(l10n.company, identity?.company);
      add(l10n.email, identity?.email);
      add(l10n.phone, identity?.phone);
      add(l10n.ssn, identity?.ssn, FieldKind.secret);
      add(l10n.passportNumber, identity?.passportNumber);
      add(l10n.licenseNumber, identity?.licenseNumber);
      add(
        l10n.address,
        _join([
          identity?.address1,
          identity?.address2,
          identity?.address3,
          _join([identity?.city, identity?.state, identity?.postalCode], ', '),
          identity?.country,
        ], '\n'),
      );
    case CipherType.sshKey:
      final sshKey = cipher.sshKey;
      add(l10n.privateKey, sshKey?.privateKey, FieldKind.secret);
      add(l10n.publicKey, sshKey?.publicKey, FieldKind.mono);
      add(l10n.fingerprint, sshKey?.keyFingerprint, FieldKind.mono);
    case CipherType.bankAccount:
      final account = cipher.bankAccount;
      add(l10n.bankName, account?.bankName);
      add(l10n.accountHolder, account?.nameOnAccount);
      if (account?.accountType case final type?) {
        add(l10n.accountType, _accountType(l10n, type), FieldKind.info);
      }
      add(l10n.accountNumber, account?.accountNumber, FieldKind.secret);
      add(l10n.routingNumber, account?.routingNumber);
      add(l10n.branchNumber, account?.branchNumber);
      add(l10n.pin, account?.pin, FieldKind.secret);
      add(l10n.swiftCode, account?.swiftCode);
      add(l10n.iban, account?.iban);
      add(l10n.bankPhone, account?.bankContactPhone);
    case CipherType.driversLicense:
      final license = cipher.driversLicense;
      add(
        l10n.fullName,
        _join([
          license?.firstName,
          license?.middleName,
          license?.lastName,
        ], ' '),
      );
      add(l10n.dateOfBirth, license?.dateOfBirth);
      add(l10n.licenseNumber, license?.licenseNumber);
      add(l10n.issuingCountry, license?.issuingCountry);
      add(l10n.issuingState, license?.issuingState);
      add(l10n.issueDate, license?.issueDate);
      add(l10n.expirationDate, license?.expirationDate);
      add(l10n.issuingAuthority, license?.issuingAuthority);
      add(l10n.licenseClass, license?.licenseClass);
    case CipherType.passport:
      final passport = cipher.passport;
      add(l10n.surname, passport?.surname);
      add(l10n.givenName, passport?.givenName);
      add(l10n.dateOfBirth, passport?.dateOfBirth);
      add(l10n.sex, passport?.sex);
      add(l10n.birthPlace, passport?.birthPlace);
      add(l10n.nationality, passport?.nationality);
      add(l10n.issuingCountry, passport?.issuingCountry);
      add(l10n.passportNumber, passport?.passportNumber);
      add(l10n.passportType, passport?.passportType);
      add(l10n.nationalId, passport?.nationalIdentificationNumber);
      add(l10n.issuingAuthority, passport?.issuingAuthority);
      add(l10n.issueDate, passport?.issueDate);
      add(l10n.expirationDate, passport?.expirationDate);
  }
  return rows;
}

List<FieldRow> customFields(AppLocalizations l10n, Cipher cipher) => [
  for (final field in cipher.fields)
    switch (field.type) {
      FieldType.hidden => FieldRow(
        field.name ?? '',
        field.value ?? '',
        FieldKind.password,
      ),
      FieldType.boolean => FieldRow(
        field.name ?? '',
        field.value == 'true' ? l10n.yes : l10n.no,
        FieldKind.info,
      ),
      FieldType.linked => FieldRow(
        field.name ?? '',
        l10n.linkedTo(linkedFieldLabel(l10n, field.linkedId) ?? '?'),
        FieldKind.info,
      ),
      _ => FieldRow(field.name ?? '', field.value ?? ''),
    },
];

/// How Bitwarden's card [brand] shows.
String cardBrandLabel(AppLocalizations l10n, String brand) => switch (brand) {
  'Amex' => 'American Express',
  'Other' => l10n.cardBrandOther,
  _ => brand,
};

String? _expiration(String? month, String? year) {
  final paddedMonth = month == null || month.isEmpty
      ? null
      : month.padLeft(2, '0');
  return _join([paddedMonth, year], ' / ');
}

String _accountType(
  AppLocalizations l10n,
  BankAccountType type,
) => switch (type) {
  BankAccountType.checking => l10n.accountTypeChecking,
  BankAccountType.savings => l10n.accountTypeSavings,
  BankAccountType.certificateOfDeposit => l10n.accountTypeCertificateOfDeposit,
  BankAccountType.lineOfCredit => l10n.accountTypeLineOfCredit,
  BankAccountType.investmentBrokerage => l10n.accountTypeInvestmentBrokerage,
  BankAccountType.moneyMarket => l10n.accountTypeMoneyMarket,
  _ => l10n.accountTypeOther,
};

String? linkedFieldLabel(AppLocalizations l10n, LinkedIdType? id) =>
    switch (id) {
      LinkedIdType.loginUsername => l10n.username,
      LinkedIdType.loginPassword => l10n.password,
      LinkedIdType.cardCardholderName => l10n.cardholderName,
      LinkedIdType.cardExpMonth => l10n.cardExpMonth,
      LinkedIdType.cardExpYear => l10n.cardExpYear,
      LinkedIdType.cardCode => l10n.cardCode,
      LinkedIdType.cardBrand => l10n.cardBrand,
      LinkedIdType.cardNumber => l10n.cardNumber,
      LinkedIdType.identityTitle => l10n.identityTitle,
      LinkedIdType.identityMiddleName => l10n.middleName,
      LinkedIdType.identityAddress1 ||
      LinkedIdType.identityAddress2 ||
      LinkedIdType.identityAddress3 => l10n.address,
      LinkedIdType.identityCity => l10n.city,
      LinkedIdType.identityState => l10n.state,
      LinkedIdType.identityPostalCode => l10n.postalCode,
      LinkedIdType.identityCountry => l10n.country,
      LinkedIdType.identityCompany => l10n.company,
      LinkedIdType.identityEmail => l10n.email,
      LinkedIdType.identityPhone => l10n.phone,
      LinkedIdType.identitySsn => l10n.ssn,
      LinkedIdType.identityUsername => l10n.username,
      LinkedIdType.identityPassportNumber => l10n.passportNumber,
      LinkedIdType.identityLicenseNumber => l10n.licenseNumber,
      LinkedIdType.identityFirstName => l10n.firstName,
      LinkedIdType.identityLastName => l10n.lastName,
      LinkedIdType.identityFullName => l10n.fullName,
      _ => null,
    };

String? _join(Iterable<String?> parts, String separator) {
  final present = [
    for (final part in parts)
      if (part != null && part.trim().isNotEmpty) part.trim(),
  ];
  return present.isEmpty ? null : present.join(separator);
}
