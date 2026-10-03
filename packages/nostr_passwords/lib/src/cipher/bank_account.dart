import 'json.dart';

extension type const BankAccountType(String value) {
  static const checking = BankAccountType('checking');
  static const savings = BankAccountType('savings');
  static const certificateOfDeposit = BankAccountType('certificateOfDeposit');
  static const lineOfCredit = BankAccountType('lineOfCredit');
  static const investmentBrokerage = BankAccountType('investmentBrokerage');
  static const moneyMarket = BankAccountType('moneyMarket');
  static const other = BankAccountType('other');
}

class BankAccount {
  BankAccount({
    this.bankName,
    this.nameOnAccount,
    this.accountType,
    this.accountNumber,
    this.routingNumber,
    this.branchNumber,
    this.pin,
    this.swiftCode,
    this.iban,
    this.bankContactPhone,
  }) : _source = const {};

  BankAccount.fromJson(Map<String, dynamic> json)
    : bankName = json['bankName'],
      nameOnAccount = json['nameOnAccount'],
      accountType = json['accountType'] == null
          ? null
          : BankAccountType(json['accountType']),
      accountNumber = json['accountNumber'],
      routingNumber = json['routingNumber'],
      branchNumber = json['branchNumber'],
      pin = json['pin'],
      swiftCode = json['swiftCode'],
      iban = json['iban'],
      bankContactPhone = json['bankContactPhone'],
      _source = json;

  String? bankName;
  String? nameOnAccount;
  BankAccountType? accountType;
  String? accountNumber;
  String? routingNumber;
  String? branchNumber;
  String? pin;
  String? swiftCode;
  String? iban;
  String? bankContactPhone;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'bankName': bankName,
    'nameOnAccount': nameOnAccount,
    'accountType': accountType?.value,
    'accountNumber': accountNumber,
    'routingNumber': routingNumber,
    'branchNumber': branchNumber,
    'pin': pin,
    'swiftCode': swiftCode,
    'iban': iban,
    'bankContactPhone': bankContactPhone,
  });
}
