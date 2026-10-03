import 'json.dart';

class PaymentCard {
  PaymentCard({
    this.cardholderName,
    this.brand,
    this.number,
    this.expMonth,
    this.expYear,
    this.code,
  }) : _source = const {};

  PaymentCard.fromJson(Map<String, dynamic> json)
    : cardholderName = json['cardholderName'],
      brand = json['brand'],
      number = json['number'],
      expMonth = json['expMonth'],
      expYear = json['expYear'],
      code = json['code'],
      _source = json;

  String? cardholderName;
  String? brand;
  String? number;
  String? expMonth;
  String? expYear;
  String? code;
  final Map<String, dynamic> _source;

  Map<String, dynamic> toJson() => mergeJson(_source, {
    'cardholderName': cardholderName,
    'brand': brand,
    'number': number,
    'expMonth': expMonth,
    'expYear': expYear,
    'code': code,
  });
}
