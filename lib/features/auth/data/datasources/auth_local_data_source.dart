import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String sessionCookieKey = 'connect_sid';
  static const String userDataKey = 'user_data';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<bool> getOnboardingCompleted() async {
    final prefs = await _prefs();
    return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(onboardingCompletedKey, value);
  }

  Future<String?> getSessionCookie() async {
    final prefs = await _prefs();
    return prefs.getString(sessionCookieKey);
  }

  Future<void> setSessionCookie(String value) async {
    final prefs = await _prefs();
    await prefs.setString(sessionCookieKey, value);
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(isLoggedInKey, value);
  }

  Future<void> clearSessionCookie() async {
    final prefs = await _prefs();
    await prefs.remove(sessionCookieKey);
    await prefs.remove(
      userDataKey,
    ); // Çıkış yapınca user verisini de silmek güvenlidir
  }

  // YENİ VE DOĞRU METOT:
  Future<void> setUserData(String userDataJson) async {
    final prefs = await _prefs(); // Önce prefs alınmalı
    await prefs.setString(userDataKey, userDataJson);
  }

  // İhtiyacın olabilir: Kayıtlı kullanıcı verisini geri okumak için
  Future<String?> getUserData() async {
    final prefs = await _prefs();
    return prefs.getString(userDataKey);
  }
}
