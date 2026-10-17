import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/application/literature_service.dart';
import 'package:smap/features/lessons/application/literature_tree.dart';
import 'package:smap/features/lessons/presentation/literature/era_detail/era_detail_state.dart';
import 'package:smap/features/lessons/presentation/literature/sheets/author_sheet.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of the era detail (pano 14.5 kare 2 and 3, 14.7 kare 1 and 2;
/// route `/lessons/:lessonId/literature/:eraId`).
///
/// - **Sections.** The era's name and count come from the service's era list,
///   the accordions from its sub-subjects, and the authors of each accordion
///   from its own read: opened accordions load their authors, and a failure
///   stays inside that accordion ("Yazarlar yüklenemedi." + "Tekrar Dene")
///   while the others work. Everything cached shows at once and is read again
///   quietly.
/// - **Opening.** The first accordion with a missing work opens, its authors
///   load and the page scrolls to it ([focusRequest]; 350 ms in the view, a
///   jump under "Reduce motion"). With nothing missing the first one opens
///   and nothing scrolls. The student opens and closes the others by hand.
/// - **Counts.** Every number is the service's, so "Öğrendim" in the author
///   sheet lowers this screen's tag, the accordion's tag and the author row
///   while the sheet is still open.
class EraDetailViewModel extends ReactiveViewModel {
  EraDetailViewModel({required this.eraId, required LiteratureService service})
    : _service = service;

  /// The era's id (the route's `:eraId`).
  final String eraId;

  final LiteratureService _service;

  final Set<String> _open = {};
  bool _initialOpenDone = false;
  bool _started = false;
  bool _disposed = false;
  final ValueNotifier<EraFocusTarget?> _focusRequest =
      ValueNotifier<EraFocusTarget?>(null);

  @override
  List<ListenableServiceMixin> get listenableServices => [_service];

  /// Set once when the first accordion with something missing is open: the
  /// view scrolls to it.
  ValueListenable<EraFocusTarget?> get focusRequest => _focusRequest;

  LiteratureEra? get _era => _service.eraOf(eraId);

  List<LiteratureSub> get _subs =>
      _service.subsOf(eraId).data ?? const <LiteratureSub>[];

  /// The era's name for the bar; empty until it is known.
  String get title => _era?.name ?? '';

  EraHeaderData get header =>
      EraHeaderData(name: _era?.name, missing: _era?.missing);

  /// The section under the title. The era must be known to be titled: a
  /// failed era list is the screen's failure, and so is an unknown era.
  EraBodyData get body {
    final eras = _service.state.eras;
    final subs = _service.subsOf(eraId);
    if (_era == null) {
      if (eras.isLoading) return const EraBodyData(SectionState.loading);
      return const EraBodyData(SectionState.error);
    }
    return switch (subs.state) {
      SectionState.ready => EraBodyData(SectionState.ready, [
        for (final sub in _subs) sub.id,
      ]),
      SectionState.empty => const EraBodyData(SectionState.empty),
      SectionState.loading => const EraBodyData(SectionState.loading),
      SectionState.error ||
      SectionState.offline => const EraBodyData(SectionState.error),
    };
  }

  /// The header of the accordion [id]; `null` for an unknown one.
  SubCardData? subCard(String id) {
    for (final sub in _subs) {
      if (sub.id == id) {
        return SubCardData(
          id: sub.id,
          name: sub.name,
          open: _open.contains(sub.id),
          missing: sub.missing,
        );
      }
    }
    return null;
  }

  /// The inside of the accordion [id].
  SubAuthorsData subAuthors(String id) {
    final section = _service.authorsOf(id);
    return switch (section.state) {
      SectionState.ready => SubAuthorsData(SectionState.ready, [
        for (final author in section.data!) _rowOf(author),
      ]),
      SectionState.empty => const SubAuthorsData(SectionState.empty),
      SectionState.loading => const SubAuthorsData(SectionState.loading),
      SectionState.error ||
      SectionState.offline => const SubAuthorsData(SectionState.error),
    };
  }

  static AuthorRowData _rowOf(AuthorView author) => AuthorRowData(
    key: author.key,
    name: author.name,
    workCount: author.workCount,
    missing: author.missingCount,
    photo: author.photo,
  );

  /// Starts the screen; the view calls it once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    _openInitial();
    await Future.wait([_service.loadEras(), _service.loadSubs(eraId)]);
    if (_disposed) return;
    _openInitial();
    notifyListeners();
  }

  /// "Tekrar Dene" of the screen: the era list and the sub-subjects again.
  Future<void> retry() async {
    await Future.wait([
      if (_era == null) _service.loadEras(force: true),
      _service.loadSubs(eraId, force: true),
    ]);
    if (_disposed) return;
    _openInitial();
    notifyListeners();
  }

  /// "Tekrar Dene" inside the accordion [subId].
  Future<void> retryAuthors(String subId) =>
      _service.loadAuthors(eraId, subId, force: true);

  /// Opens the first accordion with a missing work (the first one when none
  /// is missing) once the sub-subjects are here.
  void _openInitial() {
    if (_initialOpenDone) return;
    final subs = _subs;
    if (!_service.subsOf(eraId).isReady || subs.isEmpty) return;
    _initialOpenDone = true;
    var target = 0;
    var missing = false;
    for (final (index, sub) in subs.indexed) {
      if ((sub.missing ?? 0) > 0) {
        target = index;
        missing = true;
        break;
      }
    }
    final id = subs[target].id;
    _open.add(id);
    unawaited(_service.loadAuthors(eraId, id));
    // Nothing to scroll to when the target is already at the top.
    if (missing && target > 0) _focusRequest.value = EraFocusTarget(id);
  }

  /// An accordion was opened or closed; opening reads its authors.
  void setOpen(String subId, bool open) {
    if (open ? !_open.add(subId) : !_open.remove(subId)) return;
    notifyListeners();
    if (open) unawaited(_service.loadAuthors(eraId, subId));
  }

  /// An author row was pressed: the author sheet opens.
  Future<void> openAuthor(String subId, String authorKey) => AuthorSheet.show(
    service: _service,
    eraId: eraId,
    subId: subId,
    authorKey: authorKey,
  );

  @override
  void dispose() {
    _disposed = true;
    _focusRequest.dispose();
    super.dispose();
  }
}
