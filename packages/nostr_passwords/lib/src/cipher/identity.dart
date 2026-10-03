import 'json.dart';

class Identity {
  Identity({
    this.title,
    this.firstName,
    this.middleName,
    this.lastName,
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.company,
    this.email,
    this.phone,
    this.ssn,
    this.username,
    this.passportNumber,
    this.licenseNumber,
  }) : _source = const {};

  Identity.fromJson(Map<String, dynamic> json)
    : title = json['title'],
      firstName = json['firstName'],
      middleName = json['middleName'],
      lastName = json['lastName'],
      address1 = json['address1'],
      address2 = json['address2'],
      address3 = json['address3'],
      city = json['city'],
      state = json['state'],
      postalCode = json['postalCode'],
      country = json['country'],
      company = json['company'],
      email = json['email'],
      phone = json['phone'],
      ssn = json['ssn'],
      username = json['username'],
      passportNumber = json['passportNumber'],
      licenseNumber = json['licenseNumber'],
      _source = json;

  String? title;
  String? firstName;
  String? middleName;
  String? lastName;
  String? address1;
  String? address2;
  String? address3;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? company;
  String? email;
  String? phone;
  String? ssn;
  String? username;
  String? passportNumber;
  String? licenseNumber;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'title': title,
    'firstName': firstName,
    'middleName': middleName,
    'lastName': lastName,
    'address1': address1,
    'address2': address2,
    'address3': address3,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'company': company,
    'email': email,
    'phone': phone,
    'ssn': ssn,
    'username': username,
    'passportNumber': passportNumber,
    'licenseNumber': licenseNumber,
  });
}
