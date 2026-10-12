part of '../scan_review_view.dart';

/// The form image card (pano 4.7, 4.8 kare 1; spec C70): a `bgSurface` card
/// (16 from the sides, 12 padding) with the image the reader drew its findings
/// on, 346 x 212 on the board, in an `InteractiveViewer` (1 to 5 times; a
/// double tap zooms to 2,5 times and back), the 40 pt "Formu büyüt" button (a
/// 48 pt target, `raised` shadow, white 94 %) at its top right, and "İki
/// parmakla yakınlaştırabilirsin." under the card.
///
/// While the image loads it is a 212 pt skeleton with "Form görüntüsü
/// yükleniyor" (the grid below already works: the answers came with the
/// reading); after 15 s without it, or on an error, the card says "Görüntü
/// yüklenemedi" with the text button "Tekrar Dene".
class _ReviewImageCard extends StatefulWidget {
  const _ReviewImageCard();

  @override
  State<_ReviewImageCard> createState() => _ReviewImageCardState();
}

enum _ImageLoad { loading, ready, failed }

class _ReviewImageCardState extends State<_ReviewImageCard> {
  final TransformationController _zoom = TransformationController();
  Timer? _timeout;
  _ImageLoad _load = _ImageLoad.loading;
  int _attempt = 0;

  /// The card's image area (pano 4.7: 346 x 212).
  static const double _imageHeight = 212;
  static const double _zoomedScale = 2.5;
  static const double _maxScale = 5;
  static const double _zoomButton = 40;

  @override
  void initState() {
    super.initState();
    _startTimeout();
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _zoom.dispose();
    super.dispose();
  }

  void _startTimeout() {
    _timeout?.cancel();
    _timeout = Timer(SmapDurations.skeletonTimeout, () {
      if (mounted && _load == _ImageLoad.loading) {
        setState(() => _load = _ImageLoad.failed);
      }
    });
  }

  void _markReady() {
    if (!mounted || _load == _ImageLoad.ready) return;
    _timeout?.cancel();
    setState(() => _load = _ImageLoad.ready);
  }

  void _markFailed() {
    if (!mounted || _load == _ImageLoad.failed) return;
    _timeout?.cancel();
    setState(() => _load = _ImageLoad.failed);
  }

  void _retry() {
    setState(() {
      _load = _ImageLoad.loading;
      _attempt++;
    });
    _startTimeout();
  }

  /// Zooms to 2,5 times around [focal] (view points), or back to 1.
  void _toggleZoom(Offset focal) {
    if (_zoom.value.getMaxScaleOnAxis() > 1.01) {
      _zoom.value = Matrix4.identity();
      return;
    }
    _zoom.value = Matrix4.identity()
      ..translateByDouble(
        -focal.dx * (_zoomedScale - 1),
        -focal.dy * (_zoomedScale - 1),
        0,
        1,
      )
      ..scaleByDouble(_zoomedScale, _zoomedScale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<ScanReviewViewModel>(context, listen: false);
    final url = vm.imageUrl;
    final failed = _load == _ImageLoad.failed || url == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: AppRadius.borderLg,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: SizedBox(
                height: _imageHeight,
                child: failed
                    ? _ImageFailed(onRetry: _retry)
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final center = constraints.biggest.center(
                            Offset.zero,
                          );
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.borderSm,
                                child: GestureDetector(
                                  onDoubleTapDown: (details) =>
                                      _toggleZoom(details.localPosition),
                                  child: InteractiveViewer(
                                    transformationController: _zoom,
                                    maxScale: _maxScale,
                                    child: Image.network(
                                      url,
                                      key: ValueKey(_attempt),
                                      fit: BoxFit.contain,
                                      frameBuilder:
                                          (context, child, frame, sync) {
                                            if (frame != null || sync) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback(
                                                    (_) => _markReady(),
                                                  );
                                            }
                                            return child;
                                          },
                                      errorBuilder: (context, error, stack) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback(
                                              (_) => _markFailed(),
                                            );
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              if (_load == _ImageLoad.loading)
                                const _ImageSkeleton(),
                              if (_load == _ImageLoad.ready)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: _ZoomButton(
                                    onPressed: () => _toggleZoom(center),
                                    size: _zoomButton,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s4),
            child: Text(
              l10n.scan_pinchHint,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
