part of '../shell_frame.dart';

/// The offline strip on top of the shell (pano 1.22 kare 6, 1.24 kare 5;
/// spec §3.5): "Çevrimdışısın. Son kaydedilen veriler gösteriliyor." slides
/// down over 250 ms when the link goes and "Bağlandın" leaves it after 2 s.
///
/// The strip is the kit's [AppOfflineStrip]; this adds the status bar's room
/// to it. While it shows, its navy block takes the top safe area and the
/// content below stops reserving it (its media padding top shrinks by the
/// same amount), so the pages do not move and no strip text sits under the
/// clock. It follows the same `online` listenable as the kit's strip, with a
/// phase machine of its own, so the two agree to the frame.
class _ShellOfflineStrip extends StatefulWidget {
  const _ShellOfflineStrip({required this.online, required this.child});

  final ValueListenable<bool> online;
  final Widget child;

  @override
  State<_ShellOfflineStrip> createState() => _ShellOfflineStripState();
}

class _ShellOfflineStripState extends State<_ShellOfflineStrip> {
  late final OfflineStripController _controller = OfflineStripController(
    online: widget.online,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final inset = media.padding.top;
    final colors = context.appColors;
    return ValueListenableBuilder<OfflineStripPhase>(
      valueListenable: _controller.phase,
      child: widget.child,
      builder: (context, phase, child) {
        final shown = phase != OfflineStripPhase.hidden;
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: shown ? 1 : 0),
          duration: context.motion(AppMotion.base, reduced: Duration.zero),
          curve: shown ? AppMotion.enter : AppMotion.exit,
          child: child,
          builder: (context, t, child) => Column(
            children: [
              ColoredBox(
                color: colors.inverseSurface,
                child: SizedBox(width: double.infinity, height: inset * t),
              ),
              AppOfflineStrip(online: widget.online),
              Expanded(
                child: MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(top: inset * (1 - t)),
                  ),
                  child: child!,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
