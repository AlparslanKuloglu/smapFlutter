import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_navigator.dart';

/// A [MeetingsNavigator] on the stack of the page that owns the ViewModel:
/// Görüşme Detayı is pushed on the Görüşmelerim tab's own stack, so the
/// bottom bar stays and Back walks it (pano 1.19 "sekme başına yığın").
class StackMeetingsNavigator implements MeetingsNavigator {
  const StackMeetingsNavigator(this._router);

  final StackRouter _router;

  @override
  Future<void> openMeeting(MeetingEntry meeting) =>
      _router.push(MeetingDetailRoute(meetingId: meeting.id, meeting: meeting));

  /// "Öğrencinin verileri": Öğrenci Profili in the Öğrencilerim tab, on its
  /// Program tab (Tur 12 A: the coach reads and edits the student's program
  /// from here). The tab switches and its stack becomes the list and the
  /// profile, so Back returns to the list.
  @override
  Future<void> openStudentData({
    required String studentId,
    required String name,
    String? photo,
  }) => _router.navigate(
    CoachStudentsTabRoute(
      children: [
        const StudentsRoute(),
        StudentProfileRoute(studentId: studentId, tab: 'program'),
      ],
    ),
  );
}
