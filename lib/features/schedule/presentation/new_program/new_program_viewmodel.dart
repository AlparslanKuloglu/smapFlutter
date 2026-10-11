import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/schedule/application/new_program_summary.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';
import 'package:smap/features/schedule/presentation/program_dialogs.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

/// The three steps of the new program flow (pano 3.5 "Adım N/3").
enum NewProgramStep { days, grid, name }

/// The new program flow (pano 3.5 kare 1 to 4; flow 13.3): the days, the hour
/// grid with the topics, the name and the motto, then "Programı Kaydet".
///
/// One screen with three steps, so "Geri her adımda seçimleri korur": nothing
/// is lost by going back. Past days cannot be chosen (the calendar closes
/// them; [toggleDay] ignores them too). Taking a day out of the choice takes
/// its topics with it. A step moves on only when it has what the next needs:
/// a day, then a topic (a program is its topics: one without any has no days
/// on the server).
///
/// Saving creates the program through `ScheduleService.createWeekly`, shows
/// the "Program kaydedildi." toast with the success haptic and closes the flow
/// with the new program's id, which opens the program (pano 13.3). A failure
/// toasts and keeps the form. Leaving with something entered asks "Program
/// kaydedilmesin mi?".
class NewProgramViewModel extends BaseViewModel {
  NewProgramViewModel({
    required ScheduleService schedule,
    required ToastService toast,
    required ProgramDialogs dialogs,
    required ProgramNavigator navigator,
    required ValueListenable<bool> online,
    required String Function(String month, int week) defaultName,
    this.studentId,
    DateTime Function()? clock,
  }) : _schedule = schedule,
       _toast = toast,
       _dialogs = dialogs,
       _navigator = navigator,
       _online = online,
       _defaultName = defaultName,
       _clock = clock ?? DateTime.now;

  /// The student the program is for; `null` for the signed-in user.
  final String? studentId;

  final ScheduleService _schedule;
  final ToastService _toast;
  final ProgramDialogs _dialogs;
  final ProgramNavigator _navigator;
  final ValueListenable<bool> _online;
  final String Function(String month, int week) _defaultName;
  final DateTime Function() _clock;

  NewProgramStep _step = NewProgramStep.days;
  List<DateTime> _days = const [];
  WeeklyDraft _draft = const WeeklyDraft(name: '');
  DateTime? _gridDay;
  String _name = '';
  String _motto = '';
  bool _nameTouched = false;
  bool _nameError = false;
  bool _saving = false;
  bool _disposed = false;

  NewProgramStep get step => _step;

  /// Today, as a calendar day.
  DateTime get today => CalendarMath.dateOnly(_clock());

  /// The chosen days, oldest first.
  List<DateTime> get days => _days;

  /// The day of the grid step.
  DateTime? get gridDay => _gridDay;

  /// Every topic placed so far.
  List<ProgramEntry> get entries => [
    for (final task in _draft.tasks) ProgramEntry.of(task),
  ];

  /// The topics of [day], earliest first.
  List<ProgramEntry> entriesOn(DateTime day) => [
    for (final task in _draft.tasksOn(day)) ProgramEntry.of(task),
  ];

  /// How many topics [day] holds (the "2 konu" under a chip).
  int countOn(DateTime day) => _draft.tasksOn(day).length;

  /// The step's primary button can be pressed.
  bool get canContinue => switch (_step) {
    NewProgramStep.days => _days.isNotEmpty,
    NewProgramStep.grid => _draft.tasks.isNotEmpty,
    NewProgramStep.name => !_saving,
  };

  String get name => _name;
  String get motto => _motto;

  /// The name field shows "Programına bir ad ver." (set by a save with no
  /// name, cleared when the student types).
  bool get nameError => _nameError;

  /// A save is running: the button spins and taps are ignored.
  bool get saving => _saving;

  /// What step 3 summarizes.
  NewProgramSummary get summary => NewProgramSummary.of(_days, entries);

  /// Leaving by the system back has to be asked first: something was entered,
  /// or a later step is open (back goes one step).
  bool get interceptsBack => hasChanges || _step != NewProgramStep.days;

  /// Something was entered: leaving asks first.
  bool get hasChanges =>
      _days.isNotEmpty || _draft.tasks.isNotEmpty || _nameTouched;

  /// Chooses or drops [day]; a past day does nothing.
  void toggleDay(DateTime day) {
    final only = CalendarMath.dateOnly(day);
    if (CalendarMath.isBeforeDay(only, today)) return;
    final has = _days.any((d) => CalendarMath.sameDay(d, only));
    if (has) {
      _days = [
        for (final d in _days)
          if (!CalendarMath.sameDay(d, only)) d,
      ];
      _draft = _draft.withoutDay(only);
    } else {
      _days = CalendarMath.sortedUnique([..._days, only]);
    }
    notifyListeners();
  }

  /// "Devam Et": on to the next step.
  void next() {
    if (!canContinue) return;
    switch (_step) {
      case NewProgramStep.days:
        _step = NewProgramStep.grid;
        final current = _gridDay;
        if (current == null ||
            !_days.any((d) => CalendarMath.sameDay(d, current))) {
          _gridDay = _days.first;
        }
      case NewProgramStep.grid:
        _step = NewProgramStep.name;
        if (!_nameTouched && _name.isEmpty) _name = _suggestedName();
      case NewProgramStep.name:
        return;
    }
    notifyListeners();
  }

  /// Back one step; `false` on the first step, where the caller leaves the
  /// flow ([requestClose]).
  bool back() {
    switch (_step) {
      case NewProgramStep.days:
        return false;
      case NewProgramStep.grid:
        _step = NewProgramStep.days;
      case NewProgramStep.name:
        _step = NewProgramStep.grid;
    }
    notifyListeners();
    return true;
  }

  /// A chip of the grid step.
  void selectGridDay(DateTime day) {
    if (_gridDay != null && CalendarMath.sameDay(_gridDay!, day)) return;
    _gridDay = CalendarMath.dateOnly(day);
    notifyListeners();
  }

  /// An empty hour was tapped: the topic sheet, then the topic is placed with
  /// a short selection haptic.
  Future<void> placeTopic(int hour) async {
    final day = _gridDay;
    if (day == null) return;
    if (_draft.tasksOn(day).any((t) => t.hour == hour)) return;
    final choice = await _dialogs.pickTopic(
      day: day,
      hour: hour,
      placements: placementsOf(entries),
    );
    if (choice == null || _disposed) return;
    AppHaptics.selection();
    _draft = _draft.withTask(choice.toTask(day: day, hour: hour));
    notifyListeners();
  }

  /// The X of a filled slot.
  void removeEntry(ProgramEntry entry) {
    AppHaptics.selection();
    _draft = _draft.withoutTask(entry.id);
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    _nameTouched = true;
    if (_nameError && value.trim().isNotEmpty) _nameError = false;
    notifyListeners();
  }

  void setMotto(String value) {
    _motto = value;
    _nameTouched = true;
  }

  /// "Programı Kaydet".
  Future<void> save() async {
    if (_saving || _step != NewProgramStep.name) return;
    if (_name.trim().isEmpty) {
      _nameError = true;
      AppHaptics.error();
      notifyListeners();
      return;
    }
    _saving = true;
    notifyListeners();
    final result = await _schedule.createWeekly(
      _draft.copyWith(name: _name.trim(), motto: _motto.trim()),
      studentId: studentId,
    );
    if (_disposed) return;
    _saving = false;
    notifyListeners();
    result.fold((_) => _toast.error((l) => l.schedule_saveFailed), (created) {
      _toast.success((l) => l.schedule_toastProgramSaved);
      _navigator.close(created.id);
    });
  }

  /// The X of the first step and the system back there: closes the flow, after
  /// "Program kaydedilmesin mi?" when something was entered.
  Future<void> requestClose() async {
    if (_saving) return;
    if (hasChanges && !await _dialogs.confirmDiscard()) return;
    if (_disposed) return;
    _navigator.close();
  }

  /// `true` while the device has a link.
  bool get online => _online.value;

  String _suggestedName() {
    final first = _days.isEmpty ? today : _days.first;
    final named = ProgramNaming.weekOfMonth(first);
    return _defaultName(named.month, named.week);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
