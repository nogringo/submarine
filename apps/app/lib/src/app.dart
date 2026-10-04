import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'context.dart';
import 'router.dart';
import 'theme/theme.dart';
import 'vaults/vaults.dart';

class SubmarineApp extends StatefulWidget {
  const SubmarineApp({super.key, required this.vaults});

  final Vaults vaults;

  @override
  State<SubmarineApp> createState() => _SubmarineAppState();
}

class _SubmarineAppState extends State<SubmarineApp> {
  late final GoRouter _router = buildRouter(widget.vaults);
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onPause: () => unawaited(widget.vaults.pauseSync()),
      onResume: widget.vaults.resumeSync,
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VaultsScope(
    vaults: widget.vaults,
    child: MaterialApp.router(
      title: 'Submarine',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Palette.light, Brightness.light),
      darkTheme: buildTheme(Palette.dark, Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    ),
  );
}
