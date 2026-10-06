import 'dart:async';
import 'dart:math';

import 'package:ndk/domain_layer/entities/broadcast_state.dart'
    show RelayBroadcastResponse;
import 'package:ndk/domain_layer/entities/nip_65.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip09/deletion.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'cipher/cipher.dart';
import 'cipher/field.dart';
import 'cipher/json.dart';
import 'cipher/password_history.dart';
import 'envelope.dart';
import 'item.dart';
import 'relay_list.dart';
import 'version_event.dart';

/// A vault, local first: a change is done once it is saved in the ndk cache,
/// the local relay. ndk then sends it to [currentRelays] in the background,
/// unless `NdkConfig.pendingDeliveryRetriesEnabled` is off, and [push] sends it
/// now.
class Vault {
  Vault({
    required this.ndk,
    required this.signer,
    required this.relays,
    this.indexers = indexerRelays,
  });

  final Ndk ndk;
  final EventSigner signer;

  /// Where the vault lives until it has a relay list, and where its relay list
  /// always goes, for a new device to find it.
  final List<String> relays;

  /// Where [setRelayList] publishes too.
  final List<String> indexers;

  /// Decrypted on demand and kept in memory only: ndk's own decrypted payload
  /// cache would write the passwords to disk in clear.
  final _versions = <String, Envelope>{};

  /// Keeps the vault's gift wraps and deletion requests synced from
  /// [currentRelays] into the ndk cache. The relay list is left to
  /// [fetchRelayList].
  ///
  /// The handle holds the relays of the moment: once the relay list changed,
  /// call it again, and release the previous handle.
  ///
  /// Some relays serve gift wraps to their recipient only, so this
  /// authenticates as the vault (NIP-42): [signer] must be in `ndk.accounts`.
  Future<SyncHandle> sync(SyncEngine engine) async => engine.ensure(
    SyncRequest(
      filters: [_wraps, _deletions],
      relays: await currentRelays(),
      authPubkey: signer.getPublicKey(),
      // Deletion requests are backdated like gift wraps, but the engine only
      // reaches further back for a gift wrap filter.
      overlapMargin: engine.overlapMargin + _backdating,
    ),
  );

  /// Holds a subscription open on [currentRelays] for what other devices
  /// publish to the vault from now on, and saves it in the ndk cache. An event
  /// comes out of the stream once saved, for [items] to see it.
  ///
  /// Every listener shares the same subscriptions: they open with the first
  /// one, close once the last one cancels, and move to the new relays when
  /// [setRelayList] or [fetchRelayList] changes the relay list.
  ///
  /// What was published before, or while a relay was out of reach, is left to
  /// [sync]. It authenticates as the vault, like [sync].
  Stream<Nip01Event> subscribe() => _live.stream;

  late final _live = StreamController<Nip01Event>.broadcast(
    onListen: () => unawaited(_openLive()),
    onCancel: _closeLive,
  );

  var _liveRequests = <(String, StreamSubscription<Nip01Event>)>[];

  /// Tells an opening that a close or another opening came while it read the
  /// relays.
  var _liveGeneration = 0;

  Future<void> _openLive() async {
    final generation = ++_liveGeneration;
    final relays = await currentRelays();
    // Without explicit relays, ndk would ask its bootstrap relays.
    if (generation != _liveGeneration || relays.isEmpty) return;
    for (final filter in [_wraps, _deletions]) {
      final response = ndk.requests.subscription(
        // A limit holds for stored events only, while a `since` would also
        // drop the new gift wraps, which are backdated.
        filter: filter..limit = 0,
        explicitRelays: relays,
        cacheWrite: true,
        auth: AuthPolicy.require(_account),
      );
      _liveRequests.add((
        response.requestId,
        response.stream.listen(_live.add, onError: _live.addError),
      ));
    }
  }

  void _closeLive() {
    _liveGeneration++;
    final requests = _liveRequests;
    _liveRequests = [];
    for (final (requestId, listener) in requests) {
      unawaited(listener.cancel());
      unawaited(ndk.requests.closeSubscription(requestId));
    }
  }

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
    final deleted = {
      for (final request in await _loadDeletions()) ...request.getTags('e'),
    };
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

  /// The relays the vault lives on: those of its relay list in the ndk cache,
  /// or [relays] while it has none.
  Future<List<String>> currentRelays() async {
    final list = await relayList();
    final listed = {...?list?.public.keys, ...?list?.private.keys};
    return listed.isEmpty ? relays : listed.toList();
  }

  /// The vault's relay list found in the ndk cache, see [fetchRelayList] to
  /// fill it, or null if it has none.
  Future<RelayList?> relayList() async {
    if (await _loadRelayList() case final event?) {
      return readRelayList(event, signer);
    }
    return null;
  }

  /// Fetches the vault's relay list into the ndk cache, from the relays
  /// [setRelayList] publishes it to, and returns the newest one.
  ///
  /// Not part of [sync]: a replaceable event needs its newest version only,
  /// and comes from more relays than the items.
  Future<RelayList?> fetchRelayList() async {
    final known = await _loadRelayList();
    final targets = _relayListTargets(
      known == null ? null : await readRelayList(known, signer),
    );
    if (targets.isNotEmpty) {
      await ndk.requests
          .query(
            filter: Filter(
              kinds: [Nip65.kKind],
              authors: [signer.getPublicKey()],
            ),
            explicitRelays: targets,
            auth: AuthPolicy.allow(_account),
          )
          .future;
    }
    if ((await _loadRelayList())?.id != known?.id) await _followRelays();
    return relayList();
  }

  /// Saves [list] as the vault's relay list, in place of the previous one.
  ///
  /// A relay list goes as wide as it can (NIP-65): to [relays], to the relays
  /// it lists and to [indexers]. The relays it adds get a copy of the vault's
  /// gift wraps and deletion requests, which they do not hold yet.
  Future<void> setRelayList(RelayList list) async {
    final previous = await _loadRelayList();
    final before = await currentRelays();
    await _save(
      await signRelayList(
        list,
        signer,
        // Of two lists made in the same second, relays keep the lowest id.
        createdAt: max(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          (previous?.createdAt ?? 0) + 1,
        ),
      ),
    );
    await _copyTo([
      for (final relay in await currentRelays())
        if (!before.contains(relay)) relay,
    ]);
    await _followRelays();
  }

  /// Brings the ndk cache and every relay of [currentRelays] to the same gift
  /// wraps and deletion requests, each one getting what it lacks, once
  /// [fetchRelayList] fetched the newest relay list. That list then goes to
  /// all the relays [setRelayList] publishes it to.
  ///
  /// Nothing is sent before every relay answered: what a relay lacks is only
  /// known from what all the others hold, and a deletion request on a slow
  /// relay must keep the gift wrap it deletes from spreading.
  ///
  /// Returns the relays left out of sync, with why. A relay that did not give
  /// all it holds gets nothing, as what it lacks is unknown.
  Future<Map<String, String>> reconcile() async {
    await fetchRelayList();
    final held = <String, Set<String>>{};
    final unsynced = <String, String>{};
    Future<void> fetch(String relay) async {
      try {
        held[relay] = {
          for (final filter in [_wraps, _deletions])
            ...await _fetchAll(relay, filter),
        };
      } on _LeftOut catch (leftOut) {
        unsynced[relay] = leftOut.reason;
      }
    }

    await Future.wait([
      for (final relay in await currentRelays()) fetch(relay),
    ]);
    List<String> lacking(Nip01Event event) => [
      for (final MapEntry(key: relay, value: ids) in held.entries)
        if (!ids.contains(event.id)) relay,
    ];
    // ndk merges the broadcasts of an event, so each one goes out once.
    final sent = await Future.wait([
      for (final event in await _shareable())
        if (lacking(event) case final to when to.isNotEmpty)
          _send(event, to: to),
      if (await _loadRelayList() case final relayList?) _send(relayList),
    ]);
    final refusals = <String, List<String>>{};
    for (final response in sent.expand((responses) => responses)) {
      if (!response.broadcastSuccessful) {
        (refusals[response.relayUrl] ??= []).add(
          response.msg.isEmpty ? 'no answer' : response.msg,
        );
      }
    }
    for (final MapEntry(key: relay, value: reasons) in refusals.entries) {
      unsynced[relay] ??=
          'refused ${reasons.length} event${reasons.length == 1 ? '' : 's'}: '
          '${reasons.first}';
    }
    return unsynced;
  }

  /// Sends again the changes no relay accepted yet, and returns those still
  /// left.
  Future<List<EventDeliverySnapshot>> push() async {
    // TODO: also resend to the relays not acked yet (but not permanentFailure):
    // without ndk retries (CLI), a partial delivery or _copyTo never completes.
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
    Deletion.kKind || Nip65.kKind => event.pubKey == signer.getPublicKey(),
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

  Future<List<Nip01Event>> _loadDeletions() => ndk.config.cache.loadEvents(
    kinds: [Deletion.kKind],
    pubKeys: [signer.getPublicKey()],
  );

  /// loadEvents returns the newest version of a replaceable event only.
  Future<Nip01Event?> _loadRelayList() async =>
      (await ndk.config.cache.loadEvents(
        kinds: [Nip65.kKind],
        pubKeys: [signer.getPublicKey()],
      )).firstOrNull;

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
    await _save(
      await wrapEnvelope(
        envelope,
        signer,
        signerFactory: ndk.config.eventSignerFactory,
      ),
    );
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

  /// The vault's events in the cache that belong on its relays: the deletion
  /// requests, and the gift wraps they spare that open, as anyone can send one
  /// to the vault.
  Future<List<Nip01Event>> _shareable() async {
    final deletions = await _loadDeletions();
    final deleted = {for (final request in deletions) ...request.getTags('e')};
    return [
      for (final wrap in await _loadWraps())
        if (!deleted.contains(wrap.id) && await _open(wrap) != null) wrap,
      ...deletions,
    ];
  }

  Future<void> _copyTo(List<String> added) async {
    if (added.isEmpty) return;
    await Future.wait([
      for (final event in await _shareable())
        _send(event, to: added, timeout: Duration.zero),
    ]);
  }

  /// The ids of the events matching [filter] on [relay], fetched a page at a
  /// time, and saved in the cache.
  Future<Set<String>> _fetchAll(String relay, Filter filter) async {
    final ids = <String>{};
    int? until;
    while (true) {
      // Not through the cache, which could hide some of the page.
      final response = ndk.requests.query(
        filter: filter.clone()..until = until,
        explicitRelays: [relay],
        cacheRead: false,
        cacheWrite: false,
        auth: AuthPolicy.require(_account),
      );
      final page = await response.future;
      final outcome = response.relayOutcomes.values.singleOrNull;
      if (outcome?.status != RelayRequestStatus.eose) {
        throw _LeftOut('${outcome ?? 'no answer'}');
      }
      final fresh = [
        for (final event in page)
          if (ids.add(event.id)) event,
      ];
      if (fresh.isEmpty) return ids;
      for (final event in fresh) {
        await ndk.config.cache.saveEventIfAbsent(event);
      }
      // Inclusive: a relay may cut its page in the middle of a second.
      until = page.map((event) => event.createdAt).reduce(min);
    }
  }

  /// Moves the live subscriptions, if any, to [currentRelays].
  Future<void> _followRelays() async {
    if (!_live.hasListener) return;
    _closeLive();
    await _openLive();
  }

  Future<List<RelayBroadcastResponse>> _send(
    Nip01Event event, {
    List<String>? to,
    Duration? timeout,
  }) async {
    return ndk.broadcast
        .broadcast(
          nostrEvent: event,
          specificRelays: to ?? await _targets(event),
          timeout: timeout,
          saveToCache: false,
          // Without it, a relay asking for AUTH would see the logged account.
          auth: AuthPolicy.allow(_account),
        )
        .broadcastDoneFuture;
  }

  Future<List<String>> _targets(Nip01Event event) async =>
      event.kind == Nip65.kKind
      ? _relayListTargets(await readRelayList(event, signer))
      : await currentRelays();

  List<String> _relayListTargets(RelayList? list) => {
    ...relays,
    ...?list?.public.keys,
    ...?list?.private.keys,
    ...indexers,
  }.toList();

  Account get _account => Account(
    type: AccountType.externalSigner,
    pubkey: signer.getPublicKey(),
    signer: signer,
  );
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

/// Why [Vault.reconcile] left a relay out.
class _LeftOut implements Exception {
  _LeftOut(this.reason);

  final String reason;
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
