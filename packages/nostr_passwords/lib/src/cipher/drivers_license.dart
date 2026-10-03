import 'json.dart';

class DriversLicense {
  DriversLicense({
    this.firstName,
    this.middleName,
    this.lastName,
    this.dateOfBirth,
    this.licenseNumber,
    this.issuingCountry,
    this.issuingState,
    this.issueDate,
    this.expirationDate,
    this.issuingAuthority,
    this.licenseClass,
  }) : _source = const {};

  DriversLicense.fromJson(Map<String, dynamic> json)
    : firstName = json['firstName'],
      middleName = json['middleName'],
      lastName = json['lastName'],
      dateOfBirth = json['dateOfBirth'],
      licenseNumber = json['licenseNumber'],
      issuingCountry = json['issuingCountry'],
      issuingState = json['issuingState'],
      issueDate = json['issueDate'],
      expirationDate = json['expirationDate'],
      issuingAuthority = json['issuingAuthority'],
      licenseClass = json['licenseClass'],
      _source = json;

  String? firstName;
  String? middleName;
  String? lastName;
  String? dateOfBirth;
  String? licenseNumber;
  String? issuingCountry;
  String? issuingState;
  String? issueDate;
  String? expirationDate;
  String? issuingAuthority;
  String? licenseClass;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'dateOfBirth': dateOfBirth,
    'licenseNumber': licenseNumber,
    'issuingCountry': issuingCountry,
    'issuingState': issuingState,
    'issueDate': issueDate,
    'expirationDate': expirationDate,
    'issuingAuthority': issuingAuthority,
    'licenseClass': licenseClass,
  });
}
