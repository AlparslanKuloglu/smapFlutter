import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/cards/domain/card_totals.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_rows.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/presentation/lessons/sheets/web_only_sheet.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// What the list of Derslerim draws: the state and, when it is
/// [SectionState.ready], the rows (a selector value, equal by content).
@immutable
class LessonsListData {
  const LessonsListData(this.state, [this.rows = const []]);

  final SectionState state;
  final List<LessonRow> rows;

  @override
  bool operator ==(Object other) =>
      other is LessonsListData &&
      other.state == state &&
      listEquals(other.rows, rows);

  @override
  int get hashCode => Object.hash(state, Object.hashAll(rows));
}

/// Opens a link outside the app (`url_launcher`); `false` when it could not.
typedef UrlOpener = Future<bool> Function(Uri uri);

/// Opens the "Web'de" sheet of [row] and answers whether "Web'de Aç" was
/// pressed.
typedef WebSheetOpener = Future<bool> Function(LessonRow row, String host);

Future<bool> _showWebSheet(LessonRow row, String host) =>
    WebOnlySheet.show(subject: row.subject, host: host);

/// The logic of Derslerim (pano 7.1, 7.5 kare 1 and 4; spec §4.F 7.1).
///
/// - The lessons and their counts come from the session's [LessonsService];
///   this screen only shows them, so a lesson learned elsewhere lowers the
///   count here at once. The first load is bounded by 15 s: after that the
///   skeleton gives way to the error state (a late answer still fills the
///   list).
/// - The deck counters (`getInfoCardsInfo`) load on the side: a failure only
///   leaves the card progress out, it never fails the list.
/// - TYT or AYT is kept on the device (karar 5.8).
/// - Offline, the web-only lessons are left out of the list (karar 5.9).
/// - A row opens Ders Detayı on its own category; a "Web'de" row opens the
///   sheet, and its button opens the site.
class LessonsViewModel extends ReactiveViewModel {
  LessonsViewModel({
    required LessonsService lessons,
    required CardRepository cards,
    required DevicePreferences preferences,
    required ValueListenable<bool> online,
    required Uri webUri,
    required LessonsNavigator navigator,
    required UrlOpener openUrl,
    WebSheetOpener webSheet = _showWebSheet,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _lessons = lessons,
       _cards = cards,
       _preferences = preferences,
       _online = online,
       _webUri = webUri,
       _navigator = navigator,
       _openUrl = openUrl,
       _webSheet = webSheet,
       _timeout = timeout,
       _examType = LessonsExamType.fromKey(
         preferences.getString(DevicePreferences.lessonsExamTypeKey),
       );

  final LessonsService _lessons;
  final CardRepository _cards;
  final DevicePreferences _preferences;
  final ValueListenable<bool> _online;
  final Uri _webUri;
  final LessonsNavigator _navigator;
  final UrlOpener _openUrl;
  final WebSheetOpener _webSheet;
  final Duration _timeout;

  LessonsExamType _examType;
  CardTotals _cardTotals = const CardTotals.empty();
  bool _settled = false;
  bool _started = false;
  bool _disposed = false;
  LessonsListData? _list;

  @override
  List<ListenableServiceMixin> get listenableServices => [_lessons];

  /// TYT or AYT, the choice of the band's segment.
  LessonsExamType get examType => _examType;

  /// The site's address as the "Web'de" sheet writes it ("smaptr.com").
  String get webHost {
    final host = _webUri.host;
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  /// The list section: skeleton, rows or the error state.
  LessonsListData get list => _list ??= _buildList();

  LessonsListData _buildList() {
    final entries = _lessons.entries;
    if (entries.isNotEmpty) {
      final rows = LessonRows.build(
        entries: entries,
        examType: _examType,
        cards: _cardTotals,
        online: _online.value,
      );
      if (rows.isNotEmpty) return LessonsListData(SectionState.ready, rows);
    }
    if (!_settled) return const LessonsListData(SectionState.loading);
    final error = _lessons.error;
    return LessonsListData(
      error != null && error.isOffline
          ? SectionState.offline
          : SectionState.error,
    );
  }

  @override
  void notifyListeners() {
    _list = null;
    super.notifyListeners();
  }

  /// Starts loading; the view calls it once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    _online.addListener(_onOnlineChanged);
    unawaited(_loadCards());
    await _load();
  }

  /// "Tekrar Dene": back to the skeleton and ask again.
  Future<void> retry() async {
    _settled = false;
    notifyListeners();
    unawaited(_loadCards());
    await _load(force: true);
  }

  Future<void> _load({bool force = false}) async {
    try {
      await withSkeletonTimeout(
        force ? _lessons.refresh() : _lessons.load(),
        timeout: _timeout,
      );
    } on TimeoutException {
      // The skeleton gives way to the error state; a late answer still
      // arrives through the service.
    }
    if (_disposed) return;
    _settled = true;
    notifyListeners();
  }

  Future<void> _loadCards() async {
    final result = await _cards.getTotals();
    if (_disposed) return;
    // A failure leaves the card progress out; the list does not depend on it.
    _cardTotals = result.rightOrNull ?? _cardTotals;
    notifyListeners();
  }

  void _onOnlineChanged() => notifyListeners();

  /// The segment changed: the list follows and the choice is kept.
  void selectExamType(LessonsExamType type) {
    if (type == _examType) return;
    _examType = type;
    unawaited(
      _preferences.setString(DevicePreferences.lessonsExamTypeKey, type.key),
    );
    notifyListeners();
  }

  /// A row was pressed: its lesson opens, or the web sheet for a web-only
  /// one.
  Future<void> openRow(LessonRow row) async {
    if (row.webOnly) {
      final open = await _webSheet(row, webHost);
      if (open) await _openUrl(_webUri);
      return;
    }
    await _navigator.openLesson(row.lessonId, cat: row.cat);
  }

  @override
  void dispose() {
    _disposed = true;
    _online.removeListener(_onOnlineChanged);
    super.dispose();
  }
}
