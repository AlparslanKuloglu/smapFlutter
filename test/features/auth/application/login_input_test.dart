import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/auth/application/login_input.dart';

void main() {
  group('LoginInput.normalizeUsername', () {
    test('lower-cases and removes spaces (pano 2.3 "Davranış")', () {
      expect(LoginInput.normalizeUsername(' Alparslan.K '), 'alparslan.k');
      expect(LoginInput.normalizeUsername('ali veli'), 'aliveli');
      expect(LoginInput.normalizeUsername('Ayşe\t_Nur\n'), 'ayşe_nur');
    });

    test('lower-cases the Turkish I and İ the Turkish way', () {
      expect(LoginInput.normalizeUsername('IŞIK'), 'ışık');
      expect(LoginInput.normalizeUsername('İPEK'), 'ipek');
    });

    test('an empty or blank name stays empty', () {
      expect(LoginInput.normalizeUsername(''), '');
      expect(LoginInput.normalizeUsername('   '), '');
    });
  });

  group('LoginInput.isComplete', () {
    test('needs both a name and a password', () {
      expect(LoginInput.isComplete(username: 'ayse', password: 'x'), isTrue);
      expect(LoginInput.isComplete(username: '', password: 'x'), isFalse);
      expect(LoginInput.isComplete(username: 'ayse', password: ''), isFalse);
    });

    test('a password of spaces counts as typed (it is sent as it is)', () {
      expect(LoginInput.isComplete(username: 'ayse', password: ' '), isTrue);
    });
  });
}
