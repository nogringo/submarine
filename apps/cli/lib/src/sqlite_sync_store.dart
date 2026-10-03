import 'dart:convert';

import 'package:sqlite3/sqlite3.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

/// [SyncStore] on a sqlite3 database it shares, so it never closes it.
/// Timestamps are stored as epoch milliseconds.
class SqliteSyncStore implements SyncStore {
  SqliteSyncStore(this.db) {
    // No PRAGMA user_version: ndk_sqlite3 tracks its own schema with it.
    db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        filter_fingerprint TEXT NOT NULL,
        auth_pubkey TEXT NOT NULL,
        relay_url TEXT NOT NULL,
        coverage TEXT NOT NULL,
        last_attempt_at INTEGER,
        PRIMARY KEY (filter_fingerprint, auth_pubkey, relay_url)
      ) WITHOUT ROWID
    ''');
  }

  static const _table = 'relay_filter_sync_states';

  final Database db;

  @override
  Future<RelayFilterSyncState?> readSyncState({
    required String relayUrl,
    required String filterFingerprint,
    String? authPubkey,
  }) async {
    final rows = db.select(
      'SELECT * FROM $_table '
      'WHERE filter_fingerprint = ? AND auth_pubkey = ? AND relay_url = ?',
      [filterFingerprint, _authKey(authPubkey), relayUrl],
    );
    return rows.isEmpty ? null : _syncStateFrom(rows.single);
  }

  @override
  Future<List<RelayFilterSyncState>> readSyncStates({
    required String filterFingerprint,
    String? authPubkey,
  }) async => [
    for (final row in db.select(
      'SELECT * FROM $_table '
      'WHERE filter_fingerprint = ? AND auth_pubkey = ? ORDER BY relay_url',
      [filterFingerprint, _authKey(authPubkey)],
    ))
      _syncStateFrom(row),
  ];

  @override
  Future<void> writeSyncState(RelayFilterSyncState state) async {
    db.execute(
      'INSERT OR REPLACE INTO $_table (filter_fingerprint, auth_pubkey, '
      'relay_url, coverage, last_attempt_at) VALUES (?, ?, ?, ?, ?)',
      [
        state.filterFingerprint,
        _authKey(state.authPubkey),
        state.relayUrl,
        jsonEncode([
          for (final range in state.coverage)
            {
              'from': range.from.millisecondsSinceEpoch,
              'to': range.to.millisecondsSinceEpoch,
              'completedAt': range.completedAt.millisecondsSinceEpoch,
            },
        ]),
        state.lastAttemptAt?.millisecondsSinceEpoch,
      ],
    );
  }

  @override
  Future<void> deleteSyncState({
    required String relayUrl,
    required String filterFingerprint,
    String? authPubkey,
  }) async {
    db.execute(
      'DELETE FROM $_table '
      'WHERE filter_fingerprint = ? AND auth_pubkey = ? AND relay_url = ?',
      [filterFingerprint, _authKey(authPubkey), relayUrl],
    );
  }

  @override
  Future<void> deleteSyncStates({
    required String filterFingerprint,
    String? authPubkey,
  }) async {
    db.execute(
      'DELETE FROM $_table WHERE filter_fingerprint = ? AND auth_pubkey = ?',
      [filterFingerprint, _authKey(authPubkey)],
    );
  }

  @override
  Future<void> clear() async {
    db.execute('DELETE FROM $_table');
  }

  /// Anonymous is stored as '', since SQLite never finds two NULL keys equal.
  String _authKey(String? authPubkey) => authPubkey ?? '';

  RelayFilterSyncState _syncStateFrom(Row row) {
    final authPubkey = row['auth_pubkey'] as String;
    final lastAttemptAt = row['last_attempt_at'] as int?;
    return RelayFilterSyncState(
      relayUrl: row['relay_url'] as String,
      filterFingerprint: row['filter_fingerprint'] as String,
      authPubkey: authPubkey.isEmpty ? null : authPubkey,
      coverage: [
        for (final range in jsonDecode(row['coverage'] as String) as List)
          _rangeFrom(range as Map<String, Object?>),
      ],
      lastAttemptAt: lastAttemptAt == null ? null : _utc(lastAttemptAt),
    );
  }

  CoverageRange _rangeFrom(Map<String, Object?> range) => CoverageRange(
    from: _utc(range['from'] as int),
    to: _utc(range['to'] as int),
    completedAt: _utc(range['completedAt'] as int),
  );

  DateTime _utc(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
}
