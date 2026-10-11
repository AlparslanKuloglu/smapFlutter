import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/features/lessons/application/subject_resolver.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_icons.dart';

void main() {
  group('SubjectResolver.fromLessonName', () {
    const cases = <String, SubjectKey?>{
      'Türkçe': SubjectKey.turkce,
      'TÜRKÇE': SubjectKey.turkce,
      'Türk Dili ve Edebiyatı': SubjectKey.edebiyat,
      'Edebiyat': SubjectKey.edebiyat,
      'Tarih': SubjectKey.tarih,
      'Tarih-2': SubjectKey.tarih,
      'Coğrafya-2': SubjectKey.cografya,
      'COĞRAFYA': SubjectKey.cografya,
      'Temel Matematik': SubjectKey.matematik,
      'Matematik': SubjectKey.matematik,
      'Geometri': SubjectKey.geometri,
      'Fizik': SubjectKey.fizik,
      'Kimya': SubjectKey.kimya,
      'Biyoloji': SubjectKey.biyoloji,
      'Felsefe': null,
      'Din Kültürü': null,
      '': null,
    };
    cases.forEach((name, subject) {
      test('"$name" -> $subject', () {
        expect(SubjectResolver.fromLessonName(name), subject);
      });
    });
  });

  group('SubjectTone and glyph mapping', () {
    test('all nine subjects have a tone in both themes', () {
      for (final key in SubjectKey.values) {
        expect(SubjectTone.light[key], isNotNull, reason: '$key light');
        expect(SubjectTone.dark[key], isNotNull, reason: '$key dark');
      }
      expect(SubjectKey.values.length, 9);
    });

    test('all nine subjects have a glyph and they differ', () {
      for (final key in SubjectKey.values) {
        expect(subjectIcons[key], isNotNull, reason: '$key');
      }
      expect(subjectIcons.values.toSet().length, 9);
    });

    test('the neutral glyph is none of the nine', () {
      expect(subjectIcons.values.contains(subjectFallbackIcon), isFalse);
    });
  });
}
