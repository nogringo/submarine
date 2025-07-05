class OTPValue {
  final String type; // 'totp' or 'hotp'
  final String secret;
  final String algorithm; // 'SHA1', 'SHA256', 'SHA512'
  final int digits;
  final int period;
  final int counter;

  OTPValue({
    required this.type,
    required this.secret,
    required this.algorithm,
    required this.digits,
    required this.period,
    this.counter = 0,
  });

  factory OTPValue.fromJson(Map<String, dynamic> json) {
    return OTPValue(
      type: json['type'],
      secret: json['secret'],
      algorithm: json['algorithm'],
      digits: json['digits'],
      period: json['period'],
      counter: json['counter'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'secret': secret,
      'algorithm': algorithm,
      'digits': digits,
      'period': period,
      'counter': counter,
    };
  }
}