import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_theme.dart';

/// Keeps a legacy screen looking like it did before the app theme became
/// `SmapTheme` (plan RTR: "gerekirse eski ekranlar `Theme(data: LegacyTheme)`
/// ile sarılır").
///
/// The legacy screens were built against `AppTheme.light` (a Material 3 theme
/// seeded from the old blue-gray). Under `SmapTheme` (mihr_ui) stock buttons,
/// text fields and progress indicators would change shape and color, so every
/// legacy route page wraps its screen in this. It goes with the page when the
/// screen is migrated.
class LegacyTheme extends StatelessWidget {
  const LegacyTheme({required this.child, super.key});

  final Widget child;

  static final ThemeData _data = AppTheme.light;

  @override
  Widget build(BuildContext context) => Theme(data: _data, child: child);
}
