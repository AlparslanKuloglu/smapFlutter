import 'package:flutter/material.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/core/theme/subject_tone.dart';

/// The one way screen code reads the design tokens (UI guide §4.7).
///
/// ```dart
/// final colors = context.appColors;
/// final text = context.appText;
/// Text(value, style: text.metricLg.copyWith(color: colors.textPrimary));
/// ```
///
/// Both getters throw a [FlutterError] if the theme is not `SmapTheme` (the
/// extension is missing). That is the right failure: a widget under another
/// theme would otherwise show wrong colors without a sign.
extension SmapThemeContext on BuildContext {
  /// All color roles of the current theme.
  SmapColors get appColors {
    final colors = Theme.of(this).extension<SmapColors>();
    if (colors == null) throw _missing('SmapColors');
    return colors;
  }

  /// All text styles of the current theme (colorless).
  SmapText get appText {
    final text = Theme.of(this).extension<SmapText>();
    if (text == null) throw _missing('SmapText');
    return text;
  }

  /// The tile and accent colors of [key] in the current theme.
  SubjectTone appSubject(SubjectKey key) => appColors.subjects[key]!;

  FlutterError _missing(String extension) => FlutterError(
    '$extension is not on the current Theme. Build the app theme with '
    'SmapTheme.light() / SmapTheme.dark().',
  );
}
