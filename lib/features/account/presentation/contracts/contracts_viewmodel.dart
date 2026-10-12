import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/account/application/legal_entries.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/account_navigator.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of Sözleşmeler (pano 9.7 kare 1; spec §4.H 9.7; flow 13.10; route
/// `/account/agreements`).
///
/// The legal texts come from `getLegalDocuments`; the list is the active ones
/// in the design's order (terms, KVKK, privacy), see `LegalEntry.listOf`. The
/// first load is limited to 15 s (the skeleton gives way to the error state);
/// "Tekrar Dene" goes back to the skeleton. A row opens the reading screen
/// with the text already in hand.
class ContractsViewModel extends BaseViewModel {
  ContractsViewModel({
    required AccountRepository accounts,
    required AccountNavigator navigator,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _accounts = accounts,
       _navigator = navigator,
       _timeout = timeout;

  final AccountRepository _accounts;
  final AccountNavigator _navigator;
  final Duration _timeout;

  AsyncSection<List<LegalEntry>> _contracts =
      const AsyncSection<List<LegalEntry>>.loading();
  bool _loading = false;
  bool _disposed = false;

  /// The list: loading, the rows, empty, or failed (offline included).
  AsyncSection<List<LegalEntry>> get contracts => _contracts;

  /// Loads the texts; the view calls it once.
  Future<void> init() => _load();

  /// "Tekrar Dene": back to the skeleton, then ask again.
  Future<void> retry() {
    _contracts = const AsyncSection<List<LegalEntry>>.loading();
    notifyListeners();
    return _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    AsyncSection<List<LegalEntry>> next;
    try {
      final result = await withSkeletonTimeout(
        _accounts.getLegalDocuments(),
        timeout: _timeout,
      );
      next = result.fold(
        AsyncSection.failed<List<LegalEntry>>,
        (documents) => AsyncSection.of(
          LegalEntry.listOf(documents),
          isEmpty: (entries) => entries.isEmpty,
        ),
      );
    } on Object catch (error) {
      next = AsyncSection.failed<List<LegalEntry>>(error);
    }
    _loading = false;
    if (_disposed) return;
    _contracts = next;
    notifyListeners();
  }

  /// A row: the reading screen of that text.
  Future<void> open(LegalEntry entry) => _navigator.openContract(entry);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
