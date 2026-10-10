import 'package:flutter/foundation.dart';

enum AccountRoute {
  hub,
  account,
  payment,
  savedCards,
  contracts,
  notifications,
}

class AccountNavNotifier extends ChangeNotifier {
  AccountRoute _route = AccountRoute.hub;

  AccountRoute get route => _route;

  bool get isHub => _route == AccountRoute.hub;

  bool get showBackButton => !isHub;

  String get title => switch (_route) {
    AccountRoute.hub => 'Hesap',
    AccountRoute.account => 'Profilim',
    AccountRoute.payment => 'Ödeme Ayarlarım',
    AccountRoute.savedCards => 'Kayıtlı Kartlarım',
    AccountRoute.contracts => 'Sözleşmeler',
    AccountRoute.notifications => 'Bildirimler',
  };

  void open(AccountRoute route) {
    if (_route == route) return;
    _route = route;
    notifyListeners();
  }

  void backToHub() {
    if (_route == AccountRoute.hub) return;
    _route = AccountRoute.hub;
    notifyListeners();
  }

  void resetToHub() => backToHub();
}
