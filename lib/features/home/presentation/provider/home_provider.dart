import 'package:flutter/foundation.dart';
import 'package:smap/domain/models/general_lessons.dart';
import 'package:smap/domain/models/student_model.dart';
import 'package:smap/repository/home_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeProvider extends ChangeNotifier {
  HomeProvider({HomeRepository? repository})
    : _repository = repository ?? HomeRepository(),
      _state = HomeState(
        focusedMonth: DateTime(DateTime.now().year, DateTime.now().month),
      );

  final HomeRepository _repository;

  HomeState _state;
  HomeState get state => _state;

  void prevMonth() {
    _updateState(
      HomeState(
        focusedMonth: DateTime(
          state.focusedMonth.year,
          state.focusedMonth.month - 1,
        ),
      ),
    );
  }

  void nextMonth() {
    _updateState(
      HomeState(
        focusedMonth: DateTime(
          state.focusedMonth.year,
          state.focusedMonth.month + 1,
        ),
      ),
    );
  }

  void _updateState(HomeState newState) {
    _state = newState;
    notifyListeners();
  }

  List<GeneralLesson> _lessons = [];
  bool _isLoading = false;
  String? _error;

  List<GeneralLesson> get lessons => _lessons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Student> _coachStudents =
      []; // Varsa StudentModel listen, yoksa dynamic/Map yapabilirsin
  List<Student> get coachStudents => _coachStudents;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user_data');

      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        String userRole = userData['role'];
        if (userRole == 'student') {
          final results = await Future.wait([
            _repository.fetchGeneralLessons(),
            _repository.fetchLessonsTotalMissing(),
          ]);

          final List<GeneralLesson> rawLessons =
              results[0] as List<GeneralLesson>;
          final Map<String, dynamic> statsMap =
              results[1] as Map<String, dynamic>;

          // Her ders için statsMap içinde o dersin ID'sine karşılık gelen bir veri var mı bakıyoruz.
          _lessons = rawLessons.map((lesson) {
            if (statsMap.containsKey(lesson.id)) {
              // copyWith metodu ile dersin içine stats JSON'ını gömüyoruz
              return lesson.copyWith(stats: statsMap[lesson.id]);
            }
            return lesson;
          }).toList();
        } else if (userRole == 'coach') {
          // --- KOÇ İÇİN ÖĞRENCİLERİ ÇEKİYORUZ ---
          // Repository'ne koçun öğrencilerini getiren bir metot eklemelisin
          final studentsResult = await _repository.fetchMyStudents();
          _coachStudents = studentsResult;
        }
      }
    } catch (e) {
      _error = "Veriler güncellenirken bir sorun oluştu: $e";
      print(e); // Debug için hatayı konsola yazdırıyoruz
    } finally {
      print("home provider 106");
      _isLoading = false;
      notifyListeners();
    }
  }

  void addStudentToLocalList(Student newStudent) {
    // coachStudents listen bir final List ise ve değiştirilemiyorsa:
    // _coachStudents = [..._coachStudents, newStudent];

    // Eğer normal bir List ise:
    coachStudents.add(newStudent);

    notifyListeners(); // Arayüzün güncellenmesini sağlar
  }
}

class HomeState {
  const HomeState({required this.focusedMonth});

  final DateTime focusedMonth;
}
