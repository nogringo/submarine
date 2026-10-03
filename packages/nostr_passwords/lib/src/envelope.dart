class Envelope {
  const Envelope({
    this.v = 1,
    required this.id,
    required this.type,
    required this.rev,
    required this.parents,
    required this.modifiedAt,
    required this.data,
  });

  factory Envelope.fromJson(Map<String, dynamic> json) => Envelope(
    v: json['v'] as int,
    id: json['id'] as String,
    type: json['type'] as String,
    rev: json['rev'] as String,
    parents: (json['parents'] as List).cast<String>(),
    modifiedAt: DateTime.fromMillisecondsSinceEpoch(
      json['modified_at'] as int,
      isUtc: true,
    ),
    data: json['data'] as Map<String, dynamic>,
  );

  final int v;
  final String id;
  final String type;
  final String rev;
  final List<String> parents;
  final DateTime modifiedAt;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() => {
    'v': v,
    'id': id,
    'type': type,
    'rev': rev,
    'parents': parents,
    'modified_at': modifiedAt.millisecondsSinceEpoch,
    'data': data,
  };
}
