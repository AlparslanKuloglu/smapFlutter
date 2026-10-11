import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/smap_theme.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';

/// What the user sees when the bootstrap itself failed (the service container,
/// the preferences): one status screen and "Tekrar Dene". Without it the
/// native splash would stay up forever.
class BootFailureApp extends StatelessWidget {
  const BootFailureApp({required this.onRetry, super.key});

  /// Runs the bootstrap again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // The localizations are looked up directly: this app has no router and
    // the delegates below load them a frame later than the first build needs.
    final l10n = lookupAppLocalizations(const Locale('tr'));
    return MaterialApp(
      title: 'SMAP',
      debugShowCheckedModeBanner: false,
      theme: SmapTheme.light(),
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('tr')],
      locale: const Locale('tr'),
      home: AppStatusView(
        title: l10n.startup_bootFailedTitle,
        message: l10n.errors_unknown,
        icon: PhosphorIconsRegular.warningCircle,
        tone: AppStatusTone.error,
        blocking: true,
        primary: AppStatusAction(label: l10n.common_retry, onPressed: onRetry),
      ),
    );
  }
}
