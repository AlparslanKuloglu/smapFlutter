part of '../home_view.dart';

/// What the band shows: the first name, the avatar file, the days left and
/// the exam day.
typedef _BandData = (String, String?, int?, DateTime);

/// The band of the home screen (pano 3.1 kare 1 and 2, 3.2, 3.3; C81
/// `AppHomeBand.student`): "Merhaba, Alparslan" and the YKS counter "252 gün
/// kaldı · YKS · 19 Haziran 2027 Cumartesi", which shrinks to one line
/// "YKS'ye 252 gün" as the page scrolls.
///
/// The band comes at once with its data on the device (the name from the
/// session, the counter from the clock): it never waits for a request. It
/// rebuilds only when the name, the avatar or the day count changes, and the
/// counter is renewed at midnight by the ViewModel.
class _HomeBand extends SelectorViewModelWidget<HomeViewModel, _BandData> {
  const _HomeBand();

  @override
  _BandData selector(HomeViewModel viewModel) => (
    viewModel.firstName,
    viewModel.photo,
    viewModel.daysLeft,
    viewModel.yksDate,
  );

  @override
  Widget build(BuildContext context, _BandData data) {
    final (name, photo, daysLeft, examDate) = data;
    final asset = AvatarAsset.pathOf(photo);
    return AppHomeBand.student(
      name: name,
      avatar: asset == null ? null : AssetImage(asset),
      counter: daysLeft == null
          ? null
          : AppHomeCounter(daysLeft: daysLeft, examDate: examDate),
    );
  }
}
