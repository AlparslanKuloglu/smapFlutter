import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/smap_colors.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';

/// The four tones of an [AppNoticeBox].
enum AppNoticeTone {
  /// `infoBg` with an Info icon in `info`.
  info,

  /// `successBg` with a CheckCircle in `success`.
  success,

  /// `warningBg` with a Warning triangle in `warning` (never orange).
  warning,

  /// `errorBg` with a WarningCircle in `error`.
  error;

  /// The Phosphor Regular icon of the tone.
  IconData get icon => switch (this) {
    info => PhosphorIconsRegular.info,
    success => PhosphorIconsRegular.checkCircle,
    warning => PhosphorIconsRegular.warning,
    error => PhosphorIconsRegular.warningCircle,
  };

  /// The tint behind the box.
  Color fillOf(SmapColors colors) => switch (this) {
    info => colors.infoBg,
    success => colors.successBg,
    warning => colors.warningBg,
    error => colors.errorBg,
  };

  /// The icon color.
  Color inkOf(SmapColors colors) => switch (this) {
    info => colors.info,
    success => colors.success,
    warning => colors.warning,
    error => colors.error,
  };
}

/// The inline notice (C39 "InfoBox / ErrorBox / WarningBox"; board 1.4 and
/// the sign-up and settings screens 2.2, 2.3, 2.5, 9.5, 9.6; UI guide §5 #17).
///
/// A row with a 20 pt tone icon (1 pt from the top) and the message at
/// 15/22 in `textPrimary` (the text never takes the tone color), 10 apart; 12
/// / 14 padding, radius 12, no left stripe. [actionLabel] adds an inline text
/// button under the message ("Ayarları Aç") aligned with the text. Error and
/// warning notices are announced as alerts (live region), info and success
/// as plain content.
class AppNoticeBox extends StatelessWidget {
  const AppNoticeBox({
    required this.message,
    this.tone = AppNoticeTone.info,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// The message ("Fotoğrafı çekebilmek için kamera iznine ihtiyacımız var.").
  final String message;
  final AppNoticeTone tone;

  /// The inline text button ("Ayarları Aç").
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Icon edge.
  static const double iconSize = AppSize.iconInButton;

  /// Gap between the icon and the text (C39: 10).
  static const double _gap = 10;

  /// Padding (C39: 12 / 14).
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: AppSpacing.s12,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final alert = tone == AppNoticeTone.error || tone == AppNoticeTone.warning;
    return Semantics(
      container: true,
      liveRegion: alert,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tone.fillOf(colors),
          borderRadius: AppRadius.borderMd,
        ),
        child: Padding(
          padding: _padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: ExcludeSemantics(
                  child: PhosphorIcon(
                    tone.icon,
                    size: iconSize,
                    color: tone.inkOf(colors),
                  ),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: context.appText.body.copyWith(
                        color: colors.textPrimary,
                        height: 22 / 15,
                      ),
                    ),
                    if (actionLabel case final label?) ...[
                      const SizedBox(height: 2),
                      // The text button's own 12 pt side padding is pulled
                      // back so its label lines up with the message, and its
                      // 48 pt target overflows the 30 pt it takes in layout.
                      SizedBox(
                        height: 30,
                        child: OverflowBox(
                          alignment: Alignment.centerLeft,
                          minHeight: 0,
                          maxHeight: AppSize.touch,
                          maxWidth: double.infinity,
                          child: Transform.translate(
                            offset: const Offset(-12, 0),
                            child: AppButton(
                              label: label,
                              onPressed: onAction,
                              variant: AppButtonVariant.text,
                              size: AppButtonSize.md40,
                              focusGapColor: tone.fillOf(colors),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
