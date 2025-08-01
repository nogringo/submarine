class DecryptedSecretEvent {
  final String eventId;
  final int createdAt;
  final Map<String, dynamic> secret;

  DecryptedSecretEvent({
    required this.eventId,
    required this.createdAt,
    required this.secret,
  });

  Map<String, dynamic> toJson() {
    return {'eventId': eventId, 'createdAt': createdAt, 'secret': secret};
  }

  factory DecryptedSecretEvent.fromJson(Map<String, dynamic> json) {
    return DecryptedSecretEvent(
      eventId: json['eventId'] as String,
      createdAt: json['createdAt'] as int,
      secret: json['secret'] as Map<String, dynamic>,
    );
  }
}
