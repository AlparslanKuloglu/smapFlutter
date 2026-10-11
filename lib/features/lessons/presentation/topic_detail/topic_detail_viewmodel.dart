import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/cards/data/card_repository.dart';
import 'package:smap/features/lessons/application/general_lesson_spec.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/application/lesson_category.dart';
import 'package:smap/features/lessons/application/lesson_segments.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/application/topic_loader.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';
import 'package:smap/features/lessons/presentation/lessons_navigator.dart';
import 'package:smap/features/lessons/presentation/topic_detail/sheets/card_sheet.dart';
import 'package:smap/features/lessons/presentation/topic_detail/topic_detail_state.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of Konu Detayı (pano 7.3, 7.5 kare 3, 7.6; spec §4.F 7.3).
///
/// - **Loading.** The link carries the ids only, so the [TopicLoader] finds
///   the topic in its lesson (the track of the link, else the device's last
///   exam type) and reads its sub-topics and items under that category. The
///   first load is bounded by 15 s, then the error state shows; the Back button
///   is always there.
/// - **Opening.** With `focus=firstMissing` the first sub-topic that holds a
///   missing item is open, its first missing item is open and the screen
///   scrolls to it ([focusRequest], 350 ms in the view); without it the first
///   sub-topic opens and nothing scrolls.
/// - **"Öğrendim"** (from the card sheet): the item turns learned at once,
///   `learnedItem` goes out and a failure puts it back with a toast. There
///   is no undo on the server. The session's lesson counts are read again
///   afterwards.
/// - **Star.** `addFavoriteMobil` is a toggle; the item's own flag is flipped
///   after it succeeds.
class TopicDetailViewModel extends BaseViewModel {
  TopicDetailViewModel({
    required this.lessonId,
    required this.topicId,
    required LessonsService lessons,
    required LessonContentRepository content,
    required CardRepository cards,
    required DevicePreferences preferences,
    required ToastService toast,
    String? focus,
    LessonCat? cat,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _lessons = lessons,
       _content = content,
       _cards = cards,
       _preferences = preferences,
       _toast = toast,
       _wantsFocus = focus == TopicFocus.firstMissing,
       _cat = cat,
       _timeout = timeout,
       _loader = TopicLoader(content);

  final String lessonId;
  final String topicId;

  final LessonsService _lessons;
  final LessonContentRepository _content;
  final CardRepository _cards;
  final DevicePreferences _preferences;
  final ToastService _toast;
  final bool _wantsFocus;
  final LessonCat? _cat;
  final Duration _timeout;
  final TopicLoader _loader;

  SectionState _state = SectionState.loading;
  TopicHeaderData? _headerBase;
  TopicOutline _outline = const TopicOutline([]);
  String? _initialOpenSubTopic;
  String? _initialOpenItem;
  bool _started = false;
  bool _disposed = false;
  final ValueNotifier<FocusTarget?> _focusRequest = ValueNotifier<FocusTarget?>(
    null,
  );

  /// Set once when the content has loaded and the first missing item is to
  /// be shown: the view scrolls to it.
  ValueListenable<FocusTarget?> get focusRequest => _focusRequest;

  /// The title block; `null` while loading or after a failure.
  TopicHeaderData? get header {
    final base = _headerBase;
    if (base == null) return null;
    return TopicHeaderData(
      topicName: base.topicName,
      lessonName: base.lessonName,
      isLiterature: base.isLiterature,
      trackLabel: base.trackLabel,
      number: base.number,
      subTopicCount: _outline.subTopics.length,
      itemCount: _outline.itemCount,
    );
  }

  /// The topic's name for the bar; empty until it is known.
  String get title => _headerBase?.topicName ?? '';

  /// The content section.
  TopicBodyData get body =>
      TopicBodyData(_state, [for (final sub in _outline.subTopics) sub.id]);

  /// The sub-topic [id], `null` for an unknown one.
  SubTopicView? subTopic(String id) {
    for (final sub in _outline.subTopics) {
      if (sub.id == id) return sub;
    }
    return null;
  }

  /// Whether the sub-topic [id] opens with the screen.
  bool opensInitially(String id) => id == _initialOpenSubTopic;

  /// The key of the item that opens with the screen.
  String? get initialOpenItem => _initialOpenItem;

  /// Loads the topic; the view calls it once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    unawaited(_lessons.load().catchError((Object _) {}));
    await _load();
  }

  /// "Tekrar Dene": back to the skeleton and ask again.
  Future<void> retry() async {
    _state = SectionState.loading;
    notifyListeners();
    await _load();
  }

  Future<void> _load() async {
    final section = await AsyncSection.load<TopicContent>(
      _fetch,
      timeout: _timeout,
    );
    if (_disposed) return;
    final content = section.data;
    if (content == null) {
      _state = section.isOffline ? SectionState.offline : SectionState.error;
      notifyListeners();
      return;
    }
    final lesson = _lesson!;
    _outline = TopicOutline.of(content.subSubjects);
    _headerBase = TopicHeaderData(
      topicName: content.topicName,
      lessonName: lesson.name,
      isLiterature: lesson.isLiterature,
      trackLabel: _trackLabel(lesson, content.cat),
      number: content.number,
      subTopicCount: 0,
      itemCount: 0,
    );
    final target = _wantsFocus ? _outline.firstMissing : null;
    _initialOpenSubTopic = target?.subTopicId ?? _outline.initiallyOpenSubTopic;
    _initialOpenItem = target?.itemKey;
    _state = _outline.isEmpty ? SectionState.empty : SectionState.ready;
    notifyListeners();
    if (target != null) _focusRequest.value = target;
  }

  GeneralLesson? get _lesson =>
      _lessons.entryOf(lessonId)?.lesson ??
      LessonCatalog.byId(lessonId)?.toGeneralLesson();

  Future<TopicContent> _fetch() async {
    final lesson = _lesson;
    if (lesson == null) {
      throw const AppException(
        code: AppErrorCode.notFound,
        message: 'Unknown lesson',
      );
    }
    final saved = LessonsExamType.fromKey(
      _preferences.getString(DevicePreferences.lessonsExamTypeKey),
    ).cat;
    final result = await _loader.load(
      lesson: lesson,
      topicId: topicId,
      cat: _cat,
      saved: saved,
    );
    return result.fold(
      (AppException failure) => throw failure,
      (content) => content,
    );
  }

  static String? _trackLabel(GeneralLesson lesson, LessonCat cat) {
    final track = cat.track;
    return track == null ? null : LessonSegments.labelOf(track);
  }

  // ── Actions ──

  /// "Kartı Aç": the card sheet of the item. Its "Öğrendim" (after the
  /// one-time confirmation) marks the item learned.
  Future<void> openCard(String itemKey) async {
    final item = _outline.itemOf(itemKey);
    final base = _headerBase;
    if (item == null || base == null || !item.hasCard) return;
    final skipConfirm =
        _preferences.getBool(DevicePreferences.skipLearnedConfirmKey) ?? false;
    final result = await CardSheet.show(
      item: item,
      contextLine: (l) => l.cardSheet_context(
        base.isLiterature ? l.lessons_literatureName : base.lessonName,
        base.topicName,
      ),
      askConfirm: !skipConfirm,
      onFavorite: (favorite) => setFavorite(itemKey, favorite),
    );
    if (result == null || !result.learned) return;
    if (result.dontAskAgain) {
      unawaited(
        _preferences.setBool(DevicePreferences.skipLearnedConfirmKey, true),
      );
    }
    await learnItem(itemKey);
  }

  /// Marks the item [itemKey] learned: optimistic, put back with a toast when
  /// the request fails.
  Future<void> learnItem(String itemKey) async {
    final item = _outline.itemOf(itemKey);
    if (item == null || !item.canLearn) return;
    _changeItem(itemKey, (i) => i.copyWith(card: ItemCardState.learned));
    final answer = await _content.markItemLearned(itemId: item.progressId!);
    if (_disposed) return;
    if (answer.isLeft()) {
      _changeItem(itemKey, (i) => i.copyWith(card: ItemCardState.missing));
      _toast.error((l) => l.lessons_sendFailed);
      return;
    }
    AppHaptics.success();
    unawaited(_lessons.refresh().catchError((Object _) {}));
  }

  /// Sets the star of the item [itemKey]; `false` when the request failed
  /// (the item keeps its star).
  Future<bool> setFavorite(String itemKey, bool favorite) async {
    final item = _outline.itemOf(itemKey);
    if (item == null || !item.canFavorite) return false;
    if (item.isFavorite == favorite) return true;
    final answer = await _cards.toggleFavorite(itemId: item.itemId!);
    if (_disposed) return false;
    if (answer.isLeft()) {
      _toast.error((l) => l.lessons_sendFailed);
      return false;
    }
    _changeItem(itemKey, (i) => i.copyWith(isFavorite: favorite));
    return true;
  }

  void _changeItem(String itemKey, ItemView Function(ItemView) change) {
    _outline = _outline.withItem(itemKey, change);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _focusRequest.dispose();
    super.dispose();
  }
}
