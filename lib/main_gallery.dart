import 'package:flutter/material.dart';
import 'package:smap/core/theme/smap_theme.dart';
import 'package:smap/features/debug/component_gallery_view.dart';
import 'package:smap/features/debug/gallery_settings.dart';
import 'package:smap/features/debug/launch_env.dart';
import 'package:smap/l10n/app_localizations.dart';

/// Entry point of the component gallery:
/// `flutter run -t lib/main_gallery.dart`.
///
/// Router-free on purpose (Düzeltmeler #22): a plain `MaterialApp` with
/// [SmapTheme] light and dark, the app's localizations (tr) and the gallery
/// view as home. It does not touch the app's dependency container, the router
/// or the session, so it runs against any build of the kit.
/// Keyboard focus rings are always shown (traditional highlight mode) so the
/// focus states can be seen with a hardware keyboard or the Tab key.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;
  runApp(const GalleryApp());
}

/// The gallery app shell: theme mode, text scale and reduce motion come from
/// [GallerySettings].
class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  final GallerySettings _settings = GallerySettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) => MaterialApp(
        title: 'SMAP',
        debugShowCheckedModeBanner: false,
        // `GALLERY_SEMANTICS=true` draws the semantics tree over the page.
        showSemanticsDebugger: debugLaunchEnv('GALLERY_SEMANTICS') == 'true',
        theme: SmapTheme.light(),
        darkTheme: SmapTheme.dark(),
        themeMode: _settings.dark ? ThemeMode.dark : ThemeMode.light,
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(_settings.textScale),
            disableAnimations: _settings.reduceMotion,
          ),
          child: child!,
        ),
        home: GalleryScope(
          settings: _settings,
          child: const ComponentGalleryView(),
        ),
      ),
    );
  }
}
