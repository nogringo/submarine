import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'clipboard.dart';
import 'context.dart';
import 'lock/app_lock.dart';
import 'lock/lock_screen.dart';
import 'mail/mail_settings.dart';
import 'router.dart';
import 'screen_capture.dart';
import 'theme/appearance.dart';
import 'theme/theme.dart';
import 'vaults/vaults.dart';
import 'widgets/signer_requests.dart';

class SubmarineApp extends StatefulWidget {
  const SubmarineApp({
    super.key,
    required this.vaults,
    required this.lock,
    required this.appearance,
    required this.clipboard,
    required this.screenCapture,
    required this.mail,
  });

  final Vaults vaults;
  final AppLock lock;
  final Appearance appearance;
  final AppClipboard clipboard;
  final ScreenCapture screenCapture;
  final MailSettings mail;

  @override
  State<SubmarineApp> createState() => _SubmarineAppState();
}

class _SubmarineAppState extends State<SubmarineApp> {
  late final GoRouter _router = buildRouter(widget.vaults);
  late final AppLifecycleListener _lifecycle;
  late var _locked = widget.lock.locked;

  /// Redirects once unlocked, which the router left alone while locked.
  void _onLock() {
    if (_locked && !widget.lock.locked) _router.refresh();
    _locked = widget.lock.locked;
  }

  @override
  void initState() {
    super.initState();
    widget.lock.addListener(_onLock);
    _lifecycle = AppLifecycleListener(
      onPause: () => unawaited(widget.vaults.pauseSync()),
      onResume: widget.vaults.resumeSync,
      onHide: widget.lock.hidden,
      onShow: widget.lock.shown,
    );
  }

  @override
  void dispose() {
    widget.lock.removeListener(_onLock);
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VaultsScope(
    vaults: widget.vaults,
    child: AppLockScope(
      lock: widget.lock,
      child: AppClipboardScope(
        clipboard: widget.clipboard,
        child: ScreenCaptureScope(
          screenCapture: widget.screenCapture,
          child: MailSettingsScope(
            mail: widget.mail,
            child: AppearanceScope(
              appearance: widget.appearance,
              child: ListenableBuilder(
                listenable: widget.appearance,
                builder: (context, _) => MaterialApp.router(
                  title: 'Submarine',
                  debugShowCheckedModeBanner: false,
                  theme: buildTheme(Palette.light, Brightness.light),
                  darkTheme: buildTheme(Palette.dark, Brightness.dark),
                  themeMode: widget.appearance.themeMode,
                  locale: widget.appearance.locale,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  routerConfig: _router,
                  // Above the navigator, so that dialogs and menus hide too.
                  builder: (context, child) => AnnotatedRegion(
                    value: systemBarsStyle(Theme.of(context).brightness),
                    child: LockGate(
                      lock: widget.lock,
                      child: SignerRequestsFrame(
                        onOpen: () => showSignerRequests(
                          _router.routerDelegate.navigatorKey.currentContext!,
                        ),
                        child: child!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
