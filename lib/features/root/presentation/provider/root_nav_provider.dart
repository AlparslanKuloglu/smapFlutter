import 'package:flutter/foundation.dart';

class RootNavNotifier extends ChangeNotifier {
  int _selectedIndex = 0;
  int? _initialTabIndex;

  int get selectedIndex => _selectedIndex;
  int? get initialTabIndex => _initialTabIndex;

  /// Ana tab değişimini yapar ve isteğe bağlı olarak alt sekme indeksini alır.
  void changeTab(int index, {int? initialTabIndex}) {
    if (_selectedIndex == index && _initialTabIndex == initialTabIndex) {
      return;
    }

    _selectedIndex = index;
    _initialTabIndex = initialTabIndex;
    notifyListeners();
  }
}
