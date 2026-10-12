import 'package:stacked/stacked.dart';

import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/application/topic_groups.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The two lists of the "Konu ekle" sheet (pano 3.5 kare 3 segment).
enum TopicSource { bag, lessons }

/// The logic of the "Konu ekle" sheet (pano 3.5 kare 3): "Çantam" (the topics
/// the exams left missing, grouped by lesson) and "Dersler" (every topic of
/// every lesson), one radio choice and "Ekle".
///
/// "Çantam" comes with the programs (`ScheduleService.load`); "Dersler" is
/// loaded the first time its segment opens (`ScheduleService.mainSubjects`,
/// cached for the session). Both run under the 15 s skeleton limit and fail
/// into an error with "Tekrar Dene". A topic already in the program is
/// marked "Programda: Pzt 10:00" but can be picked again.
class TopicPickerViewModel extends BaseViewModel {
  TopicPickerViewModel({
    required ScheduleService schedule,
    required this.placements,
    this.studentId,
    this.studentFirstName,
    TopicSource initial = TopicSource.bag,
  }) : _schedule = schedule,
       _source = initial;

  final ScheduleService _schedule;

  /// Where each topic already sits in the program, by `TopicChoice.key`.
  final Map<String, ProgramEntry> placements;

  /// The student whose bag and lessons these are; `null` for the user's own.
  final String? studentId;

  /// The student's first name in a coach's view (the sheet names the student
  /// and leaves out the "Eksik" tag: the bag has no such field, Tur 12 A);
  /// `null` for the user's own.
  final String? studentFirstName;

  /// A coach writes a student's program.
  bool get isCoachView => studentId != null;

  TopicSource _source;
  AsyncSection<List<TopicGroup>> _bag =
      const AsyncSection<List<TopicGroup>>.loading();
  AsyncSection<List<TopicGroup>> _lessons =
      const AsyncSection<List<TopicGroup>>.loading();
  bool _lessonsRequested = false;
  TopicChoice? _selected;
  bool _disposed = false;

  TopicSource get source => _source;

  /// The state and groups of the list on screen.
  AsyncSection<List<TopicGroup>> get shown =>
      _source == TopicSource.bag ? _bag : _lessons;

  AsyncSection<List<TopicGroup>> get bag => _bag;
  AsyncSection<List<TopicGroup>> get lessons => _lessons;

  /// The picked topic; `null` until one is picked.
  TopicChoice? get selected => _selected;

  /// Whether the topic with [key] is the picked one.
  bool isSelected(String key) => _selected?.key == key;

  /// Where [choice] already sits in the program, if anywhere.
  ProgramEntry? placedAt(TopicChoice choice) => placements[choice.key];

  /// Loads "Çantam", and "Dersler" when it is the first segment.
  Future<void> init() async {
    await _loadBag();
    if (_source == TopicSource.lessons) await _loadLessons();
  }

  /// A segment was picked.
  Future<void> setSource(TopicSource value) async {
    if (value == _source) return;
    _source = value;
    notifyListeners();
    if (value == TopicSource.lessons && !_lessonsRequested) {
      await _loadLessons();
    }
  }

  /// A radio row was tapped.
  void select(TopicChoice choice) {
    if (_selected?.key == choice.key) return;
    _selected = choice;
    notifyListeners();
  }

  /// "Tekrar Dene" of the list on screen.
  Future<void> retry() => _source == TopicSource.bag
      ? _loadBag(force: true)
      : _loadLessons(force: true);

  Future<void> _loadBag({bool force = false}) async {
    if (_schedule.snapshot(studentId: studentId) == null || force) {
      _bag = const AsyncSection<List<TopicGroup>>.loading();
      notifyListeners();
    }
    final result = await AsyncSection.load<List<TopicGroup>>(() async {
      final answer = await _schedule.load(
        studentId: studentId,
        forceRefresh: force,
      );
      return answer.fold(
        (failure) => throw failure,
        (snapshot) => TopicGroups.bag(snapshot.bagItems),
      );
    }, isEmpty: (groups) => groups.isEmpty);
    if (_disposed) return;
    _bag = result;
    notifyListeners();
  }

  Future<void> _loadLessons({bool force = false}) async {
    _lessonsRequested = true;
    _lessons = const AsyncSection<List<TopicGroup>>.loading();
    notifyListeners();
    final result = await AsyncSection.load<List<TopicGroup>>(() async {
      final answer = await _schedule.mainSubjects(
        studentId: studentId,
        forceRefresh: force,
      );
      return answer.fold((failure) => throw failure, TopicGroups.lessons);
    }, isEmpty: (groups) => groups.isEmpty);
    if (_disposed) return;
    _lessons = result;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
