import 'json.dart';

class Passport {
  Passport({
    this.surname,
    this.givenName,
    this.dateOfBirth,
    this.sex,
    this.birthPlace,
    this.nationality,
    this.issuingCountry,
    this.passportNumber,
    this.passportType,
    this.nationalIdentificationNumber,
    this.issuingAuthority,
    this.issueDate,
    this.expirationDate,
  }) : _source = const {};

  Passport.fromJson(Map<String, dynamic> json)
    : surname = json['surname'],
      givenName = json['givenName'],
      dateOfBirth = json['dateOfBirth'],
      sex = json['sex'],
      birthPlace = json['birthPlace'],
      nationality = json['nationality'],
      issuingCountry = json['issuingCountry'],
      passportNumber = json['passportNumber'],
      passportType = json['passportType'],
      nationalIdentificationNumber = json['nationalIdentificationNumber'],
      issuingAuthority = json['issuingAuthority'],
      issueDate = json['issueDate'],
      expirationDate = json['expirationDate'],
      _source = json;

  String? surname;
  String? givenName;
  String? dateOfBirth;
  String? sex;
  String? birthPlace;
  String? nationality;
  String? issuingCountry;
  String? passportNumber;
  String? passportType;
  String? nationalIdentificationNumber;
  String? issuingAuthority;
  String? issueDate;
  String? expirationDate;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'surname': surname,
    'givenName': givenName,
    'dateOfBirth': dateOfBirth,
    'sex': sex,
    'birthPlace': birthPlace,
    'nationality': nationality,
    'issuingCountry': issuingCountry,
    'passportNumber': passportNumber,
    'passportType': passportType,
    'nationalIdentificationNumber': nationalIdentificationNumber,
    'issuingAuthority': issuingAuthority,
    'issueDate': issueDate,
    'expirationDate': expirationDate,
  });
}
