import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/application/topic_choice.dart';
import 'package:smap/features/schedule/data/schedule_repository.dart';
import 'package:smap/features/schedule/presentation/program_dialogs.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

import '../../../core/network/fake_adapter.dart';
import '../network_harness.dart';
import '../program_fixtures.dart';

/// A tiny stateful backend of the program endpoints: the stored programs, the
/// bag, the lessons' topics and every write it saw.
class ProgramServer {
  ProgramServer({List<Map<String, Object?>>? weeklies})
    : weeklies = weeklies ?? [ekimIkinciHaftaJson()];

  List<Map<String, Object?>> weeklies;
  List<Map<String, Object?>> bag = [
    {
      'student': 's1',
      'mainSubject': 'm-tarih',
      'data': {'_id': 'i1', 'name': 'Tarih Biliminin Tanımı', 'konu': 'k1'},
      'lesson': {
        '_id': kTytTarihId,
        'name': 'TYT Tarih',
        'lessonColor': '#ffeed6',
        'mapImage': 'assets/icons/icon2.png',
      },
    },
  ];
  bool failList = false;
  bool failWrites = false;
  bool failSubjects = false;
  int listCalls = 0;
  int subjectCalls = 0;
  final List<Map<String, Object?>> updates = [];

  /// Every request as `path studentId` (`-` when it carried none): a coach's
  /// calls carry the student's id, a student's carry none.
  final List<String> requests = [];
  final List<Map<String, Object?>> adds = [];
  Completer<void>? holdWrites;

  FakeAdapter get adapter => FakeAdapter((options) async {
    requests.add(
      '${options.path} ${options.queryParameters['studentId'] ?? '-'}',
    );
    switch (options.path) {
      case '/student/getMyWeeklies':
        listCalls++;
        if (failList) return jsonResponse({'success': false});
        return jsonResponse({
          'success': true,
          'weeklies': weeklies,
          'bagItems': bag,
        });
      case '/student/getAllMainSubjects':
        subjectCalls++;
        if (failSubjects) return jsonResponse({'success': false});
        return jsonResponse({
          'success': true,
          'subjectsJson': {
            kTurkceId: [
              {'_id': 'm-noktalama', 'name': 'Noktalama İşaretleri'},
              {'_id': 'm-ogeler', 'name': 'Cümlenin Öğeleri'},
            ],
            kTytTarihId: [
              {'_id': 'm-tarih', 'name': 'Kurtuluş Savaşı Hazırlık Dönemi'},
            ],
          },
        });
      case '/student/addNewProgram':
        if (failWrites) return jsonResponse({'success': false});
        final dataObj = Map<String, Object?>.from(
          (options.data as Map)['dataObj'] as Map,
        );
        adds.add(dataObj);
        final created = {
          '_id': 'w-new-${adds.length}',
          'name': dataObj['name'],
          'motto': dataObj['motto'],
          'content': dataObj['tasks'],
        };
        weeklies = [created, ...weeklies];
        return jsonResponse({'success': true, 'weekly': created});
      case '/student/updateProgram':
        final hold = holdWrites;
        if (hold != null) await hold.future;
        if (failWrites) return jsonResponse({'success': false});
        final dataObj = Map<String, Object?>.from(
          (options.data as Map)['dataObj'] as Map,
        );
        updates.add(dataObj);
        final updated = {
          '_id': dataObj['weeklyId'],
          'name': dataObj['name'],
          'motto': dataObj['motto'],
          'content': dataObj['tasks'],
        };
        weeklies = [
          for (final w in weeklies) w['_id'] == updated['_id'] ? updated : w,
        ];
        return jsonResponse({'success': true, 'weekly': updated});
    }
    return jsonResponse({'success': false}, status: 404);
  });

  /// The tasks of the last update, as `HH:mm title` lines.
  List<String> get lastTasks => [
    for (final task in (updates.last['tasks'] as List).cast<Map>())
      '${task['day']} ${task['hour'].toString().padLeft(2, '0')}:'
          '${task['minute'].toString().padLeft(2, '0')} ${task['title']}',
  ];
}

/// The pieces a ViewModel needs, on one scripted backend.
class ProgramRig {
  ProgramRig({ProgramServer? server, DateTime? now})
    : server = server ?? ProgramServer(),
      now = now ?? DateTime(2026, 10, 10, 9) {
    network = buildNetwork(this.server.adapter);
    schedule = ScheduleService(
      repository: ScheduleRepository(network),
      clock: () => this.now,
    );
    toast = ToastService(presenter: _NoPresenter());
  }

  final ProgramServer server;
  DateTime now;
  late final NetworkService network;
  late final ScheduleService schedule;
  late final ToastService toast;
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);
  final FakeNavigator navigator = FakeNavigator();
  final FakeDialogs dialogs = FakeDialogs();

  /// The toast on screen, as Turkish text; `null` when there is none.
  String? get toastText {
    final entry = toast.slot.current.value;
    return entry?.title(AppLocalizationsTr());
  }

  /// The toast's kind.
  AppToastKind? get toastKind => toast.slot.current.value?.kind;

  /// Presses "Geri Al" of the toast on screen.
  void undo() => toast.slot.current.value!.onUndo!();

  void dispose() {
    schedule.dispose();
    network.dispose();
    toast.dispose();
    online.dispose();
  }
}

class _NoPresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

class FakeNavigator implements ProgramNavigator {
  final List<String> opened = [];
  final List<DateTime?> openedDays = [];
  Object? closedWith;
  bool closed = false;
  int newFlows = 0;
  String? newFlowResult;

  @override
  void openDetail(String programId, {DateTime? day}) {
    opened.add(programId);
    openedDays.add(day);
  }

  @override
  Future<String?> openNewProgram() async {
    newFlows++;
    return newFlowResult;
  }

  @override
  void close([Object? result]) {
    closed = true;
    closedWith = result;
  }
}

class FakeDialogs implements ProgramDialogs {
  bool resetAnswer = true;
  bool cancelAnswer = true;
  bool discardAnswer = true;
  TimeOfDay? time;
  TopicChoice? topic;
  PlacedTopic? slot;
  int resetAsked = 0;
  int discardAsked = 0;
  DateTime? resetDay;
  int? resetCount;
  Map<String, ProgramEntry>? lastPlacements;

  @override
  Future<bool> confirmResetDay({
    required DateTime day,
    required int count,
  }) async {
    resetAsked++;
    resetDay = day;
    resetCount = count;
    return resetAnswer;
  }

  @override
  Future<bool> confirmCancelProgram({required String name}) async =>
      cancelAnswer;

  @override
  Future<bool> confirmDiscard() async {
    discardAsked++;
    return discardAnswer;
  }

  @override
  Future<TimeOfDay?> pickTime({required TimeOfDay initial}) async => time;

  @override
  Future<TopicChoice?> pickTopic({
    required DateTime day,
    required int hour,
    required Map<String, ProgramEntry> placements,
  }) async {
    lastPlacements = placements;
    return topic;
  }

  @override
  Future<PlacedTopic?> pickSlot({
    required DateTime day,
    required List<ProgramEntry> entries,
    required Map<String, ProgramEntry> placements,
  }) async {
    lastPlacements = placements;
    return slot;
  }
}

/// A topic of the "Dersler" list, for the tests that place one.
TopicChoice noktalamaChoice() => const TopicChoice(
  lessonId: kTurkceId,
  lessonName: 'TYT Türkçe',
  title: 'Noktalama İşaretleri',
  mainSubjectId: 'm-noktalama',
  lessonColor: '#F7EDE4',
  mapImage: 'icon1.png',
);
