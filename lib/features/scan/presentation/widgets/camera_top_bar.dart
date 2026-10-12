import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/scan/presentation/widgets/camera_chrome_button.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The top bar of the camera stages (pano 4.2 to 4.4; spec C67): Kapat at the
/// left, the [title] in the middle (15/24 · 600, white) and, when [onHelp] is
/// given, "?" at the right; without it a 48 pt gap keeps the title centered
/// ("sağda 48 boşluk", pano 4.4). 48 pt high and 8 from the sides, lifted 8
/// above the safe area edge as on the board (y 54 on a 62 pt safe area).
///
/// It is a [Positioned]: put it in a `Stack`. Dark theme only.
class CameraTopBar extends StatelessWidget {
  const CameraTopBar({
    required this.title,
    required this.onClose,
    this.onHelp,
    super.key,
  });

  /// "Optik Form", "Köşeleri Ayarla".
  final String title;
  final VoidCallback onClose;

  /// The "?" button; null leaves the 48 pt gap.
  final VoidCallback? onHelp;

  /// How far the bar rises above the safe area edge.
  static const double lift = 8;

  /// Where the bar's bottom edge is under the safe area, for the screens that
  /// lay content out below it.
  static const double below = AppSize.touch - lift;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final safe = MediaQuery.paddingOf(context).top;
    return Positioned(
      top: safe > lift ? safe - lift : 0,
      left: AppSpacing.s8,
      right: AppSpacing.s8,
      height: AppSize.touch,
      child: Row(
        children: [
          CameraChromeButton(
            icon: PhosphorIconsRegular.x,
            semanticLabel: l10n.common_close,
            onPressed: onClose,
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: text.bodyStrong.copyWith(color: colors.textOnNavy),
              ),
            ),
          ),
          if (onHelp != null)
            CameraChromeButton(
              icon: PhosphorIconsRegular.question,
              iconSize: 22,
              semanticLabel: l10n.scan_howToShootA11y,
              onPressed: onHelp,
            )
          else
            const SizedBox(width: AppSize.touch),
        ],
      ),
    );
  }
}
