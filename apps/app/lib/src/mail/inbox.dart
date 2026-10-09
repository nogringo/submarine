import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ndk/ndk.dart' show Nip19;
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../theme/theme.dart';
import '../vaults/vaults.dart';
import '../widgets/spinning_icon.dart';

/// The emails and private messages of an item's mailbox, synced while it
/// shows, unless [Vaults.pauseSync] paused the syncing.
class Inbox extends StatefulWidget {
  const Inbox({super.key, required this.mailboxKey, required this.title});

  /// The nsec the item holds.
  final String mailboxKey;

  final String title;

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  late final Mailbox _mailbox;
  bool? _paused;
  StreamSubscription<void>? _live;
  Future<void>? _syncing;
  var _messages = const <MailMessage>[];
  var _reading = false;
  var _readAgain = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vaults = Vaults.of(context);
    if (_paused == null) {
      _mailbox = Mailbox(
        ndk: vaults.ndk,
        signer: vaults.ndk.config.eventSignerFactory.create(
          privateKey: Nip19.decode(widget.mailboxKey),
        ),
        indexers: vaults.indexers,
      );
      unawaited(_read());
    }
    if (vaults.syncPaused == _paused) return;
    _paused = vaults.syncPaused;
    vaults.syncPaused ? _pause() : _sync();
  }

  @override
  void dispose() {
    _pause();
    // A fetch under way may still sign its AUTH.
    unawaited(
      (_syncing ?? Future.value()).whenComplete(_mailbox.signer.dispose),
    );
    super.dispose();
  }

  void _sync() {
    _syncing ??= _fetch().whenComplete(() {
      if (mounted) setState(() => _syncing = null);
    });
  }

  /// Subscribes before fetching the latest messages, for none to arrive in
  /// between.
  Future<void> _fetch() async {
    try {
      await _mailbox.fetchRelays();
      if (!mounted || _paused!) return;
      _live ??= _mailbox.subscribe().listen((_) => unawaited(_read()));
      await _mailbox.fetch();
    } catch (error, stack) {
      _report(error, stack, 'while fetching the inbox');
    }
    if (mounted) await _read();
  }

  void _pause() {
    unawaited(_live?.cancel());
    _live = null;
  }

  /// Folds the reads asked for while one runs into a single next one.
  Future<void> _read() async {
    if (_reading) {
      _readAgain = true;
      return;
    }
    _reading = true;
    try {
      do {
        _readAgain = false;
        final messages = await _mailbox.messages();
        if (!mounted) return;
        setState(() => _messages = messages);
      } while (_readAgain);
    } catch (error, stack) {
      _report(error, stack, 'while reading the inbox');
    } finally {
      _reading = false;
    }
  }

  void _report(Object error, StackTrace stack, String context) =>
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'submarine',
          context: ErrorDescription(context),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final syncing = _syncing != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.muted,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.refreshInbox,
              onPressed: syncing ? null : () => setState(_sync),
              icon: SpinningIcon(
                Icons.refresh_rounded,
                spinning: syncing,
                size: 20,
                color: palette.muted,
              ),
            ),
          ],
        ),
        FieldCard(
          children: [
            if (_messages.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  syncing ? l10n.inboxFetching : l10n.inboxEmpty,
                  style: TextStyle(color: palette.muted),
                ),
              ),
            for (final message in _messages)
              _MessageRow(
                message: message,
                onTap: () => _showMessage(context, _mailbox, message),
              ),
          ],
        ),
      ],
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message, required this.onTap});

  final MailMessage message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    const name = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
    final (icon, kind, sender, senderStyle, summary) = switch (message) {
      Email(:final from, :final fromName, :final subject) => (
        Icons.mail_outline_rounded,
        l10n.email,
        fromName ?? from,
        name,
        subject.isEmpty ? l10n.noSubject : subject,
      ),
      DirectMessage(:final pubkey, :final text) => (
        Icons.chat_bubble_outline_rounded,
        l10n.privateMessage,
        _shortNpub(pubkey),
        monoStyle.copyWith(fontSize: 14),
        text.trim().split('\n').first,
      ),
    };
    final date = _formatDate(context, message.date);
    return Semantics(
      button: true,
      label: '$kind, $sender, $summary, $date',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Icon(icon, color: palette.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sender,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: senderStyle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: TextStyle(fontSize: 13, color: palette.muted),
                        ),
                      ],
                    ),
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: palette.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Its start and its end, which tell two keys apart, as a whole npub fills
/// the line.
String _shortNpub(String pubkey) {
  final npub = Nip19.encodePubKey(pubkey);
  return '${npub.substring(0, 12)}...${npub.substring(npub.length - 6)}';
}

/// The time for today's messages, the date for older ones.
String _formatDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final local = date.toLocal();
  final now = DateTime.now();
  final today =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  return (today ? DateFormat.Hm(locale) : DateFormat.yMMMd(locale)).format(
    local,
  );
}

/// In a dialog on wide screens, in a sheet on phones, as the generator.
Future<void> _showMessage(
  BuildContext context,
  Mailbox mailbox,
  MailMessage message,
) {
  final view = _MessageView(mailbox: mailbox, message: message);
  if (context.isWide) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: view,
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: view,
      ),
    ),
  );
}

class _MessageView extends StatefulWidget {
  const _MessageView({required this.mailbox, required this.message});

  final Mailbox mailbox;
  final MailMessage message;

  @override
  State<_MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<_MessageView> {
  /// The text of a large email, downloaded once the view opens.
  late Future<String> _text = _download();

  Future<String> _download() async => switch (widget.message) {
    Email(:final text?) => text,
    final Email email => (await widget.mailbox.download(email)).text!,
    DirectMessage(:final text) => text,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final message = widget.message;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final (title, sender) = switch (message) {
      Email(:final from, :final fromName, :final subject) => (
        subject.isEmpty ? l10n.noSubject : subject,
        fromName == null ? from : '$fromName <$from>',
      ),
      DirectMessage(:final pubkey) => (
        l10n.privateMessage,
        Nip19.encodePubKey(pubkey),
      ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectableText(
          title,
          style: Theme.of(context).dialogTheme.titleTextStyle,
        ),
        const SizedBox(height: 8),
        SelectableText(sender, style: TextStyle(color: palette.muted)),
        Text(
          DateFormat.yMMMd(locale).add_Hm().format(message.date.toLocal()),
          style: TextStyle(fontSize: 13, color: palette.muted),
        ),
        const Divider(height: 32),
        FutureBuilder(
          future: _text,
          builder: (context, snapshot) => switch (snapshot) {
            AsyncSnapshot(:final data?) => SelectableText(data),
            AsyncSnapshot(hasError: true) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.emailDownloadFailed,
                  style: TextStyle(color: palette.danger),
                ),
                TextButton(
                  onPressed: () => setState(() => _text = _download()),
                  child: Text(l10n.tryAgain),
                ),
              ],
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
    );
  }
}
