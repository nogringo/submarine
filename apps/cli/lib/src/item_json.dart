import 'package:nostr_passwords/nostr_passwords.dart';

/// An item as `bw` prints it: the cipher with the fields bw adds around it.
Map<String, dynamic> itemJson(Item item) =>
    {'object': 'item', 'id': item.id, 'organizationId': null}
      ..addAll(item.cipher.toJson())
      // An item imported from Bitwarden may still carry its old ids.
      ..['id'] = item.id
      ..['organizationId'] = null
      ..['collectionIds'] = <String>[];
