import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';
export 'theme/palette.dart';

/// From this width on, the vaults, the items and the selected item sit side
/// by side. Below, each takes the whole screen.
const wideLayoutWidth = 720.0;

extension AppContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isWide => MediaQuery.sizeOf(this).width >= wideLayoutWidth;
}
