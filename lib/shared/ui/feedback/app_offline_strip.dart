import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/feedback/offline_strip_logic.dart';

/// The offline strip under the bar (C75 "OfflineStrip"; board 1.22 kare 6 and
/// 1.24 kare 5; handoff 11.15; UI guide §5 #31).
///
/// Sits directly under the root band or detail bar and pushes the content
/// down: it takes its own height in the layout (never an overlay), so put it
/// in the column between the bar and the page. 40 pt minimum, 8/16 padding,
/// 10 between the 18 pt WifiSlash and the text: "Çevrimdışısın. Son
/// kaydedilen veriler gösteriliyor." 13/20 · 600 in `onInverseSurface` on
/// `inverseSurface` (navy 900 in light, `#E8ECF1` in dark: the inverse surface
/// of the toast). It slides down in 250 ms; when the connection returns it
/// reads "Bağlandın" for 2 s and then slides away. Under "Reduce motion" it
/// fades in 150 ms. Announced as a live region.
///
/// It only tells; the screens keep showing the last saved data and the
/// actions that need the network wait in their queue. The band above it
/// flattens its bottom corners while the strip shows (the band's own job).
///
/// ```dart
/// AppOfflineStrip.service(locator<ConnectivityService>())
/// ```
class AppOfflineStrip extends StatefulWidget {
  /// Follows any `online` listenable.
  const AppOfflineStrip({required this.online, super.key});

  /// Follows [ConnectivityService.online].
  AppOfflineStrip.service(ConnectivityService connectivity, {Key? key})
    : this(online: connectivity.online, key: key);

  /// `true` while the device has a link.
  final ValueListenable<bool> online;

  /// Strip minimum height.
  static const double minHeight = 40;

  /// WifiSlash edge.
  static const double iconSize = 18;

  @override
  State<AppOfflineStrip> createState() => _AppOfflineStripState();
}

class _AppOfflineStripState extends State<AppOfflineStrip> {
  late OfflineStripController _controller = OfflineStripController(
    online: widget.online,
  );

  @override
  void didUpdateWidget(AppOfflineStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.online != widget.online) {
      _controller.dispose();
      _controller = OfflineStripController(online: widget.online);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return ValueListenableBuilder<OfflineStripPhase>(
      valueListenable: _controller.phase,
      builder: (context, phase, _) {
        final shown = phase != OfflineStripPhase.hidden;
        return ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: shown ? 1 : 0,
            duration: context.motion(AppMotion.base, reduced: Duration.zero),
            curve: shown ? AppMotion.enter : AppMotion.exit,
            child: ExcludeSemantics(
              excluding: !shown,
              child: AnimatedOpacity(
                opacity: shown ? 1 : 0,
                duration: reduce ? AppMotion.reducedFade : AppMotion.base,
                child: _StripBody(phase: phase),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StripBody extends StatelessWidget {
  const _StripBody({required this.phase});

  final OfflineStripPhase phase;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final connected = phase == OfflineStripPhase.connected;
    return Semantics(
      liveRegion: true,
      container: true,
      child: ColoredBox(
        color: colors.inverseSurface,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppOfflineStrip.minHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              children: [
                ExcludeSemantics(
                  child: PhosphorIcon(
                    connected
                        ? PhosphorIconsRegular.wifiHigh
                        : PhosphorIconsRegular.wifiSlash,
                    size: AppOfflineStrip.iconSize,
                    color: colors.onInverseSurface,
                  ),
                ),
                const SizedBox(width: _gap),
                Expanded(
                  child: Text(
                    connected
                        ? l10n.kit2_connectedStrip
                        : l10n.kit2_offlineStrip,
                    style: text.caption.copyWith(
                      color: colors.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Icon to text (C75: 10).
  static const double _gap = 10;
}
