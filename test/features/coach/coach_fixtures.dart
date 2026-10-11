/// A student document as `getMyStudents` returns it, password hash included.
Map<String, Object?> studentJson({
  String id = 'student-1',
  String name = 'Zeynep',
  String? surname = 'Kaya',
  Object? seasonType = 12,
  Object? aimType = 2,
  Object? totalMexam = 14,
}) => {
  '_id': id,
  'name': name,
  'firstName': name,
  'surname': surname,
  'userName': 'zeynep.kaya',
  'password': r'$2a$10$abcdefghijklmnopqrstuv',
  'photo': 'avatars/1avatarN3.png',
  'schoolNo': 0,
  'totalMexam': totalMexam,
  'status': 1,
  'seasonType': seasonType,
  'aimType': aimType,
  'registerType': 0,
  'email': 'zeynep@example.com',
  'degreePoint': 0,
  'date': '2026-09-01T10:00:00.000Z',
  'phone': '5551112233',
  'coach': 'coach-1',
  '__v': 0,
};

/// An interview as `getInterviews` returns it.
Map<String, Object?> interviewJson({
  String id = 'iv-1',
  Object? type = 1,
  Object? student,
  Object? notesStr,
}) => {
  '_id': id,
  'type': type,
  'date': '2026-06-28T11:30:00.000Z',
  'student':
      student ??
      {
        '_id': 'student-1',
        'firstName': 'Zeynep',
        'surname': 'Kaya',
        'photo': '1avatarN3.png',
      },
  'notesStr':
      notesStr ?? '[{"note":"İlk not","date":"2026-06-28T12:00:00.000Z"}]',
};
