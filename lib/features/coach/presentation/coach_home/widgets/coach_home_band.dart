part of '../coach_home_view.dart';

/// What the band shows: the first name, the avatar file, the student count and
/// the meeting count.
typedef _BandData = (String, String?, int?, int?);

/// The band of the coach home (pano 10.1 kare 1 to 4; C81
/// `AppHomeBand.coach`): "Merhaba, Mehmet" and under it "5 öğrenci ·
/// önümüzdeki 7 günde 2 görüşme" ("Henüz öğrencin yok" with no student; kare
/// 3).
///
/// The band comes at once with its data on the device (the name and the avatar
/// from the session): it never waits for a request. The counts fill in as the
/// sections arrive (a count that has not arrived, or whose section failed, is
/// left out of the line) and it rebuilds only when one of the four values
/// changes.
class _CoachBand
    extends SelectorViewModelWidget<CoachHomeViewModel, _BandData> {
  const _CoachBand();

  @override
  _BandData selector(CoachHomeViewModel viewModel) => (
    viewModel.firstName,
    viewModel.photo,
    viewModel.studentCount,
    viewModel.meetingCount,
  );

  @override
  Widget build(BuildContext context, _BandData data) {
    final (name, photo, students, meetings) = data;
    return AppHomeBand.coach(
      name: name,
      avatar: CoachAvatars.imageOf(photo),
      studentCount: students,
      upcomingMeetings: meetings,
    );
  }
}
