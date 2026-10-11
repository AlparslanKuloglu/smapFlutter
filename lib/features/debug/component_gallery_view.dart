import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/gallery_registry.dart';
import 'package:smap/features/debug/gallery_settings.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_tab_bar.dart';

/// Debug catalog of the redesign's shared components in both themes, to put
/// next to the design boards 1.9 to 1.17 on a device (UI guide §5 #49; plan
/// KIT1). Opened by its own entry point, `lib/main_gallery.dart`, which has no
/// router (Düzeltmeler #22); never part of the release app.
///
/// At the top: light or dark theme, text scale 1,3 and reduce motion, then
/// one tab per [GalleryPage] of the [galleryPages] list. Each page shows every
/// state of its components: normal, pressed (a note: press and hold),
/// focused (a ring, or Tab on a keyboard), disabled, loading, error.
/// `--dart-define=GALLERY_PAGE=3` opens the fourth tab first.
class ComponentGalleryView extends StatefulWidget {
  const ComponentGalleryView({super.key});

  @override
  State<ComponentGalleryView> createState() => _ComponentGalleryViewState();
}

class _ComponentGalleryViewState extends State<ComponentGalleryView> {
  int _page = const int.fromEnvironment('GALLERY_PAGE');

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final settings = GalleryScope.of(context);
    final pages = galleryPages;
    final current = _page.clamp(0, pages.length - 1);

    return Scaffold(
      backgroundColor: colors.bgCanvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.s8,
                AppSpacing.gutter,
                0,
              ),
              child: Wrap(
                spacing: AppSpacing.s8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppChip(
                    label: 'Koyu tema',
                    selected: settings.dark,
                    onTap: () => settings.dark = !settings.dark,
                  ),
                  AppChip(
                    label: 'Metin 1,3',
                    selected: settings.largeText,
                    onTap: () => settings.largeText = !settings.largeText,
                  ),
                  AppChip(
                    label: 'Hareketi azalt',
                    selected: settings.reduceMotion,
                    onTap: () => settings.reduceMotion = !settings.reduceMotion,
                  ),
                ],
              ),
            ),
            AppTabBar(
              labels: [for (final page in pages) page.title],
              selectedIndex: current,
              scrollable: true,
              onChanged: (index) => setState(() => _page = index),
            ),
            Expanded(
              child: GalleryPageFrame(
                key: ValueKey<int>(current),
                child: pages[current].builder(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
