import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/app/router/route_refresh.dart';
import 'package:smap/core/theme/smap_theme.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/legacy/legacy_scope.dart';
import 'package:smap/features/startup/application/session_expired_coordinator.dart';
import 'package:smap/features/startup/presentation/session_expired/session_expired_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/session_manager.dart';

/// The root widget (`MaterialApp.router`).
///
/// - Theme: `SmapTheme.light()` for both slots and `ThemeMode.light` until the
///   legacy screens are migrated (K9); the dark theme is built and ready for
///   the day `ThemeMode.system` goes on.
/// - Language: only Turkish; `AppLocalizations` plus the Material, Cupertino
///   and widgets delegates of Flutter.
/// - Router: the one `AppRouter`, re-running its guards when the session
///   changes (`RouteRefresh`).
/// - Above the router, the legacy providers (`LegacyScope`) stay, so the
///   legacy screens keep working until they are migrated.
/// - Toasts draw in the root navigator's overlay (`ToastService.navigator`),
///   so no host widget is needed here; the offline strip is the shell's (E5).
/// - The "oturum bitti" sheet is opened by the [SessionExpiredCoordinator]
///   from the session state, on whatever screen the user is.
class SmapApp extends StatefulWidget {
  const SmapApp({super.key});

  @override
  State<SmapApp> createState() => _SmapAppState();
}

class _SmapAppState extends State<SmapApp> {
  final AppRouter _router = locator<AppRouter>();
  late final RouteRefresh _refresh = RouteRefresh(locator<SessionManager>());
  late final RouterConfig<UrlState> _config = _router.config(
    reevaluateListenable: _refresh,
  );
  late final SessionExpiredCoordinator _expired = SessionExpiredCoordinator(
    session: locator<SessionManager>(),
    showSheet: SessionExpiredSheet.show,
    openSignIn: () => _router.push(const LoginRoute()),
  );

  @override
  void initState() {
    super.initState();
    _expired.start();
  }

  @override
  void dispose() {
    _expired.dispose();
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LegacyScope(
      child: MaterialApp.router(
        title: 'SMAP',
        debugShowCheckedModeBanner: false,
        theme: SmapTheme.light(),
        darkTheme: SmapTheme.dark(),
        themeMode: ThemeMode.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('tr')],
        locale: const Locale('tr'),
        routerConfig: _config,
      ),
    );
  }
}
