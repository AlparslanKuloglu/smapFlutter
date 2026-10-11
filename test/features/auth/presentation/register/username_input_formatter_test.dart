import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/auth/application/register/username_input_formatter.dart';

TextEditingValue _typed(String text, [int? cursor]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

void main() {
  const formatter = UserNameInputFormatter();

  TextEditingValue format(TextEditingValue v) =>
      formatter.formatEditUpdate(TextEditingValue.empty, v);

  test('a valid name passes untouched', () {
    final value = _typed('alparslan.k');

    expect(format(value), same(value));
  });

  test('upper case becomes Turkish lower case', () {
    expect(format(_typed('ALPARSLAN.K')).text, 'alparslan.k');
    expect(format(_typed('IŞIK')).text, 'ışık');
  });

  test('spaces and dashes are dropped as typed', () {
    expect(format(_typed('ali veli')).text, 'aliveli');
    expect(format(_typed('ali-veli')).text, 'aliveli');
  });

  test('the cursor follows the text', () {
    // "ali| veli" typed a space after "ali" in "aliveli" at offset 4.
    final result = format(_typed('ali veli', 4));

    expect(result.text, 'aliveli');
    expect(result.selection.baseOffset, 3);
  });

  test('a pasted mixed string is cleaned and the cursor goes to its end', () {
    final result = format(_typed('Ali Veli_99!'));

    expect(result.text, 'aliveli_99');
    expect(result.selection.baseOffset, 'aliveli_99'.length);
  });
}
