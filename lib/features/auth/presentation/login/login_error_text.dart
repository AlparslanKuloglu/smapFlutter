import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The sentence of the red box on the sign-in screen for a failed attempt
/// (pano 2.3 kare 3; spec §4.A "2.3").
///
/// Wrong credentials get the board's sentence and nothing that tells which
/// field is wrong. A sign-in that got no answer, or lost the connection,
/// reads "Bağlanamadık…"; the other codes use the shared `errors_*` texts, so
/// no raw error or server message ever reaches the screen.
///
/// [forgotPasswordOpen] says whether the reset link is drawn: the board's
/// "…ya da şifreni sıfırla." points at it, so without the link the sentence
/// ends after "Tekrar dene.".
String loginErrorText(
  AppLocalizations l10n,
  AppErrorCode code, {
  required bool forgotPasswordOpen,
}) => switch (code) {
  AppErrorCode.unauthorized ||
  AppErrorCode.validation ||
  AppErrorCode.notFound =>
    forgotPasswordOpen
        ? l10n.login_errorInvalid
        : l10n.login_errorInvalidNoReset,
  AppErrorCode.network || AppErrorCode.timeout => l10n.login_errorNetwork,
  AppErrorCode.offline => l10n.errors_offline,
  AppErrorCode.sessionExpired => l10n.errors_sessionExpired,
  AppErrorCode.forbidden => l10n.errors_forbidden,
  AppErrorCode.server => l10n.errors_server,
  AppErrorCode.maintenance => l10n.errors_maintenance,
  AppErrorCode.cancelled => l10n.errors_cancelled,
  AppErrorCode.unknown => l10n.errors_unknown,
};
