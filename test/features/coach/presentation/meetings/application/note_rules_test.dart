import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/coach/application/note_rules.dart';

void main() {
  test('a note holds 500 characters (pano 10.6 "0/500")', () {
    expect(NoteRules.maxLength, 500);
  });

  group('"Notu Kaydet" (pano 10.6 kare 1)', () {
    test('is off while there is no text', () {
      expect(NoteRules.canAdd(''), isFalse);
      expect(NoteRules.canAdd('   \n '), isFalse);
    });

    test('works once there is something', () {
      expect(NoteRules.canAdd('Tarih eksikleri'), isTrue);
    });
  });

  group('"Kaydet" of an edit (pano 10.6 kare 2)', () {
    const original = 'Tarih eksikleri için haftada 3 saat ayrıldı.';

    test('works only for a change', () {
      expect(NoteRules.canSaveEdit(original, original: original), isFalse);
      expect(
        NoteRules.canSaveEdit('Haftada 4 saat ayrıldı.', original: original),
        isTrue,
      );
    });

    test('whitespace around the text is no change', () {
      expect(
        NoteRules.canSaveEdit('  $original ', original: original),
        isFalse,
      );
    });

    test('an emptied note cannot be saved', () {
      expect(NoteRules.canSaveEdit('', original: original), isFalse);
      expect(NoteRules.canSaveEdit('  ', original: original), isFalse);
    });
  });

  test('the text goes out trimmed', () {
    expect(NoteRules.normalize('  a b \n'), 'a b');
  });
}
