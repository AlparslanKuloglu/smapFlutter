import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The sentence for an [AppErrorCode] that is shown where the scan has no
/// screen of its own for it (a toast after the exam request failed). The
/// words are the shared `errors_*` ones; no code, status or exception text
/// reaches the user.
String scanErrorText(AppLocalizations l10n, AppErrorCode code) =>
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
