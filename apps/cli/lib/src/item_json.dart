import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';

const _itemOnlyKeys = {'object', 'id', 'organizationId', 'collectionIds'};

/// An item as `bw` prints it: the cipher with the fields bw adds around it.
Map<String, dynamic> itemJson(Item item) =>
    {'object': 'item', 'id': item.id, 'organizationId': null}
      ..addAll(item.cipher.toJson())
      // An item imported from Bitwarden may still carry its old ids.
      ..['id'] = item.id
      ..['organizationId'] = null
      ..['collectionIds'] = <String>[];

/// The cipher in an item JSON encoded as `bw encode` does, without the fields
/// [itemJson] adds. Throws a [FormatException] when [encoded] is not one.
Cipher decodeItemJson(String encoded) {
  // Like Node's decoder behind bw, which skips line breaks.
  final bytes = base64.decode(
    base64.normalize(encoded.replaceAll(RegExp(r'\s'), '')),
  );
  final json = jsonDecode(utf8.decode(bytes, allowMalformed: true));
  if (json is! Map<String, dynamic>) {
    throw const FormatException('Not a JSON object.');
  }
  try {
    return Cipher.fromJson({
      for (final MapEntry(:key, :value) in json.entries)
        if (!_itemOnlyKeys.contains(key)) key: value,
    });
  } on TypeError {
    throw const FormatException('Not an item.');
  }
}
