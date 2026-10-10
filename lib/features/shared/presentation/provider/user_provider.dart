import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smap/domain/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  // Uygulama açıldığında veya giriş yapıldığında çağırılacak
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userDataJson = prefs.getString('user_data');
    //print("userDataJson: $userDataJson");

    if (userDataJson != null) {
      _user = UserModel.fromJson(jsonDecode(userDataJson));
      notifyListeners(); // Widget'lara "veri geldi, kendini yenile" der
    }
  }

  void clearUserData() {
    _user = null; // Kullanıcı nesnesini sıfırla
    notifyListeners(); // Arayüze haber ver ki widget'lar temizlensin
  }

  String? get userRole => _user?.role;
}
