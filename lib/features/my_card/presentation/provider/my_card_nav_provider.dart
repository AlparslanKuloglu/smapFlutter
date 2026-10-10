import 'package:flutter/foundation.dart';

class MyCardNavNotifier extends ChangeNotifier {
  String? _selectedLessonId;
  String? _selectedLessonName;

  String? get selectedLessonId => _selectedLessonId;
  String? get selectedLessonName => _selectedLessonName;

  bool get isHub => _selectedLessonId == null;

  bool get showBackButton => !isHub;

  String get title => isHub ? 'Derslerim' : '$_selectedLessonName Derslerim';

  void openLesson({required String id, required String name}) {
    if (_selectedLessonId == id) return;
    _selectedLessonId = id;
    _selectedLessonName = name;
    notifyListeners();
  }

  void backToHub() {
    if (_selectedLessonId == null) return;
    _selectedLessonId = null;
    _selectedLessonName = null;
    notifyListeners();
  }

  void resetToHub() => backToHub();
}
