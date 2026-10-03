import 'package:ndk_sqlite3/ndk_sqlite3.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:submarine_cli/src/sqlite_sync_store.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';
import 'package:test/test.dart';

const fingerprint = 'a1b2c3d4e5f60718';
const alice =
    '56e8c688aabb49e9bb68f9d8d6722c809366ad1ad959042db45970cc63152d75';
const relay = 'wss://relay.example.com';
const otherRelay = 'wss://other.example.com';

final january = DateTime.utc(2026, 1, 1);
final march = DateTime.utc(2026, 3, 31, 23, 59, 59);
final april = DateTime.utc(2026, 4, 1, 10, 30);

void main() {
  late Database db;
  late SyncStore store;

  setUp(() {
    db = sqlite3.openInMemory();
    store = SqliteSyncStore(db);
  });

  tearDown(() => db.close());

  group('sync state', () {
    test('round trips', () async {
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          authPubkey: alice,
          coverage: [
            CoverageRange(from: january, to: march, completedAt: april),
          ],
          lastAttemptAt: april,
        ),
      );

      final read = await store.readSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
        authPubkey: alice,
      );

      expect(read!.relayUrl, relay);
      expect(read.filterFingerprint, fingerprint);
      expect(read.authPubkey, alice);
      expect(read.lastAttemptAt, april);
      expect(read.lastAttemptAt!.isUtc, isTrue);
      expect(read.coverage, [
        CoverageRange(from: january, to: march, completedAt: april),
      ]);
    });

    test('round trips a state without auth nor attempt', () async {
      await store.writeSyncState(
        RelayFilterSyncState(relayUrl: relay, filterFingerprint: fingerprint),
      );

      final read = await store.readSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
      );

      expect(read!.authPubkey, isNull);
      expect(read.lastAttemptAt, isNull);
      expect(read.coverage, isEmpty);
    });

    test('returns null when nothing was written', () async {
      final read = await store.readSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
      );

      expect(read, isNull);
    });

    test('keeps authenticated and anonymous states apart', () async {
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          authPubkey: alice,
          lastAttemptAt: april,
        ),
      );

      final anonymous = await store.readSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
      );

      expect(anonymous, isNull);
    });

    test('keeps filters apart', () async {
      await store.writeSyncState(
        RelayFilterSyncState(relayUrl: relay, filterFingerprint: fingerprint),
      );

      final other = await store.readSyncState(
        relayUrl: relay,
        filterFingerprint: '0000000000000000',
      );

      expect(other, isNull);
    });

    test('overwrites the previous state of the same key', () async {
      await store.writeSyncState(
        RelayFilterSyncState(relayUrl: relay, filterFingerprint: fingerprint),
      );
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          coverage: [
            CoverageRange(from: january, to: march, completedAt: april),
          ],
        ),
      );

      final read = await store.readSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
      );

      expect(read!.coverage, hasLength(1));
      expect(
        await store.readSyncStates(filterFingerprint: fingerprint),
        hasLength(1),
      );
    });
  });

  group('delete sync state', () {
    test('forgets one state and leaves the others', () async {
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          authPubkey: alice,
        ),
      );
      await store.writeSyncState(
        RelayFilterSyncState(relayUrl: relay, filterFingerprint: fingerprint),
      );

      await store.deleteSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
        authPubkey: alice,
      );

      expect(
        await store.readSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          authPubkey: alice,
        ),
        isNull,
      );
      expect(
        await store.readSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
        ),
        isNotNull,
      );
    });

    test('is safe when nothing was written', () async {
      await store.deleteSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
      );
    });
  });

  group('states of a filter', () {
    Future<void> writeStates() async {
      await store.writeSyncState(
        RelayFilterSyncState(relayUrl: relay, filterFingerprint: fingerprint),
      );
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: otherRelay,
          filterFingerprint: fingerprint,
        ),
      );
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          authPubkey: alice,
        ),
      );
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: relay,
          filterFingerprint: '0000000000000000',
        ),
      );
    }

    test('reads every relay of one filter, under one identity', () async {
      await writeStates();

      final read = await store.readSyncStates(filterFingerprint: fingerprint);

      expect(read.map((state) => state.relayUrl), [otherRelay, relay]);
      expect(read.every((state) => state.authPubkey == null), isTrue);
    });

    test('reads the states of an identity', () async {
      await writeStates();

      final read = await store.readSyncStates(
        filterFingerprint: fingerprint,
        authPubkey: alice,
      );

      expect(read, hasLength(1));
      expect(read.single.authPubkey, alice);
    });

    test('reads nothing when the filter was never synced', () async {
      await writeStates();

      expect(
        await store.readSyncStates(filterFingerprint: '1111111111111111'),
        isEmpty,
      );
    });

    test('deletes every relay of one filter, under one identity', () async {
      await writeStates();

      await store.deleteSyncStates(filterFingerprint: fingerprint);

      expect(
        await store.readSyncStates(filterFingerprint: fingerprint),
        isEmpty,
      );
      expect(
        await store.readSyncStates(
          filterFingerprint: fingerprint,
          authPubkey: alice,
        ),
        hasLength(1),
      );
      expect(
        await store.readSyncStates(filterFingerprint: '0000000000000000'),
        hasLength(1),
      );
    });

    test('is safe when nothing was written', () async {
      await store.deleteSyncStates(filterFingerprint: fingerprint);
    });
  });

  group('clear', () {
    test('forgets every state', () async {
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          authPubkey: alice,
          coverage: [
            CoverageRange(from: january, to: march, completedAt: april),
          ],
        ),
      );
      await store.writeSyncState(
        RelayFilterSyncState(
          relayUrl: otherRelay,
          filterFingerprint: fingerprint,
        ),
      );

      await store.clear();

      expect(
        await store.readSyncState(
          relayUrl: relay,
          filterFingerprint: fingerprint,
          authPubkey: alice,
        ),
        isNull,
      );
      expect(
        await store.readSyncStates(filterFingerprint: fingerprint),
        isEmpty,
      );
    });

    test('is safe on an empty store', () async {
      await store.clear();
      await store.clear();

      expect(
        await store.readSyncStates(filterFingerprint: fingerprint),
        isEmpty,
      );
    });
  });

  test('shares its database with the ndk cache', () async {
    await store.writeSyncState(
      RelayFilterSyncState(relayUrl: relay, filterFingerprint: fingerprint),
    );

    SqliteCacheManager(db);
    final reopened = SqliteSyncStore(db);

    expect(
      await reopened.readSyncState(
        relayUrl: relay,
        filterFingerprint: fingerprint,
      ),
      isNotNull,
    );
  });
}
