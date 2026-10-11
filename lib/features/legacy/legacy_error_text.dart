import 'dart:ui' show Locale;

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The Turkish sentence of an [AppErrorCode] for the legacy screens that have
/// no `BuildContext` at hand (`errors_tr.arb`). The new screens map codes in
/// their own ViewModels.
String legacyErrorText(AppLocalizations l10n, AppErrorCode code) =>
    switch (code) {
      AppErrorCode.network => l10n.errors_network,
      AppErrorCode.timeout => l10n.errors_timeout,
      AppErrorCode.offline => l10n.errors_offline,
      AppErrorCode.unauthorized => l10n.errors_unauthorized,
      AppErrorCode.sessionExpired => l10n.errors_sessionExpired,
      AppErrorCode.forbidden => l10n.errors_forbidden,
      AppErrorCode.notFound => l10n.errors_notFound,
      AppErrorCode.validation => l10n.errors_validation,
      AppErrorCode.server => l10n.errors_server,
      AppErrorCode.maintenance => l10n.errors_maintenance,
      AppErrorCode.cancelled => l10n.errors_cancelled,
      AppErrorCode.unknown => l10n.errors_unknown,
    };

/// The app's Turkish strings without a context.
AppLocalizations legacyL10n() => lookupAppLocalizations(const Locale('tr'));
