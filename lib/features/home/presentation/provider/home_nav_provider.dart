import 'package:flutter/foundation.dart';

enum HomeRoute { hub, mySchedule }

class HomeNavNotifier extends ChangeNotifier {
  HomeRoute _route = HomeRoute.hub;

  HomeRoute get route => _route;

  bool get isHub => _route == HomeRoute.hub;

  bool get showBackButton => !isHub;

  String get title => switch (_route) {
    HomeRoute.hub => 'Anasayfa',
    HomeRoute.mySchedule => 'Programım',
  };

  void open(HomeRoute route) {
    if (_route == route) return;
    _route = route;
    notifyListeners();
  }

  void backToHub() {
    if (_route == HomeRoute.hub) return;
    _route = HomeRoute.hub;
    notifyListeners();
  }

  void resetToHub() => backToHub();
}
