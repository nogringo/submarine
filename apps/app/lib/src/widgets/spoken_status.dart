import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Tells screen readers [message] whenever it changes, as a status they would
/// not hear otherwise (WCAG 4.1.3). An announcement where the platform makes
/// them, a live region where it does not: Android 16 dropped announcements.
class SpokenStatus extends StatefulWidget {
  const SpokenStatus({super.key, required this.message, required this.child});

  /// Null says nothing.
  final String? message;
  final Widget child;

  @override
  State<SpokenStatus> createState() => _SpokenStatusState();
}

class _SpokenStatusState extends State<SpokenStatus> {
  @override
  void initState() {
    super.initState();
    _announceAfterFrame();
  }

  @override
  void didUpdateWidget(SpokenStatus old) {
    super.didUpdateWidget(old);
    if (widget.message != old.message) _announceAfterFrame();
  }

  void _announceAfterFrame() =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final message = widget.message;
        // A screen under another one, or under a dialog, keeps quiet.
        if (message == null ||
            !mounted ||
            !MediaQuery.supportsAnnounceOf(context) ||
            !(ModalRoute.isCurrentOf(context) ?? true)) {
          return;
        }
        SemanticsService.sendAnnouncement(
          View.of(context),
          message,
          Directionality.of(context),
        );
      });

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion:
        widget.message != null && !MediaQuery.supportsAnnounceOf(context),
    child: widget.child,
  );
}
