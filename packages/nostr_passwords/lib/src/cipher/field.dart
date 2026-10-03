import 'json.dart';

extension type const FieldType(int value) {
  static const text = FieldType(0);
  static const hidden = FieldType(1);
  static const boolean = FieldType(2);
  static const linked = FieldType(3);
}

extension type const LinkedIdType(int value) {
  static const loginUsername = LinkedIdType(100);
  static const loginPassword = LinkedIdType(101);
  static const cardCardholderName = LinkedIdType(300);
  static const cardExpMonth = LinkedIdType(301);
  static const cardExpYear = LinkedIdType(302);
  static const cardCode = LinkedIdType(303);
  static const cardBrand = LinkedIdType(304);
  static const cardNumber = LinkedIdType(305);
  static const identityTitle = LinkedIdType(400);
  static const identityMiddleName = LinkedIdType(401);
  static const identityAddress1 = LinkedIdType(402);
  static const identityAddress2 = LinkedIdType(403);
  static const identityAddress3 = LinkedIdType(404);
  static const identityCity = LinkedIdType(405);
  static const identityState = LinkedIdType(406);
  static const identityPostalCode = LinkedIdType(407);
  static const identityCountry = LinkedIdType(408);
  static const identityCompany = LinkedIdType(409);
  static const identityEmail = LinkedIdType(410);
  static const identityPhone = LinkedIdType(411);
  static const identitySsn = LinkedIdType(412);
  static const identityUsername = LinkedIdType(413);
  static const identityPassportNumber = LinkedIdType(414);
  static const identityLicenseNumber = LinkedIdType(415);
  static const identityFirstName = LinkedIdType(416);
  static const identityLastName = LinkedIdType(417);
  static const identityFullName = LinkedIdType(418);
}

class Field {
  Field({this.name, this.value, this.type = FieldType.text, this.linkedId})
    : _source = const {};

  Field.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      value = json['value'],
      type = FieldType(json['type'] ?? 0),
      linkedId = json['linkedId'] == null
          ? null
          : LinkedIdType(json['linkedId']),
      _source = json;

  String? name;
  String? value;
  FieldType type;
  LinkedIdType? linkedId;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'name': name,
    'value': value,
    'type': type.value,
    'linkedId': linkedId?.value,
  });
}
