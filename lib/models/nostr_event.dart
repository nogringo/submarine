import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:nostr/nostr.dart';
import 'package:submarine/models/nostr_relay.dart';

part 'nostr_event.g.dart';

@collection
class NostrEvent {
  Id docId = Isar.autoIncrement;

  String serializedEvent;
  final nostrRelays = IsarLinks<NostrRelay>();

  @ignore
  Event get event => Event.deserialize(jsonDecode(serializedEvent));
  String get id => event.id;
  String get pubkey => event.pubkey;
  int get createdAt => event.createdAt;
  int get kind => event.kind;
  @ignore
  List<List<String>> get tags => event.tags;
  String get content => event.content;
  String get sig => event.sig;

  NostrEvent(this.serializedEvent);
}
