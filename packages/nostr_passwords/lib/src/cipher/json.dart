/// Overlays a model's [fields] on the JSON it was parsed from, so keys it does
/// not model survive. A null is only written when [source] had the key.
Map<String, dynamic> mergeJson(
  Map<String, dynamic> source,
  Map<String, dynamic> fields,
) => {
  ...source,
  for (final MapEntry(:key, :value) in fields.entries)
    if (value != null || source.containsKey(key)) key: value,
};

DateTime? parseDate(Object? json) =>
    json == null ? null : DateTime.parse(json as String);

String? formatDate(DateTime? date) => date?.toUtc().toIso8601String();

T? parseObject<T>(
  Object? json,
  T Function(Map<String, dynamic> json) fromJson,
) => json == null ? null : fromJson(json as Map<String, dynamic>);

List<T> parseList<T>(
  Object? json,
  T Function(Map<String, dynamic> json) fromJson,
) => [
  for (final item in (json as List?) ?? const [])
    fromJson(item as Map<String, dynamic>),
];
