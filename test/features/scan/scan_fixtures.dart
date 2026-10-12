import 'package:smap/features/scan/domain/answer_grid.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';

/// The answers of the board's example (pano 4.7; Ek C): a form of four columns
/// of 40 questions, 160 answers, two of them blank: the 12th of the 3rd column
/// and the 31st of the 4th. The letters cycle A to E so a cell can be told from
/// its neighbours.
List<List<String?>> sampleAnswerColumns({
  Set<(int, int)> blanks = const {(3, 12), (4, 31)},
}) => [
  for (var column = 1; column <= 4; column++)
    [
      for (var question = 1; question <= 40; question++)
        blanks.contains((column, question))
            ? null
            : AnswerChoice.letters[(column + question) % 5].legacyValue,
    ],
];

/// The server's `opticimage` answer for [sampleAnswerColumns].
Map<String, dynamic> sampleOpticJson({
  List<List<String?>>? columns,
  Object? mexamFound,
  bool withImage = true,
}) => {
  'success': true,
  'answersArray': columns ?? sampleAnswerColumns(),
  'opticImageFileName': withImage ? 'optic_160.jpg' : null,
  'originalImageFileName': withImage ? 'original_160.jpg' : null,
  'mexamFound': ?mexamFound,
};

OpticReading sampleReading({List<List<String?>>? columns}) =>
    OpticReading.fromJson(sampleOpticJson(columns: columns));

/// The `answerArray` answer when the exam is known (pano 4.7 kare 4: "86 D · 74
/// Y · 0 B", "Türkiye Geneli Deneme 7").
Map<String, dynamic> sampleAnswerJson({bool found = true}) => {
  'success': true,
  'mexamFound': found
      ? {
          '_id': '6527f1c2a4b5d8e9f0123456',
          'itemName': 'Türkiye Geneli Deneme 7',
        }
      : false,
  'answersArray': sampleAnswerColumns(blanks: const {}),
  'opticImageFileName': 'optic_160.jpg',
};
