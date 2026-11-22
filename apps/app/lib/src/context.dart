import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show GlobalMaterialLocalizations;

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';
export 'theme/palette.dart';

/// Not [AppLocalizations.localizationsDelegates]: it registers the Material
/// localizations of the SDK, which the widgets of material_ui do not read.
const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// From this width on, the vaults, the items and the selected item sit side
/// by side. Below, each takes the whole screen.
const wideLayoutWidth = 720.0;

/// From this width on, the filters get a column of their own.
const filterColumnWidth = 1100.0;

extension AppContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isWide => MediaQuery.sizeOf(this).width >= wideLayoutWidth;

  bool get showsFilters => MediaQuery.sizeOf(this).width >= filterColumnWidth;
}
