import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:enough_mail_plus/mime.dart' show MimeMessage;
import 'package:ndk/domain_layer/entities/nip_65.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/helpers/relay_helper.dart';

import 'cipher/cipher.dart';
import 'cipher/field.dart';
import 'html_text.dart';
import 'mail_bridge.dart';
import 'relay_list.dart';

/// A new mailbox at [bridge]: the nsec of a key made for it alone, for a
/// hidden field of the item, and its address, that key's npub at [bridge].
/// The key comes from [signerFactory], the one the app gives ndk.
({String key, String address}) generateMailbox(
  String bridge, {
  required LocalEventSignerFactory signerFactory,
}) {
  final (privateKey, publicKey) = signerFactory.generateKeyPair();
  return (
    key: Nip19.encodePrivateKey(privateKey),
    address: '${Nip19.encodePubKey(publicKey)}@$bridge',
  );
}

/// The mailboxes [cipher] holds: each nsec of a hidden field whose address,
/// its npub at a bridge, is the username, a field or the identity's email.
List<({String key, String address})> mailboxesOf(
  Cipher cipher, {
  required LocalEventSignerFactory signerFactory,
}) {
  final values = [
    ?cipher.login?.username,
    ?cipher.identity?.email,
    for (final field in cipher.fields) ?field.value,
  ].map((value) => value.trim());
  final mailboxes = <({String key, String address})>[];
  for (final field in cipher.fields) {
    final key = field.value?.trim();
    if (field.type != FieldType.hidden || key == null) continue;
    final npub = _npubOf(key, signerFactory);
    if (npub == null) continue;
    for (final address in values) {
      if (address.startsWith('$npub@') &&
          parseMailBridge(address.substring(npub.length + 1)) != null) {
        mailboxes.add((key: key, address: address));
        break;
      }
    }
  }
  return mailboxes;
}

String? _npubOf(String key, LocalEventSignerFactory signerFactory) {
  if (!key.startsWith('nsec1')) return null;
  try {
    return Nip19.encodePubKey(signerFactory.derivePublicKey(Nip19.decode(key)));
  } catch (_) {
    return null;
  }
}

/// Publishes the relay lists of the mailbox of [key], an nsec, signed by that
/// key: a NIP-65 list of [relays], to them and to [indexers], and a
/// `kind:10050` list of [inboxRelays], the relays its emails arrive on, to
/// [relays]. A bridge finds the first on the indexers, then the second.
///
/// Local first, as a vault: done once the lists are saved in the ndk cache,
/// which then sends them in the background.
Future<void> publishMailboxRelays(
  Ndk ndk,
  String key, {
  required List<String> relays,
  required List<String> inboxRelays,
  List<String> indexers = indexerRelays,
}) async {
  final signer = ndk.config.eventSignerFactory.create(
    privateKey: Nip19.decode(key),
  );
  final relayList = await signRelayList(
    RelayList(
      public: {for (final relay in relays) relay: ReadWriteMarker.readWrite},
    ),
    signer,
  );
  final inboxList = await signer.sign(
    Nip01Event(
      pubKey: signer.getPublicKey(),
      kind: _inboxRelaysKind,
      tags: [
        for (final relay in inboxRelays) ['relay', relay],
      ],
      content: '',
    ),
  );
  final account = Account(
    type: AccountType.privateKey,
    pubkey: signer.getPublicKey(),
    signer: signer,
  );
  for (final (event, to) in [
    (relayList, {...relays, ...indexers}),
    (inboxList, relays),
  ]) {
    await ndk.config.cache.saveEvent(event);
    await ndk.broadcast
        .broadcast(
          nostrEvent: event,
          specificRelays: to,
          timeout: Duration.zero,
          saveToCache: false,
          // Without it, a relay asking for AUTH would see the logged account.
          auth: AuthPolicy.allow(account),
        )
        .broadcastDoneFuture;
  }
}

/// Relays a client gives the NIP-65 list of a new mailbox by default, those
/// of the nmail app.
const defaultMailboxRelays = [
  'wss://relay.nmail.li',
  'wss://nostr-01.yakihonne.com',
  'wss://relay.primal.net',
];

/// Relays a client gives the `kind:10050` list of a new mailbox by default,
/// those of the nmail app: the bridge sends the mailbox's emails to them.
const defaultMailboxInboxRelays = [
  'wss://relay.nmail.li',
  'wss://auth.nostr1.com',
];

/// Blossom servers a client looks for a large email on, after those its sender
/// lists: the defaults of nostr-mail.
const defaultBlossomServers = [
  'https://blossom.nmail.li',
  'https://blossom.yakihonne.com',
  'https://blossom.ditto.pub',
  'https://blossom.primal.net',
];

const _inboxRelaysKind = 10050;
const _blossomServersKind = 10063;
const _emailKind = 1301;
const _privateMessageKind = 14;

/// The inbox of a mailbox: the emails (nostr-mail, kind 1301) and the private
/// messages (NIP-17, kind 14) gift wrapped to the key of [signer], on the
/// relays of its NIP-65 and `kind:10050` lists.
///
/// [signer] opens them at each read, without a prompt when it is the local key
/// of the item: nothing decrypted is stored.
class Mailbox {
  Mailbox({
    required this.ndk,
    required this.signer,
    this.indexers = indexerRelays,
    this.blossomServers = defaultBlossomServers,
  });

  final Ndk ndk;
  final EventSigner signer;

  /// Where [fetchRelays] looks for the NIP-65 list.
  final List<String> indexers;

  /// Where [download] looks for a large email, after the servers its sender
  /// lists.
  final List<String> blossomServers;

  /// By gift wrap id, null for one that holds no message. Kept in memory only,
  /// for a new gift wrap not to open all the others again.
  final _opened = <String, MailMessage?>{};

  /// The relays of the mailbox's NIP-65 and `kind:10050` lists in the ndk
  /// cache, see [fetchRelays] to fill it.
  Future<List<String>> relays() async {
    final lists = await ndk.config.cache.loadEvents(
      pubKeys: [signer.getPublicKey()],
      kinds: [Nip65.kKind, _inboxRelaysKind],
    );
    return {
      for (final list in lists)
        for (final url in list.getTags(
          list.kind == Nip65.kKind ? 'r' : 'relay',
        ))
          ?cleanRelayUrl(url),
    }.toList();
  }

  /// Fetches the mailbox's relay lists into the ndk cache, the NIP-65 one from
  /// [indexers] and the relays known, then the `kind:10050` one from the
  /// relays of the first, and returns [relays].
  Future<List<String>> fetchRelays() async {
    for (final (kind, extra) in [
      (Nip65.kKind, indexers),
      (_inboxRelaysKind, const <String>[]),
    ]) {
      await _query(Filter(kinds: [kind], authors: [signer.getPublicKey()]), {
        ...extra,
        ...await relays(),
      }, auth: AuthPolicy.allow(_account));
    }
    return relays();
  }

  /// Fetches the latest [limit] gift wraps of the mailbox from [relays] into
  /// the ndk cache. Opening an inbox is to read the latest ones.
  Future<void> fetch({int limit = 100}) async => _query(
    _wraps..limit = limit,
    await relays(),
    auth: AuthPolicy.require(_account),
  );

  /// Holds a subscription open on [relays] for the gift wraps that arrive from
  /// now on, and saves them in the ndk cache. An event comes out of the stream
  /// once saved, for [messages] to see it. Subscribe before [fetch], for
  /// nothing to arrive in between.
  Stream<Nip01Event> subscribe() => _live.stream;

  late final _live = StreamController<Nip01Event>.broadcast(
    onListen: () => unawaited(_openLive()),
    onCancel: _closeLive,
  );

  (String, StreamSubscription<Nip01Event>)? _liveRequest;

  /// Tells an opening that a close came while it read the relays.
  var _liveGeneration = 0;

  Future<void> _openLive() async {
    final generation = ++_liveGeneration;
    final relays = await this.relays();
    if (generation != _liveGeneration || relays.isEmpty) return;
    final response = ndk.requests.subscription(
      // A limit holds for stored events only, while a `since` would also drop
      // the new gift wraps, which are backdated.
      filter: _wraps..limit = 0,
      explicitRelays: relays,
      cacheWrite: true,
      auth: AuthPolicy.require(_account),
    );
    _liveRequest = (
      response.requestId,
      response.stream.listen(_live.add, onError: _live.addError),
    );
  }

  void _closeLive() {
    _liveGeneration++;
    if (_liveRequest case (final requestId, final listener)) {
      unawaited(listener.cancel());
      unawaited(ndk.requests.closeSubscription(requestId));
    }
    _liveRequest = null;
  }

  /// The emails and private messages of the gift wraps in the ndk cache, the
  /// newest first. Leaves out a gift wrap that does not open, or holds
  /// anything else.
  Future<List<MailMessage>> messages() async {
    final wraps = await ndk.config.cache.loadEvents(
      kinds: [GiftWrap.kGiftWrapEventkind],
      tags: {
        'p': [signer.getPublicKey()],
      },
    );
    await Future.wait([
      for (final wrap in wraps)
        if (!_opened.containsKey(wrap.id))
          _open(wrap).then((message) => _opened[wrap.id] = message),
    ]);
    return [for (final wrap in wraps) ?_opened[wrap.id]]
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// [email] with its [Email.text], downloaded when it was too large for a
  /// gift wrap (nostr-mail Blossom): from the servers its sender lists, then
  /// [blossomServers]. Nothing is stored.
  ///
  /// Throws an [EmailDownloadException] when no server gives it.
  Future<Email> download(Email email) async {
    final blob = email._blob;
    if (blob == null) return email;
    final servers = {
      ...await _blossomServersOf(email.pubkey),
      ...blossomServers,
    };
    for (final server in servers) {
      final Uint8List data;
      try {
        data = (await ndk.blossom.getBlob(
          sha256: blob.hash,
          serverUrls: [server],
        )).data;
      } catch (_) {
        continue;
      }
      if (sha256.convert(data).toString() != blob.hash) continue;
      final mime = utf8.decode(await _decryptBlob(data, blob));
      return Email._parse(email.wrapId, email.pubkey, email.date, mime);
    }
    throw EmailDownloadException(blob.hash);
  }

  Filter get _wraps => Filter(
    kinds: [GiftWrap.kGiftWrapEventkind],
    pTags: [signer.getPublicKey()],
  );

  Account get _account => Account(
    type: AccountType.privateKey,
    pubkey: signer.getPublicKey(),
    signer: signer,
  );

  Future<void> _query(
    Filter filter,
    Iterable<String> relays, {
    required AuthPolicy auth,
  }) async {
    // Without explicit relays, ndk would ask its bootstrap relays.
    if (relays.isEmpty) return;
    await ndk.requests
        .query(
          filter: filter,
          explicitRelays: relays,
          // The cache could stand in for what the relays hold.
          cacheRead: false,
          auth: auth,
        )
        .future;
  }

  Future<List<String>> _blossomServersOf(String pubkey) async {
    final filter = Filter(kinds: [_blossomServersKind], authors: [pubkey]);
    await _query(filter, {
      ...await relays(),
      ...indexers,
    }, auth: const AuthPolicy.never());
    final lists = await ndk.config.cache.loadEvents(
      pubKeys: [pubkey],
      kinds: [_blossomServersKind],
    );
    return [for (final list in lists) ...list.getTags('server')];
  }

  Future<MailMessage?> _open(Nip01Event wrap) async {
    try {
      final seal = await _decrypt(wrap);
      if (seal.kind != GiftWrap.kSealEventKind ||
          !await ndk.config.eventVerifier.verify(seal)) {
        return null;
      }
      final rumor = await _decrypt(seal);
      // Only the seal's signature tells who sent it (NIP-17).
      if (rumor.pubKey != seal.pubKey) return null;
      final date = DateTime.fromMillisecondsSinceEpoch(rumor.createdAt * 1000);
      return switch (rumor.kind) {
        _emailKind => Email._fromRumor(wrap.id, rumor, date),
        _privateMessageKind => DirectMessage._(
          wrapId: wrap.id,
          pubkey: rumor.pubKey,
          date: date,
          text: rumor.content,
        ),
        _ => null,
      };
    } catch (_) {
      // Anyone can send a gift wrap to the mailbox.
      return null;
    }
  }

  Future<Nip01Event> _decrypt(Nip01Event event) async {
    final json = await signer.decryptNip44(
      ciphertext: event.content,
      senderPubKey: event.pubKey,
    );
    return Nip01EventModel.fromJson(jsonDecode(json!));
  }
}

/// A message of a [Mailbox].
sealed class MailMessage {
  const MailMessage({
    required this.wrapId,
    required this.pubkey,
    required this.date,
  });

  /// The gift wrap it came in, the one relays hold.
  final String wrapId;

  /// Who sealed it: the sender of a private message, the bridge of an email
  /// from outside Nostr.
  final String pubkey;

  final DateTime date;
}

/// An email, from nostr-mail's kind 1301.
final class Email extends MailMessage {
  const Email._({
    required super.wrapId,
    required super.pubkey,
    required super.date,
    required this.from,
    this.fromName,
    required this.subject,
    required this.text,
    this._blob,
  });

  factory Email._fromRumor(String wrapId, Nip01Event rumor, DateTime date) {
    final hash = rumor.getFirstTag('x');
    if (rumor.content.isNotEmpty || hash == null) {
      return Email._parse(wrapId, rumor.pubKey, date, rumor.content);
    }
    final key = rumor.getFirstTag('decryption-key');
    final nonce = rumor.getFirstTag('decryption-nonce');
    return Email._(
      wrapId: wrapId,
      pubkey: rumor.pubKey,
      date: date,
      from: rumor.getFirstTag('mail-from') ?? rumor.getFirstTag('from') ?? '',
      subject: rumor.getFirstTag('subject') ?? '',
      text: null,
      blob: key == null || nonce == null
          ? null
          : (hash: hash, key: key, nonce: nonce),
    );
  }

  factory Email._parse(
    String wrapId,
    String pubkey,
    DateTime date,
    String mime,
  ) {
    final message = MimeMessage.parseFromText(mime);
    final sender = message.from?.firstOrNull;
    final html = message.decodeTextHtmlPart();
    final text =
        message.decodeTextPlainPart() ?? (html == null ? '' : htmlToText(html));
    return Email._(
      wrapId: wrapId,
      pubkey: pubkey,
      date: date,
      from: sender?.email ?? '',
      fromName: sender?.hasPersonalName ?? false ? sender!.personalName : null,
      subject: message.decodeSubject() ?? '',
      text: text.replaceAll('\r\n', '\n').trim(),
    );
  }

  /// The sender's address.
  final String from;

  /// The sender's name, when the email gives one.
  final String? fromName;

  final String subject;

  /// Plain text, an HTML email's included. Null for an email too large for a
  /// gift wrap until [Mailbox.download].
  final String? text;

  final ({String hash, String key, String nonce})? _blob;
}

/// A private message, NIP-17's kind 14.
final class DirectMessage extends MailMessage {
  const DirectMessage._({
    required super.wrapId,
    required super.pubkey,
    required super.date,
    required this.text,
  });

  final String text;
}

/// What [Mailbox.download] throws when no Blossom server gives a large email.
class EmailDownloadException implements Exception {
  const EmailDownloadException(this.hash);

  /// The SHA-256 of the encrypted email.
  final String hash;

  @override
  String toString() =>
      'EmailDownloadException: no Blossom server gives the email $hash';
}

Future<List<int>> _decryptBlob(
  Uint8List data,
  ({String hash, String key, String nonce}) blob,
) {
  final aes = cryptography.AesGcm.with256bits();
  final macLength = aes.macAlgorithm.macLength;
  return aes.decrypt(
    cryptography.SecretBox(
      data.sublist(0, data.length - macLength),
      nonce: base64Decode(blob.nonce),
      mac: cryptography.Mac(data.sublist(data.length - macLength)),
    ),
    secretKey: cryptography.SecretKey(base64Decode(blob.key)),
  );
}
