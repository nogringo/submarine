import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart' show PendingSignerRequest, SignerMethod;
import 'package:ndk/shared/nips/nip09/deletion.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:url_launcher/url_launcher.dart';

import '../context.dart';
import '../items/field_tile.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import 'dialog_buttons.dart';
import 'settings_tile.dart';
import 'spoken_status.dart';
import 'vault_avatar.dart';

/// How many requests the signers seem to wait on the user for.
int signerRequestCount(Vaults vaults) =>
    vaults.all.fold(0, (sum, vault) => sum + vault.signerRequests.length);

/// What the signers wait on the user for, in a dialog on a wide screen and a
/// sheet on a narrow one. Closes once they wait for nothing.
Future<void> showSignerRequests(BuildContext context) => context.isWide
    ? showDialog(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: _SignerRequests(),
            ),
          ),
        ),
      )
    : showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _SignerRequests(),
          ),
        ),
      );

/// Holds the app above a bar telling of the requests the signers wait on the
/// user for, on a narrow screen: a wide one has a button in the rail.
class SignerRequestsFrame extends StatelessWidget {
  const SignerRequestsFrame({
    super.key,
    required this.onOpen,
    required this.child,
  });

  final VoidCallback onOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final count = context.isWide ? 0 : signerRequestCount(Vaults.of(context));
    // The same widgets with or without the bar, for the app to keep its state.
    return Column(
      children: [
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: count > 0,
            child: child,
          ),
        ),
        if (count > 0) _SignerRequestsBar(count: count, onTap: onOpen),
      ],
    );
  }
}

class _SignerRequestsBar extends StatelessWidget {
  const _SignerRequestsBar({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final waiting = context.l10n.signerWaiting(count);
    return SpokenStatus(
      message: waiting,
      child: Semantics(
        button: true,
        child: Material(
          color: palette.raised,
          shape: Border(top: BorderSide(color: palette.line)),
          child: InkWell(
            onTap: onTap,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      size: 20,
                      color: palette.signal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        waiting,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: palette.muted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignerRequests extends StatefulWidget {
  const _SignerRequests();

  @override
  State<_SignerRequests> createState() => _SignerRequestsState();
}

class _SignerRequestsState extends State<_SignerRequests> {
  var _closing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final waiting = [
      for (final vault in Vaults.of(context).all)
        if (vault.waitingForSigner) vault,
    ];
    if (waiting.isEmpty) {
      if (!_closing) {
        _closing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
      return const SizedBox.shrink();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.signerRequestsTitle,
          style: Theme.of(context).dialogTheme.titleTextStyle,
        ),
        const SizedBox(height: 4),
        Text(
          l10n.signerRequestsDescription,
          style: TextStyle(fontSize: 13, color: palette.muted),
        ),
        for (final vault in waiting) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              VaultAvatar(vault: vault, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  vault.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FieldCard(
            children: [
              if (vault.approvalUrl case final url?)
                SettingsTile(
                  title: Text(l10n.bunkerApproval),
                  trailing: TextButton(
                    onPressed: () => launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Text(l10n.openApprovalPage),
                  ),
                ),
              for (final (label, requests) in _grouped(l10n, vault))
                SettingsTile(
                  title: Text(label),
                  trailing: TextButton(
                    onPressed: () => vault.cancelSignerRequests(requests),
                    child: Text(l10n.cancel),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        DialogButtons(
          children: [
            TextButton(
              onPressed: () {
                for (final vault in waiting) {
                  vault.cancelSignerRequests(vault.signerRequests);
                }
              },
              child: Text(l10n.cancelAll),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      ],
    );
  }
}

enum _Request {
  openVault,
  lockVault,
  decryptVersions,
  saveVersions,
  deleteVersions,
  saveRelays,
  readRelays,
  encryptRelays,
  relayAuth,
  other,
}

/// What [request] is for, told from what the vault asks of its signer.
_Request _kindOf(VaultController vault, PendingSignerRequest request) {
  final toItself = request.counterpartyPubkey == vault.pubkey;
  return switch (request.method) {
    SignerMethod.nip44Decrypt when toItself =>
      request.ciphertext == vault.record.cacheKey
          ? _Request.openVault
          : _Request.readRelays,
    SignerMethod.nip44Decrypt => _Request.decryptVersions,
    SignerMethod.nip44Encrypt when toItself =>
      request.plaintext == vault.vault.cache?.key
          ? _Request.lockVault
          : _Request.encryptRelays,
    SignerMethod.signEvent => switch (request.event?.kind) {
      versionEventKind => _Request.saveVersions,
      Deletion.kKind => _Request.deleteVersions,
      10002 => _Request.saveRelays,
      22242 => _Request.relayAuth,
      _ => _Request.other,
    },
    _ => _Request.other,
  };
}

/// The requests of [vault], grouped by what they are for.
List<(String, List<PendingSignerRequest>)> _grouped(
  AppLocalizations l10n,
  VaultController vault,
) {
  final groups = <(_Request, SignerMethod?), List<PendingSignerRequest>>{};
  for (final request in vault.signerRequests) {
    final kind = _kindOf(vault, request);
    final key = (kind, kind == _Request.other ? request.method : null);
    (groups[key] ??= []).add(request);
  }
  return [
    for (final MapEntry(key: (kind, method), value: requests) in groups.entries)
      (
        switch (kind) {
          _Request.openVault => l10n.requestOpenVault,
          _Request.lockVault => l10n.requestLockVault,
          _Request.decryptVersions => l10n.requestDecryptVersions(
            requests.length,
          ),
          _Request.saveVersions => l10n.requestSaveVersions(requests.length),
          _Request.deleteVersions => l10n.requestDeleteVersions(
            requests.length,
          ),
          _Request.saveRelays => l10n.requestSaveRelays,
          _Request.readRelays => l10n.requestReadRelays,
          _Request.encryptRelays => l10n.requestEncryptRelays,
          _Request.relayAuth => l10n.requestRelayAuth(requests.length),
          _Request.other => l10n.requestOther(
            requests.length,
            method!.protocolString,
          ),
        },
        requests,
      ),
  ];
}
