import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/phone_number.dart';

void main() {
  group('nationalDigits', () {
    test('keeps the ten digits of a national number', () {
      expect(PhoneNumber.nationalDigits('5321234567'), '5321234567');
    });

    test('drops every form of the country and trunk prefix', () {
      expect(PhoneNumber.nationalDigits('+90 532 123 45 67'), '5321234567');
      expect(PhoneNumber.nationalDigits('905321234567'), '5321234567');
      expect(PhoneNumber.nationalDigits('00905321234567'), '5321234567');
      expect(PhoneNumber.nationalDigits('0532 123 45 67'), '5321234567');
      expect(PhoneNumber.nationalDigits('532-123-4567'), '5321234567');
    });

    test('does not cut a number that merely starts like a prefix', () {
      // Eight digits that begin with 90 are not a country code.
      expect(PhoneNumber.nationalDigits('90123456'), '90123456');
      // A 10 digit number starting with 0 is not a trunk prefix.
      expect(PhoneNumber.nationalDigits('0532123456'), '0532123456');
    });

    test('is empty for null and for text without digits', () {
      expect(PhoneNumber.nationalDigits(null), '');
      expect(PhoneNumber.nationalDigits('yok'), '');
    });
  });

  group('grouped and display', () {
    test('groups 3-3-2-2', () {
      expect(PhoneNumber.grouped('5321234567'), '532 123 45 67');
      expect(PhoneNumber.grouped('+905321234567'), '532 123 45 67');
    });

    test('writes the whole number with the prefix', () {
      expect(PhoneNumber.display('0532 123 45 67'), '+90 532 123 45 67');
    });

    test('a number without digits has no display', () {
      expect(PhoneNumber.display(''), isNull);
      expect(PhoneNumber.display(null), isNull);
    });
  });

  group('isComplete', () {
    test('wants ten digits starting with 5', () {
      expect(PhoneNumber.isComplete('532 123 45 67'), isTrue);
      expect(PhoneNumber.isComplete('532 123 45 6'), isFalse);
      expect(PhoneNumber.isComplete('212 123 45 67'), isFalse);
      expect(PhoneNumber.isComplete(''), isFalse);
    });
  });
}
