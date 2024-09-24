import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:get/instance_manager.dart';

part 'database.g.dart';

class NostrEvent extends Table {
  TextColumn get id => text()();
  TextColumn get pubkey => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get kind => integer()();
  TextColumn get tags => text()();
  TextColumn get content => text()();
  TextColumn get sig => text()();
}

class NostrRelay extends Table {
  TextColumn get url => text()();

  @override
  Set<Column> get primaryKey => {url};
}

class RelayEventLinks extends Table {
  // Foreign key to NostrEvent, with NOT NULL constraint
  TextColumn get eventId =>
      text().customConstraint('REFERENCES nostr_event(id) NOT NULL')();

  // Foreign key to NostrRelay, with NOT NULL constraint
  TextColumn get relayUrl =>
      text().customConstraint('REFERENCES nostr_relay(url) NOT NULL')();

  // Add a unique constraint to prevent duplicate entries
  @override
  Set<Column> get primaryKey => {eventId, relayUrl};
}

@DriftDatabase(tables: [NostrEvent, NostrRelay, RelayEventLinks])
class AppDatabase extends _$AppDatabase {
  static AppDatabase get to => Get.find();

  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/getting-started/#open
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // `driftDatabase` from `package:drift_flutter` stores the database in
    // `getApplicationDocumentsDirectory()`.
    return driftDatabase(
      name: 'my_database',
      web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
          onResult: (result) {
            if (result.missingFeatures.isNotEmpty) {
              debugPrint(
                  'Using ${result.chosenImplementation} due to unsupported '
                  'browser features: ${result.missingFeatures}');
            }
          }),
    );
  }

  Future<List<NostrEventData>> getEventsForPubkey(String pubkey) {
    return (select(nostrEvent)..where((tbl) => tbl.pubkey.equals(pubkey)))
        .get();
  }

  Future<List<NostrRelayData>> getAllNostrRelays() {
    return select(nostrRelay).get();
  }

  Stream<List<NostrEventData>> watchNostrEventsByPubkey(String pubkey) {
    return (select(nostrEvent)..where((tbl) => tbl.pubkey.equals(pubkey)))
        .watch();
  }

  Stream<List<NostrRelayData>> watchRelays() {
    return select(nostrRelay).watch();
  }

  Future<NostrEventData?> findNostrEventById(String id) {
    return (select(nostrEvent)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> isEventStoredOnRelay(String eventId, String relayUrl) async {
    final relations = await (select(relayEventLinks)
          ..where((tbl) =>
              tbl.eventId.equals(eventId) & tbl.relayUrl.equals(relayUrl)))
        .get();
    return relations.isNotEmpty;
  }

  Future<void> insertNostrEvent(NostrEventData event) {
    return into(nostrEvent).insert(event);
  }

  Future<void> insertNostrRelay(NostrRelayData relay) {
    return into(nostrRelay).insert(relay);
  }

  Future<void> insertRelayEventLink(String eventId, String relayUrl) {
    final link = RelayEventLinksCompanion(
      eventId: Value(eventId),
      relayUrl: Value(relayUrl),
    );

    return into(relayEventLinks).insert(link);
  }

  Future<void> deleteNostrRelay(String url) async {
    await (delete(nostrRelay)..where((tbl) => tbl.url.equals(url))).go();
  }
}
