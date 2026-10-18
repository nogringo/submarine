import 'dart:async';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import 'core.dart';

/// The mailboxes of the items the popup shows, by their key, an nsec. Each is
/// synced from [sync] to [close], as in the app: never all of them at once.
class Inboxes {
  Inboxes(this._ndk, {required this.indexers, required this.onChanged});

  final Ndk _ndk;

  /// Where a mailbox's NIP-65 list is looked for.
  final List<String> indexers;

  /// Tells that the messages of a mailbox changed.
  final void Function() onChanged;

  final _open = <String, _Inbox>{};

  /// The messages of the mailbox of [key] in the ndk cache, the newest first,
  /// without the text of an email nor its MIME, see [message].
  Future<List<Map<String, Object?>>> messages(String key) async => [
    for (final message in await _inbox(key).mailbox.messages())
      _toJson(message, whole: false),
  ];

  /// Fetches the latest messages of the mailbox of [key], then brings what
  /// arrives until [close].
  Future<void> sync(String key) => _inbox(key).sync();

  /// The message [wrapId] of the mailbox of [key], an email with its text and
  /// MIME, downloaded from Blossom when too large for a gift wrap.
  Future<Map<String, Object?>> message(String key, String wrapId) async {
    final inbox = _inbox(key);
    final message = await inbox.find(wrapId);
    if (message is! Email) return _toJson(message, whole: true);
    try {
      return _toJson(await inbox.mailbox.download(message), whole: true);
    } on EmailDownloadException {
      throw CoreException('emailDownloadFailed');
    }
  }

  /// Deletes the message [wrapId] of the mailbox of [key], see
  /// [Mailbox.delete].
  Future<void> delete(String key, String wrapId) async {
    final inbox = _inbox(key);
    await inbox.mailbox.delete(await inbox.find(wrapId));
    onChanged();
  }

  /// Stops syncing the mailbox of [key], and lets go of its key.
  Future<void> close(String key) async => _open.remove(key)?.close();

  Future<void> closeAll() async {
    final open = [..._open.values];
    _open.clear();
    await Future.wait([for (final inbox in open) inbox.close()]);
  }

  _Inbox _inbox(String key) => _open[key] ??= _Inbox(
    Mailbox(
      ndk: _ndk,
      signer: _ndk.config.eventSignerFactory.create(
        privateKey: _privateKeyOf(key),
      ),
      indexers: indexers,
    ),
    onChanged,
  );
}

String _privateKeyOf(String key) {
  try {
    if (key.startsWith('nsec1')) return Nip19.decode(key);
  } catch (_) {}
  throw CoreException('invalidMailboxKey');
}

Map<String, Object?> _toJson(MailMessage message, {required bool whole}) => {
  'wrapId': message.wrapId,
  'pubkey': message.pubkey,
  'date': message.date.millisecondsSinceEpoch,
  ...switch (message) {
    Email() => {
      'kind': 'email',
      'from': message.from,
      'fromName': message.fromName,
      'subject': message.subject,
      if (whole) ...{'text': message.text, 'mime': message.mime},
    },
    DirectMessage() => {'kind': 'privateMessage', 'text': message.text},
  },
};

class _Inbox {
  _Inbox(this.mailbox, this._onChanged);

  final Mailbox mailbox;
  final void Function() _onChanged;
  StreamSubscription<void>? _live;
  Future<void>? _syncing;
  var _closed = false;

  Future<void> sync() =>
      _syncing ??= _fetch().whenComplete(() => _syncing = null);

  /// Subscribes before fetching the latest messages, for none to arrive in
  /// between.
  Future<void> _fetch() async {
    try {
      await mailbox.fetchRelays();
      if (_closed) return;
      _live ??= mailbox.subscribe().listen((_) => _onChanged());
      await mailbox.fetch();
    } catch (error, stack) {
      print('Fetching an inbox failed: $error\n$stack');
    }
    if (!_closed) _onChanged();
  }

  Future<MailMessage> find(String wrapId) async {
    for (final message in await mailbox.messages()) {
      if (message.wrapId == wrapId) return message;
    }
    throw CoreException('messageNotFound');
  }

  Future<void> close() async {
    _closed = true;
    await _live?.cancel();
    // A fetch under way may still sign its AUTH.
    await _syncing;
    mailbox.signer.dispose();
  }
}
