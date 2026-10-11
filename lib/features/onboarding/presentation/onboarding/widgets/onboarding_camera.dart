part of '../onboarding_view.dart';

typedef _CameraData = (CameraPermissionState state, bool busy);

/// "Formunu okutmak için kamera gerekli" (pano 2.2 kare 4): a 96 pt `infoBg`
/// circle with a Camera icon, the `display` title, one sentence, the primary
/// "Kameraya İzin Ver" (the system dialog) and the text button "Sonra" (on
/// without the permission; the first scan asks again). No Back button is
/// drawn; the system Back still goes back.
///
/// Once the permission was refused for good it becomes "Kamera izni kapalı"
/// (pano 4.1 kare 2): a CameraSlash in `errorBg`, "Formunu okutabilmek için
/// Ayarlar'da SMAP'e kamera izni ver. Sonra buraya dön; kaldığın yerden
/// devam edersin." and "Ayarları Aç" in place of the primary button; coming
/// back with the permission given moves on by itself.
class _CameraStep
    extends SelectorViewModelWidget<OnboardingViewModel, _CameraData> {
  const _CameraStep();

  /// The circle sits 150 from the top of the board's screen (62 of it is the
  /// safe area, which the status view adds itself).
  static const double _top = 88;

  @override
  _CameraData selector(OnboardingViewModel viewModel) =>
      (viewModel.cameraState, viewModel.cameraBusy);

  @override
  Widget build(BuildContext context, _CameraData data) {
    final (state, busy) = data;
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<OnboardingViewModel>(context, listen: false);
    final denied = state == CameraPermissionState.denied;
    return AppStatusView(
      title: denied
          ? l10n.onboarding_cameraDeniedTitle
          : l10n.onboarding_cameraTitle,
      message: denied
          ? l10n.onboarding_cameraDeniedBody
          : l10n.onboarding_cameraBody,
      icon: denied
          ? PhosphorIconsRegular.cameraSlash
          : PhosphorIconsRegular.camera,
      tone: denied ? AppStatusTone.error : AppStatusTone.info,
      topPadding: _top,
      primary: AppStatusAction(
        label: denied
            ? l10n.onboarding_openSettings
            : l10n.onboarding_cameraAllow,
        loading: busy,
        onPressed: busy ? null : vm.allowCamera,
      ),
      secondary: AppStatusAction(
        label: l10n.onboarding_cameraLater,
        variant: AppButtonVariant.text,
        onPressed: busy ? null : vm.later,
      ),
    );
  }
}
