import 'dart:convert';
import 'dart:io';

import 'package:nostr_passwords/nostr_passwords.dart';

import 'cli_exception.dart';
import 'terminal.dart';

const _itemOnlyKeys = {'object', 'id', 'organizationId', 'collectionIds'};

/// An item as `bw` prints it: the cipher with the fields bw adds around it.
Map<String, dynamic> itemJson(Item item) =>
    {'object': 'item', 'id': item.id, 'organizationId': null}
      ..addAll(item.cipher.toJson())
      // An item imported from Bitwarden may still carry its old ids.
      ..['id'] = item.id
      ..['organizationId'] = null
      ..['collectionIds'] = <String>[];

/// The cipher `create` and `edit` take: [encoded], or stdin when it is empty,
/// decoded by [decodeItemJson]. Fails with bw's messages.
Future<Cipher> readItemRequest(String encoded) async {
  if (encoded.isEmpty && !stdin.hasTerminal) encoded = await readStdin();
  if (encoded.isEmpty) throw CliException('`requestJson` was not provided.');
  try {
    return decodeItemJson(encoded);
  } on FormatException {
    throw CliException('Error parsing the encoded request data.');
  }
}

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
