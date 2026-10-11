import 'package:flutter/services.dart';

import 'package:smap/features/auth/application/register/register_rules.dart';

/// Keeps what is typed into the user name field a valid user name (decision
/// 7.4): Turkish lower case, and only letters, digits, "." and "_". A
/// character that is not allowed is dropped as it is typed (a space, a dash),
/// so the field never needs a message about it; the cursor stays where the
/// person was typing.
class UserNameInputFormatter extends TextInputFormatter {
  const UserNameInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = RegisterRules.normalizeUserName(newValue.text);
    if (text == newValue.text) return newValue;
    final cursor = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, newValue.text.length)
        : newValue.text.length;
    final offset = RegisterRules.normalizeUserName(
      newValue.text.substring(0, cursor),
    ).length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset.clamp(0, text.length)),
    );
  }
}
