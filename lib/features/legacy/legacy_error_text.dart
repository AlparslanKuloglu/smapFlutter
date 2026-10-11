import 'dart:ui' show Locale;

import 'package:smap/l10n/app_localizations.dart';

/// The app's Turkish strings without a context, for the legacy code that has
/// no `BuildContext` at hand (the sign-up repository's failure message).
AppLocalizations legacyL10n() => lookupAppLocalizations(const Locale('tr'));
