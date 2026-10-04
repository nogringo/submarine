import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import '../context.dart';
import '../vaults/vault_controller.dart';

/// Where the sync of several vaults stands, as one: the oldest last sync, and
/// a failure as soon as one vault reaches no relay.
class SyncSummary {
  SyncSummary(List<VaultController> vaults)
    : failed = vaults.any((vault) => vault.phase == SyncRequestPhase.failed),
      syncing = vaults.any((vault) => vault.phase == SyncRequestPhase.syncing),
      lastSync = vaults.any((vault) => vault.lastSync == null)
          ? null
          : vaults
                .map((vault) => vault.lastSync!)
                .reduce((a, b) => a.isBefore(b) ? a : b);

  final bool failed;
  final bool syncing;

  /// Null until every vault reached a relay once.
  final DateTime? lastSync;

  String describe(AppLocalizations l10n) {
    if (failed) return l10n.syncFailed;
    final lastSync = this.lastSync;
    if (lastSync == null) return syncing ? l10n.syncing : l10n.syncNever;
    final elapsed = DateTime.now().difference(lastSync);
    if (elapsed.inMinutes < 1) return l10n.syncedJustNow;
    if (elapsed.inHours < 1) return l10n.syncedMinutesAgo(elapsed.inMinutes);
    if (elapsed.inDays < 1) return l10n.syncedHoursAgo(elapsed.inHours);
    return l10n.syncedOn(lastSync.toLocal());
  }
}

class SyncStatusText extends StatefulWidget {
  const SyncStatusText({super.key, required this.vaults, this.maxLines = 1});

  final List<VaultController> vaults;
  final int maxLines;

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
    final summary = SyncSummary(widget.vaults);
    return Text(
      summary.describe(context.l10n),
      maxLines: widget.maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13,
        color: summary.failed ? palette.danger : palette.muted,
      ),
    );
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({super.key, required this.vaults});

  final List<VaultController> vaults;

  @override
  Widget build(BuildContext context) {
    final syncing = SyncSummary(vaults).syncing;
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

/// The sync, at the bottom of the filter column.
class SyncCard extends StatelessWidget {
  const SyncCard({super.key, required this.vaults});

  final List<VaultController> vaults;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final summary = SyncSummary(vaults);
    final icon = summary.failed
        ? Icon(Icons.cloud_off_rounded, size: 18, color: palette.danger)
        : summary.lastSync != null
        ? Icon(Icons.check_rounded, size: 18, color: palette.muted)
        : null;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 4, 6),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.line),
      ),
      child: Row(
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 10)],
          Expanded(child: SyncStatusText(vaults: vaults, maxLines: 2)),
          SyncButton(vaults: vaults),
        ],
      ),
    );
  }
}
