/// A `getTotal` answer as the legacy screen reads it.
Map<String, Object?> totalAnswer() => {
  'success': true,
  'total': {
    'count': 12,
    'ortNet': 68.4,
    'lessOrSubjects': ['TYT Türkçe', 'TYT Tarih', 'TYT Matematik'],
    'data': [17, '4', 18.5],
  },
  'items': [
    {
      'subject': {'name': 'Sözcükte Anlam'},
      'count': 10,
      'trueValue': 7,
    },
    {
      'subject': {'name': 'Paragraf'},
      'count': 5,
      'trueValue': 5,
    },
  ],
};

/// A `getLineChartData` answer for a TYT student: three exams.
Map<String, Object?> lineChartAnswer({int? totalQuestion}) => {
  'success': true,
  'user': {'aimType': 3, 'name': 'Ayşe'},
  'totalQuestion': ?totalQuestion,
  'mockexams': [
    {
      'itemName': 'TYT Genel Deneme 8',
      'date': '2026-09-14T10:00:00.000Z',
      'net': 60.5,
      'true': 70,
      'wrong': 38,
      'pass': 12,
      'ranks': ['50.000', null, null, null, null],
      'points': ['380,5', null, null, null, null],
    },
    {
      'date': '2026-09-28T10:00:00.000Z',
      'net': 74.75,
      'true': 80,
      'wrong': 21,
      'pass': 19,
      'ranks': ['40.000', null, 1000, 2000, 3000],
      'points': [400, null, 410, 420, 430],
    },
    {'date': '2026-10-05T10:00:00.000Z', 'net': '67,5'},
    {'date': '2026-10-06', 'net': null},
  ],
};
