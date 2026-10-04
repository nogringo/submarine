import 'dart:math';

import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip09/deletion.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'cipher/cipher.dart';
import 'cipher/field.dart';
import 'cipher/json.dart';
import 'cipher/password_history.dart';
import 'envelope.dart';
import 'item.dart';
import 'version_event.dart';

/// A vault, local first: a change is done once it is saved in the ndk cache,
/// the local relay. ndk then sends it to [relays] in the background, unless
/// `NdkConfig.pendingDeliveryRetriesEnabled` is off, and [push] sends it now.
class Vault {
  Vault({required this.ndk, required this.signer, required this.relays});

  final Ndk ndk;
  final EventSigner signer;
  final List<String> relays;

  /// Decrypted on demand and kept in memory only: ndk's own decrypted payload
  /// cache would write the passwords to disk in clear.
  final _versions = <String, Envelope>{};

  /// Keeps the vault's gift wraps and deletion requests synced from [relays]
  /// into the ndk cache.
  ///
  /// Some relays serve gift wraps to their recipient only, so this
  /// authenticates as the vault (NIP-42): [signer] must be in `ndk.accounts`.
  SyncHandle sync(SyncEngine engine) => engine.ensure(
    SyncRequest(
      filters: [_wraps, _deletions],
      relays: relays,
      authPubkey: signer.getPublicKey(),
      // Deletion requests are backdated like gift wraps, but the engine only
      // reaches further back for a gift wrap filter.
      overlapMargin: engine.overlapMargin + _backdating,
    ),
  );

  /// When [sync] last got an answer from a relay, on any relay it ever used,
  /// or null if it never did. Reads the local state only.
  Future<DateTime?> lastSync(SyncEngine engine) async {
    DateTime? last;
    final states = await engine.coverageOfFilter(
      _wraps,
      authPubkey: signer.getPublicKey(),
    );
    for (final state in states) {
      // A pass covers up to the moment it started, while completedAt keeps
      // the oldest pass once ranges merge.
      for (final range in state.coverage) {
        if (last == null || range.to.isAfter(last)) last = range.to;
      }
    }
    return last;
  }

  Filter get _wraps => Filter(
    kinds: [GiftWrap.kGiftWrapEventkind],
    pTags: [signer.getPublicKey()],
  );

  Filter get _deletions =>
      Filter(kinds: [Deletion.kKind], authors: [signer.getPublicKey()]);

  /// Items found in the ndk cache, see [sync] to fill it. Drops from the cache
  /// the gift wraps the vault asked to delete.
  Future<List<Item>> items() async {
    final deletions = await ndk.config.cache.loadEvents(
      kinds: [Deletion.kKind],
      pubKeys: [signer.getPublicKey()],
    );
    final deleted = {for (final request in deletions) ...request.getTags('e')};
    final versions = <Envelope>[];
    final dropped = <String>[];
    for (final wrap in await _loadWraps()) {
      if (deleted.contains(wrap.id)) {
        dropped.add(wrap.id);
      } else if (await _open(wrap) case final version?) {
        versions.add(version);
      }
    }
    await _drop(dropped);
    return resolveItems(versions);
  }

  Future<Envelope> createItem(Cipher cipher) async {
    final envelope = Envelope(
      id: _randomId(),
      type: 'item',
      rev: _randomId(),
      parents: const [],
      modifiedAt: DateTime.now().toUtc(),
      data: cipher.toJson(),
    );
    await _saveVersion(envelope);
    return envelope;
  }

  /// Saves [cipher] as the new version of [item]. It replaces all the
  /// heads of [item], which resolves a conflict.
  ///
  /// As in Bitwarden, the password history is the one of [item], plus the
  /// login password and hidden fields [cipher] changes, 5 entries at most.
  Future<Envelope> updateItem(Item item, Cipher cipher) =>
      _update(item, cipher, DateTime.now().toUtc());

  /// Moves [item] to the trash, where it stays until [restoreItem] or
  /// [deleteItem].
  Future<Envelope> trashItem(Item item) {
    final now = DateTime.now().toUtc();
    return _update(
      item,
      Cipher.fromJson(item.current.data)..deletedDate = now,
      now,
    );
  }

  Future<Envelope> restoreItem(Item item) => _update(
    item,
    Cipher.fromJson(item.current.data)..deletedDate = null,
    DateTime.now().toUtc(),
  );

  /// Deletes every version of [item] for good: asks the relays to delete their
  /// gift wraps (NIP-09, NIP-59), and drops them from the cache.
  ///
  /// A version published afterwards, by a device that missed the deletion,
  /// brings the item back.
  Future<void> deleteItem(Item item) async {
    final wrapIds = [
      for (final wrap in await _loadWraps())
        if ((await _open(wrap))?.id == item.id) wrap.id,
    ];
    await Future.wait([for (final wrapId in wrapIds) _requestDeletion(wrapId)]);
    await _drop(wrapIds);
  }

  /// Sends to [relays] the changes no relay accepted yet, and returns those
  /// still left.
  Future<List<EventDeliverySnapshot>> push() async {
    await Future.wait([
      for (final delivery in await unsent()) _send(delivery.event!),
    ]);
    return unsent();
  }

  /// The changes saved in the cache that no relay accepted yet.
  Future<List<EventDeliverySnapshot>> unsent() async => [
    for (final delivery in await ndk.broadcast.loadPendingDeliveries())
      if (delivery.event case final event?
          when _isOwn(event) &&
              !delivery.relayTargets.any(
                (target) => target.state == RelayDeliveryState.acked,
              ))
        delivery,
  ];

  /// Whether [event] is one of this vault's: the cache may hold other vaults.
  bool _isOwn(Nip01Event event) => switch (event.kind) {
    GiftWrap.kGiftWrapEventkind => event.pTags.contains(signer.getPublicKey()),
    Deletion.kKind => event.pubKey == signer.getPublicKey(),
    _ => false,
  };

  Future<Envelope> _update(Item item, Cipher cipher, DateTime now) async {
    // item.cipher may be the very object the caller edited.
    final history = _passwordHistory(
      Cipher.fromJson(item.current.data),
      cipher,
      now,
    );
    final envelope = Envelope(
      id: item.id,
      type: 'item',
      rev: _randomId(),
      parents: [for (final head in item.heads) head.rev],
      modifiedAt: now,
      data: {
        ...cipher.toJson(),
        'passwordHistory': [for (final entry in history) entry.toJson()],
        'revisionDate': formatDate(now),
      },
    );
    await _saveVersion(envelope);
    return envelope;
  }

  Future<List<Nip01Event>> _loadWraps() => ndk.config.cache.loadEvents(
    kinds: [GiftWrap.kGiftWrapEventkind],
    tags: {
      'p': [signer.getPublicKey()],
    },
  );

  Future<void> _drop(List<String> wrapIds) async {
    if (wrapIds.isEmpty) return;
    await ndk.config.cache.removeEvents(ids: wrapIds);
    wrapIds.forEach(_versions.remove);
  }

  Future<Envelope?> _open(Nip01Event wrap) async {
    if (_versions[wrap.id] case final version?) return version;
    try {
      return _versions[wrap.id] = await unwrapEnvelope(
        wrap,
        signer,
        verifier: ndk.config.eventVerifier,
      );
    } catch (_) {
      // Anyone can send a wrap to the vault: one that does not open is skipped.
      return null;
    }
  }

  Future<void> _saveVersion(Envelope envelope) async {
    await _save(await wrapEnvelope(envelope, signer));
  }

  Future<void> _requestDeletion(String wrapId) async {
    final request = await signer.sign(
      Nip01Event(
        pubKey: signer.getPublicKey(),
        kind: Deletion.kKind,
        tags: [
          ['e', wrapId],
          ['k', '${GiftWrap.kGiftWrapEventkind}'],
        ],
        content: '',
        // Random and one per gift wrap, so that requests do not tie the
        // versions of an item together.
        createdAt: _randomPastTime(),
      ),
    );
    await _save(request);
  }

  Future<void> _save(Nip01Event event) async {
    await ndk.config.cache.saveEvent(event);
    // A zero timeout enrolls the event in ndk's pending delivery without
    // waiting for the relays.
    await _send(event, timeout: Duration.zero);
  }

  Future<void> _send(Nip01Event event, {Duration? timeout}) async {
    await ndk.broadcast
        .broadcast(
          nostrEvent: event,
          specificRelays: relays,
          timeout: timeout,
          saveToCache: false,
          // Without it, a relay asking for AUTH would see the logged account.
          auth: AuthPolicy.allow(
            Account(
              type: AccountType.externalSigner,
              pubkey: signer.getPublicKey(),
              signer: signer,
            ),
          ),
        )
        .broadcastDoneFuture;
  }
}

/// Bitwarden's CipherService.updateModelfromExistingCipher, then
/// adjustPasswordHistoryLength.
List<PasswordHistory> _passwordHistory(
  Cipher previous,
  Cipher next,
  DateTime now,
) {
  final history = [...previous.passwordHistory];
  final password = previous.login?.password;
  if (previous.type == CipherType.login &&
      next.type == CipherType.login &&
      password != null &&
      password.isNotEmpty &&
      password != next.login?.password) {
    history.insert(0, PasswordHistory(password: password, lastUsedDate: now));
  }
  for (final Field(:type, :name, :value) in previous.fields) {
    if (type != FieldType.hidden ||
        name == null ||
        name.isEmpty ||
        value == null ||
        value.isEmpty) {
      continue;
    }
    final match = next.fields
        .where((field) => field.type == FieldType.hidden && field.name == name)
        .firstOrNull;
    if (match?.value != value) {
      history.insert(
        0,
        PasswordHistory(password: '$name: $value', lastUsedDate: now),
      );
    }
  }
  return history.take(5).toList();
}

final _random = Random.secure();

/// How far back NIP-59 sets the `created_at` of a gift wrap, and Submarine the
/// one of a deletion request.
const _backdating = Duration(days: 2);

int _randomPastTime() =>
    DateTime.now().millisecondsSinceEpoch ~/ 1000 -
    _random.nextInt(_backdating.inSeconds);

String _randomId() => [
  for (var i = 0; i < 16; i++)
    _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();
