import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import '../context.dart';
import '../vaults/vault_controller.dart';

/// Where the sync of [vaults] stands, for all of them at once: the oldest
/// last sync, and a failure as soon as one vault reaches no relay.
class SyncStatusText extends StatefulWidget {
  const SyncStatusText({super.key, required this.vaults});

  final List<VaultController> vaults;

  @override
  State<SyncStatusText> createState() => _SyncStatusTextState();
}

class _SyncStatusTextState extends State<SyncStatusText> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    // "Synced 3 min ago" has to become "4 min ago" on its own.
    _ticker = Timer.periodic(
      const Duration(seconds: 20),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final vaults = widget.vaults;
    final failed = vaults.any(
      (vault) => vault.phase == SyncRequestPhase.failed,
    );
    return Text(
      _describe(context.l10n, vaults, failed),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        color: failed ? palette.danger : palette.muted,
      ),
    );
  }

  String _describe(
    AppLocalizations l10n,
    List<VaultController> vaults,
    bool failed,
  ) {
    if (failed) return l10n.syncFailed;
    final lastSync = vaults.any((vault) => vault.lastSync == null)
        ? null
        : vaults
              .map((vault) => vault.lastSync!)
              .reduce((a, b) => a.isBefore(b) ? a : b);
    if (lastSync == null) {
      return vaults.any((vault) => vault.phase == SyncRequestPhase.syncing)
          ? l10n.syncing
          : l10n.syncNever;
    }
    final elapsed = DateTime.now().difference(lastSync);
    if (elapsed.inMinutes < 1) return l10n.syncedJustNow;
    if (elapsed.inHours < 1) return l10n.syncedMinutesAgo(elapsed.inMinutes);
    if (elapsed.inDays < 1) return l10n.syncedHoursAgo(elapsed.inHours);
    return l10n.syncedOn(lastSync.toLocal());
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({super.key, required this.vaults});

  final List<VaultController> vaults;

  @override
  Widget build(BuildContext context) {
    final syncing = vaults.any(
      (vault) => vault.phase == SyncRequestPhase.syncing,
    );
    return IconButton(
      tooltip: context.l10n.syncNow,
      onPressed: syncing
          ? null
          : () => Future.wait([for (final vault in vaults) vault.sync()]),
      icon: syncing
          ? SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.palette.muted,
              ),
            )
          : const Icon(Icons.sync_rounded),
    );
  }
}
