import 'package:flutter/material.dart';
import 'package:mihr_ui/mihr_ui.dart' show MihrButtonSize;
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/smap_text.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';

/// The five button kinds of the design (C01; board 1.9 "5 tür") plus the
/// red text button of Tur 6 G7.
enum AppButtonVariant {
  /// Navy fill, white label. One per screen; the camera button is not
  /// counted. Board 1.9 "Birincil".
  primary,

  /// Surface fill, 1,5 pt primary edge. Board 1.9 "İkincil" ("Tekrar Çek").
  outline,

  /// `bgSunken` fill, primary text color. Board 1.9 "Sessiz" ("Vazgeç").
  quiet,

  /// No fill, `textAction` label, 12 pt side padding. Board 1.9 "Metin"
  /// ("Şifremi Unuttum"). Has no loading state.
  text,

  /// Error fill, white label. Board 1.9 "Tehlikeli" ("Hesabı Sil").
  danger,

  /// No fill, error label (Tur 6 G7). Has no loading state.
  textDanger,
}

/// The two heights of a button (C01).
enum AppButtonSize {
  /// 40 high, 16 side padding, label-md; the touch target is padded to 48
  /// (`MaterialTapTargetSize.padded`). Rows and cards only.
  md40(mihr: MihrButtonSize.md, height: 40, side: 16),

  /// 48 high, 20 side padding, label-lg. The mihr_ui size is `xl`, not
  /// `lg` (Düzeltmeler #8: mihr's `lg` is 44).
  lg48(mihr: MihrButtonSize.xl, height: 48, side: 20);

  const AppButtonSize({
    required this.mihr,
    required this.height,
    required this.side,
  });

  /// The mihr_ui size the button is built on.
  final MihrButtonSize mihr;

  /// Visible height.
  final double height;

  /// Side padding of a plain button.
  final double side;

  /// The label style of this size (`label-lg` / `label-md`).
  TextStyle labelOf(SmapText text) =>
      this == lg48 ? text.labelLg : text.labelMd;
}

/// Resolves the [ButtonStyle] of an `AppButton` from the SMAP color roles.
///
/// Passed as the instance `style` of a mihr_ui button, never as a theme
/// override (Düzeltmeler #6: dev.3's `styleBuilder` drops theme-level
/// overrides; a full per-instance `style` wins over every default). Every
/// color property is set, so no mihr getter or default color shows through.
abstract final class AppButtonStyles {
  /// Width of the outline variant's edge.
  static const double outlineEdge = 1.5;

  /// Mihr pads the label by 4 on each side on top of the button padding; the
  /// design's padding is the total, so this much is taken off.
  static const double _mihrLabelPad = AppSpacing.s4;

  /// Padding of the text kinds, both sizes (C01 "text türü").
  static const double _textSide = 12;

  /// Side padding next to an icon: the icon's side is 16 instead of 20 on
  /// the large button (C01 "Baş ikonlu / Son ikonlu").
  static const double _iconSide = 16;

  static ButtonStyle of({
    required SmapColors colors,
    required SmapText text,
    required Brightness brightness,
    required AppButtonVariant variant,
    required AppButtonSize size,
    bool hasLeading = false,
    bool hasTrailing = false,
  }) {
    final look = _Look.of(colors, brightness, variant);
    final isText =
        variant == AppButtonVariant.text ||
        variant == AppButtonVariant.textDanger;
    final plain = isText ? _textSide : size.side;
    final left = isText || !hasLeading ? plain : _iconSide;
    final right = isText || !hasTrailing ? plain : _iconSide;
    final edge = look.edge;

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(look.fill),
      foregroundColor: WidgetStateProperty.resolveWith(look.ink),
      iconColor: WidgetStateProperty.resolveWith(look.ink),
      side: edge == null
          ? null
          : WidgetStateProperty.resolveWith(
              (states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? colors.borderStrong
                    : edge,
                width: outlineEdge,
              ),
            ),
      textStyle: WidgetStatePropertyAll(size.labelOf(text)),
      iconSize: const WidgetStatePropertyAll(AppSize.iconInButton),
      padding: WidgetStatePropertyAll(
        EdgeInsets.fromLTRB(left - _mihrLabelPad, 0, right - _mihrLabelPad, 0),
      ),
      minimumSize: WidgetStatePropertyAll(Size(0, size.height)),
      maximumSize: WidgetStatePropertyAll(Size(double.maxFinite, size.height)),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),
      // Per instance: mihr buttons ignore the theme's tap target size
      // (Düzeltmeler #5). 48 high buttons are unaffected.
      tapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// The loading spinner's track opacity per variant (C01 "Yükleniyor").
  static double trackAlpha(AppButtonVariant variant) => switch (variant) {
    AppButtonVariant.primary || AppButtonVariant.danger => 0.32,
    AppButtonVariant.outline => 0.20,
    AppButtonVariant.quiet => 0.18,
    AppButtonVariant.text || AppButtonVariant.textDanger => 0.20,
  };
}

/// The colors of one variant in one theme (C01 color tables, light and
/// dark 1.23).
class _Look {
  const _Look({
    required this.rest,
    required this.pressed,
    required this.disabled,
    required this.inkRest,
    required this.disabledInk,
    this.edge,
  });

  factory _Look.of(
    SmapColors c,
    Brightness brightness,
    AppButtonVariant variant,
  ) {
    final dark = brightness == Brightness.dark;
    // Disabled fill of the solid kinds: #DCE2E9 light, #213049 dark.
    final disabledSolid = dark ? c.bgSunken : c.borderSubtle;
    return switch (variant) {
      AppButtonVariant.primary => _Look(
        rest: c.primary,
        pressed: c.primaryPressed,
        disabled: disabledSolid,
        inkRest: c.onPrimary,
        disabledInk: c.textDisabled,
      ),
      AppButtonVariant.outline => _Look(
        rest: dark ? c.bgCanvas.clear : c.bgSurface,
        pressed: c.infoBg,
        disabled: dark ? c.bgCanvas.clear : c.bgSurface,
        inkRest: c.primary,
        disabledInk: c.textDisabled,
        edge: c.primary,
      ),
      AppButtonVariant.quiet => _Look(
        rest: c.bgSunken,
        pressed: c.borderSubtle,
        disabled: dark ? c.bgSunken : c.bgCanvas,
        inkRest: c.textPrimary,
        disabledInk: c.textDisabled,
      ),
      AppButtonVariant.danger => _Look(
        rest: c.error,
        // 1.9 pressed red #A3242B: error toward the text color.
        pressed: Color.lerp(c.error, c.textPrimary, 0.18)!,
        disabled: disabledSolid,
        inkRest: c.onError,
        disabledInk: c.textDisabled,
      ),
      AppButtonVariant.text => _Look(
        rest: c.bgCanvas.clear,
        pressed: c.infoBg,
        disabled: c.bgCanvas.clear,
        inkRest: c.textAction,
        disabledInk: c.textDisabled,
      ),
      AppButtonVariant.textDanger => _Look(
        rest: c.bgCanvas.clear,
        pressed: c.errorBg,
        disabled: c.bgCanvas.clear,
        inkRest: c.error,
        disabledInk: c.textDisabled,
      ),
    };
  }

  final Color rest;
  final Color pressed;
  final Color disabled;
  final Color inkRest;
  final Color disabledInk;

  /// The outline kind's edge color; null for the others.
  final Color? edge;

  Color fill(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return disabled;
    if (states.contains(WidgetState.pressed)) return pressed;
    return rest;
  }

  Color ink(Set<WidgetState> states) =>
      states.contains(WidgetState.disabled) ? disabledInk : inkRest;
}
