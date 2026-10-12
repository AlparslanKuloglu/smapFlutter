import 'package:smap/features/coach/application/meeting_models.dart';

/// Where the meeting screens lead (pano 13.11): the ViewModels call this, not
/// a router, so a test can record the calls.
abstract interface class MeetingsNavigator {
  /// "Görüşme Detayı" of [meeting] (pano 10.5 kare 3), on the Görüşmelerim
  /// tab's stack.
  Future<void> openMeeting(MeetingEntry meeting);

  /// "Öğrencinin verileri" (pano 10.5 kare 3: "Analiz, denemeler, program"):
  /// the student's own data in the coach's view, Öğrenci Profili (pano 10.4)
  /// on its Program tab (Tur 12 A).
  Future<void> openStudentData({
    required String studentId,
    required String name,
    String? photo,
  });
}
