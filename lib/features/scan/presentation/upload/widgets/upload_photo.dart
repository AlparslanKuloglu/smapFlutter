part of '../scan_upload_view.dart';

/// The photo card (pano 4.5): 212 wide, 8 padding, radius 16, the shadow of
/// "raised" (the dark theme's is the board's 40 % black), with the
/// straightened photo 196 x 238 inside, centered. Read as "Okunan form
/// görüntüsü: dört kolon, kırk satır".
class _UploadPhoto extends ViewModelWidget<ScanUploadViewModel> {
  const _UploadPhoto();

  @override
  bool get reactive => false;

  static const double _width = 212;
  static const double _pad = 8;
  static const double _photoHeight = 238;

  @override
  Widget build(BuildContext context, ScanUploadViewModel viewModel) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Semantics(
        image: true,
        label: l10n.scan_uploadPhotoA11y,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.borderLg,
            boxShadow: AppShadows.raisedOf(context),
          ),
          child: SizedBox(
            width: _width,
            child: Padding(
              padding: const EdgeInsets.all(_pad),
              child: ClipRRect(
                borderRadius: AppRadius.borderSm,
                child: SizedBox(
                  height: _photoHeight,
                  child: Image.memory(
                    viewModel.photo,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    cacheWidth: 600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
