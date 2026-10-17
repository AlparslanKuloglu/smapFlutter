import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:stacked/stacked.dart';

import 'package:smap/features/lessons/application/literature_authors.dart';
import 'package:smap/features/lessons/application/literature_service.dart';

/// The logic of the author sheet (pano 14.6, 14.7): it shows one author of
/// [LiteratureService] and nothing else, so every count and every work row
/// follows the service in the same frame as the screens behind it.
///
/// "Öğrendim" is the service's: the row turns learned at once, the toast with
/// "Geri Al" shows, and the request is held 6 s (it goes out even if the
/// sheet is closed meanwhile). Offline the button is off and the note shows
/// under the first missing work; the sheet follows the connection.
class AuthorSheetViewModel extends ReactiveViewModel {
  AuthorSheetViewModel({
    required LiteratureService service,
    required this.eraId,
    required this.subId,
    required this.authorKey,
  }) : _service = service {
    _service.online.addListener(notifyListeners);
  }

  final LiteratureService _service;
  final String eraId;
  final String subId;
  final String authorKey;

  @override
  List<ListenableServiceMixin> get listenableServices => [_service];

  /// The author; `null` if the list no longer holds it.
  AuthorView? get author => _service.authorOf(subId, authorKey);

  /// "Tanzimat Dönemi": the era under the name.
  String get eraName => _service.eraOf(eraId)?.name ?? '';

  /// The device has a link; "Öğrendim" needs one.
  bool get isOnline => _service.isOnline;

  /// The connection state, for the strip over the sheet.
  ValueListenable<bool> get online => _service.online;

  /// The work whose row carries the offline note: the first missing one.
  String? get offlineNoteFor => isOnline ? null : author?.firstMissingId;

  /// "Öğrendim" of the work with progress id [progressId].
  void learn(String progressId) {
    _service.learn(
      eraId: eraId,
      subId: subId,
      authorKey: authorKey,
      progressId: progressId,
    );
  }

  @override
  void dispose() {
    _service.online.removeListener(notifyListeners);
    super.dispose();
  }
}
