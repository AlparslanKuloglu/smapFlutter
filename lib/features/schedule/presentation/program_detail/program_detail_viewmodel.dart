import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stacked/stacked.dart';

import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/schedule/application/program_detail.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/program_span.dart';
import 'package:smap/features/schedule/application/program_view_preference.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/application/schedule_snapshot.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';
import 'package:smap/features/schedule/presentation/program_dialogs.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';

/// The screen of one program: Gün and Hafta views, edit mode (pano 3.4 kare 3
/// and 4, 3.6, 3.8; flow 13.3).
///
/// **Loading.** The program is read from `ScheduleService` (a program saved a
/// moment ago, or already listed, is there at once) under the 15 s skeleton
/// limit; a failure is [SectionState.error] or [SectionState.offline] with
/// "Tekrar Dene".
///
/// **Instant save** (spec §6.2 6.9; "Bitti yalnız modu kapatır"). The server
/// has no partial update, so every change replaces the whole program: the
/// change is applied to the screen's draft at once and the whole draft is sent
/// ([ScheduleService.updateWeekly], which keeps writes in order). Changes made
/// while a save runs are sent in the next one. If a save fails the screen goes
/// back to the last saved state and a toast says so. Removing a topic and
/// "Günü Sıfırla" show a "Geri Al" toast for 6 s that puts the topics back
/// (the server has no reset or undo endpoint: the reset is a local edit that
/// is saved like any other).
///
/// **Offline.** The saved program can be read; "Düzenle", the edit actions and
/// "Günü Sıfırla" need a connection and are off without one.
///
/// **Coach.** [readOnly] hides the edit actions (pano 3.4: "Koçta salt
/// okunur"); [studentId] reads that student's program.
class ProgramDetailViewModel extends BaseViewModel {
  ProgramDetailViewModel({
    required this.programId,
    required ScheduleService schedule,
    required ToastService toast,
    required ProgramDialogs dialogs,
    required ProgramNavigator navigator,
    required ValueListenable<bool> online,
    required ProgramViewPreference preference,
    this.studentId,
    this.readOnly = false,
    this.requestedDay,
    this.requestedMode,
    this.deleteProgram,
    DateTime Function()? clock,
  }) : _schedule = schedule,
       _toast = toast,
       _dialogs = dialogs,
       _navigator = navigator,
       _online = online,
       _preference = preference,
       _clock = clock ?? DateTime.now,
       _mode = requestedMode ?? preference.read() {
    _online.addListener(_onConnectivity);
  }

  /// The program's id.
  final String programId;

  /// The student whose program this is; `null` for the signed-in user's own.
  final String? studentId;

  /// No edit actions (a coach reads a student's program).
  final bool readOnly;

  /// The day the route asked to open on.
  final DateTime? requestedDay;

  /// The view the route asked for.
  final ProgramViewMode? requestedMode;

  /// Deletes a program on the server. The backend has no such endpoint yet
  /// (spec §6.3 #25), so nothing is given today and "Programı İptal Et" is
  /// not drawn; see [canCancel].
  final Future<AppResult<void>> Function(String programId)? deleteProgram;

  final ScheduleService _schedule;
  final ToastService _toast;
  final ProgramDialogs _dialogs;
  final ProgramNavigator _navigator;
  final ValueListenable<bool> _online;
  final ProgramViewPreference _preference;
  final DateTime Function() _clock;

  AsyncSection<ProgramDetail> _section =
      const AsyncSection<ProgramDetail>.loading();
  ProgramViewMode _mode;
  bool _editing = false;
  DateTime? _selected;
  WeeklyDraft? _draft;
  WeeklyDraft? _confirmed;
  ProgramSpan? _span;
  bool _loading = false;
  bool _flushing = false;
  bool _dirty = false;
  bool _disposed = false;

  /// The loaded program as the screen shows it, with the changes the server
  /// has not confirmed yet.
  AsyncSection<ProgramDetail> get section => _section;

  /// The program; `null` until it is loaded.
  ProgramDetail? get detail => _section.data;

  ProgramViewMode get mode => _mode;

  /// Edit mode is on.
  bool get editing => _editing;

  /// `true` while the device has a link.
  bool get online => _online.value;

  /// Today, as a calendar day.
  DateTime get today => CalendarMath.dateOnly(_clock());

  /// The day of the Gün view.
  DateTime get selectedDay => _selected ?? today;

  /// The student may change this program at all.
  bool get canEdit => !readOnly;

  /// The student may change it now: not read only and online.
  bool get canEditNow => canEdit && online && detail != null;

  /// "Programı İptal Et" is drawn: the flag is on and a delete exists.
  bool get canCancel =>
      canEdit && FeatureFlags.programDeleteEnabled && deleteProgram != null;

  /// Loads the program, or reads it from the session's cache.
  Future<void> load({bool force = false}) async {
    if (_loading) return;
    _loading = true;
    if (_draft == null) {
      _section = const AsyncSection<ProgramDetail>.loading();
      notifyListeners();
    }
    final result = await AsyncSection.load<ScheduleSnapshot>(() async {
      final answer = await _schedule.load(
        studentId: studentId,
        forceRefresh: force,
      );
      return answer.fold((failure) => throw failure, (snapshot) => snapshot);
    });
    _loading = false;
    if (_disposed) return;
    final snapshot = result.data;
    if (snapshot == null) {
      _section = AsyncSection.failed<ProgramDetail>(result.error ?? 'failed');
      notifyListeners();
      return;
    }
    final weekly = snapshot.weeklyById(programId);
    if (weekly == null) {
      _section = const AsyncSection<ProgramDetail>.error('not listed');
      notifyListeners();
      return;
    }
    if (_draft == null || !_flushing && !_dirty) {
      final draft = weekly.toDraft();
      _draft = draft;
      _confirmed = draft;
      _rebuild();
      _selected ??= detail!.openingDay(today: today, requested: requestedDay);
    }
    notifyListeners();
  }

  /// "Tekrar Dene": back to the skeleton and a new request.
  Future<void> retry() => load(force: true);

  /// The Gün / Hafta segment. The week grid has no edit mode, so switching to
  /// it closes edit mode.
  void setMode(ProgramViewMode value) {
    if (value == _mode) return;
    _mode = value;
    if (value == ProgramViewMode.week) _editing = false;
    unawaited(_preference.write(value));
    notifyListeners();
  }

  /// A chip of the day strip.
  void selectDay(DateTime day) {
    final next = CalendarMath.dateOnly(day);
    if (_selected != null && CalendarMath.sameDay(_selected!, next)) return;
    _selected = next;
    notifyListeners();
  }

  /// "Düzenle": edit mode works on the Gün view.
  void startEditing() {
    if (!canEditNow || _editing) return;
    _editing = true;
    _mode = ProgramViewMode.day;
    notifyListeners();
  }

  /// "Bitti": only closes edit mode; everything is already saved.
  void finishEditing() {
    if (!_editing) return;
    _editing = false;
    notifyListeners();
  }

  /// The X of an item: takes the topic out and offers "Geri Al" for 6 s.
  void removeEntry(ProgramEntry entry) {
    final draft = _draft;
    if (!canEditNow || draft == null) return;
    final task = draft.tasks.where((t) => t.id == entry.id).firstOrNull;
    if (task == null) return;
    AppHaptics.selection();
    _apply(draft.withoutTask(task.id));
    _toast.undo(
      (l) => l.schedule_toastTopicRemoved,
      onUndo: () => _restore([task]),
    );
  }

  /// The underlined time of an item: the time wheel, then the new time is
  /// saved.
  Future<void> changeTime(ProgramEntry entry) async {
    if (!canEditNow) return;
    final picked = await _dialogs.pickTime(
      initial: TimeOfDay(hour: entry.hour, minute: entry.minute),
    );
    final draft = _draft;
    if (picked == null || _disposed || draft == null || !canEditNow) return;
    if (picked.hour == entry.hour && picked.minute == entry.minute) return;
    AppHaptics.selection();
    _apply(
      draft.withTaskTime(entry.id, hour: picked.hour, minute: picked.minute),
    );
  }

  /// "Konu Ekle": the hour grid of the selected day, a topic for an empty hour,
  /// and the topic is saved.
  Future<void> addTopic() async {
    final current = detail;
    if (!canEditNow || current == null) return;
    final day = selectedDay;
    final placed = await _dialogs.pickSlot(
      day: day,
      entries: current.entriesOn(day),
      placements: current.placements,
    );
    final draft = _draft;
    if (placed == null || _disposed || draft == null || !canEditNow) return;
    AppHaptics.selection();
    _apply(draft.withTask(placed.choice.toTask(day: day, hour: placed.hour)));
  }

  /// "Günü Sıfırla": asks, then takes every topic of the selected day out and
  /// offers "Geri Al" for 6 s. Nothing happens on an empty day.
  Future<void> resetDay() async {
    final draft = _draft;
    if (!canEditNow || draft == null) return;
    final day = selectedDay;
    final tasks = draft.tasksOn(day);
    if (tasks.isEmpty) return;
    final confirmed = await _dialogs.confirmResetDay(
      day: day,
      count: tasks.length,
    );
    final latest = _draft;
    if (!confirmed || _disposed || latest == null || !canEditNow) return;
    AppHaptics.selection();
    _apply(latest.withoutDay(day));
    _toast.undo(
      (l) => l.schedule_toastDayReset(TrFormat.gunAdi(day)),
      onUndo: () => _restore(tasks),
    );
  }

  /// "Programı İptal Et" (only while [canCancel]): asks, deletes, goes back to
  /// the list.
  Future<void> cancelProgram() async {
    final delete = deleteProgram;
    final current = detail;
    if (!canCancel || delete == null || current == null || !online) return;
    final confirmed = await _dialogs.confirmCancelProgram(name: current.name);
    if (!confirmed || _disposed) return;
    final result = await delete(programId);
    if (_disposed) return;
    result.fold((_) => _toast.error((l) => l.schedule_saveFailed), (_) {
      _toast.success((l) => l.schedule_toastProgramCancelled);
      _schedule.invalidate(studentId: studentId);
      _navigator.close();
    });
  }

  void _restore(List<ProgramTaskDraft> tasks) {
    final draft = _draft;
    if (_disposed || draft == null) return;
    var next = draft;
    for (final task in tasks) {
      next = next.withTask(task);
    }
    AppHaptics.selection();
    _apply(next);
  }

  void _apply(WeeklyDraft next) {
    _draft = next;
    _rebuild();
    notifyListeners();
    unawaited(_flush());
  }

  void _rebuild() {
    final draft = _draft;
    if (draft == null) return;
    final built = ProgramDetail.of(
      id: programId,
      draft: draft,
      today: today,
      keepSpan: _span,
    );
    _span = built.span;
    _section = AsyncSection<ProgramDetail>.ready(built);
  }

  /// Sends the draft; changes made meanwhile go in the next round. A failure
  /// returns the screen to the last confirmed state.
  Future<void> _flush() async {
    if (_flushing) {
      _dirty = true;
      return;
    }
    _flushing = true;
    try {
      do {
        _dirty = false;
        final sending = _draft;
        if (sending == null || sending == _confirmed) break;
        final result = await _schedule.updateWeekly(
          programId,
          sending,
          studentId: studentId,
        );
        if (_disposed) return;
        final failed = result.fold((_) => true, (_) => false);
        if (failed) {
          _draft = _confirmed;
          _dirty = false;
          _rebuild();
          notifyListeners();
          _toast.error((l) => l.schedule_saveFailed);
        } else {
          _confirmed = sending;
        }
      } while (_dirty);
    } finally {
      _flushing = false;
    }
  }

  void _onConnectivity() {
    if (_online.value && _section.isOffline) unawaited(load(force: true));
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _online.removeListener(_onConnectivity);
    super.dispose();
  }
}
