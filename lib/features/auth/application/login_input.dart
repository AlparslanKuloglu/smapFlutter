import 'package:smap/core/utils/turkish_text.dart';

/// Pure rules of the sign-in form (pano 2.3 "Davranış"), unit-tested.
abstract final class LoginInput {
  /// What is sent as the user name: every space removed and the letters in
  /// Turkish lower case ("Alparslan.K " becomes "alparslan.k"; pano 2.3
  /// "Büyük harf ve boşluk kullanıcı adında kırpılır", T7.4 "küçük harfe
  /// çevrilir"). The password is never touched.
  static String normalizeUsername(String raw) =>
      TurkishText.lower(raw.replaceAll(RegExp(r'\s'), ''));

  /// Both fields have something in them. [username] is expected normalized;
  /// the password counts as typed even when it is only spaces.
  static bool isComplete({
    required String username,
    required String password,
  }) => username.isNotEmpty && password.isNotEmpty;
}
