import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// Where the program screens go from one another. The ViewModels hold this
/// instead of a router, so they stay free of the router's generated classes
/// and of a `BuildContext` (UI guide §6 rule 16) and can be tested with a
/// fake.
abstract interface class ProgramNavigator {
  /// Pushes the program [programId] on the tab's stack, opened on [day] when
  /// given (pano 3.4 "Program satırı Gün görünümünde bugünü açar").
  void openDetail(String programId, {DateTime? day});

  /// Opens the full-screen new program flow over the shell (pano 3.5: root
  /// navigator, no bottom bar) and completes with the saved program's id, or
  /// `null` when the flow was left without saving.
  Future<String?> openNewProgram();

  /// Closes the current screen, handing [result] to whoever opened it.
  void close([Object? result]);
}

/// [ProgramNavigator] on auto_route: [router] is the stack router of the
/// screen that asks (`context.router`): the tab's stack for the list and the
/// detail, the root for the flow.
class RouterProgramNavigator implements ProgramNavigator {
  const RouterProgramNavigator(this._router);

  final StackRouter _router;

  @override
  void openDetail(String programId, {DateTime? day}) {
    _router.push(
      ProgramDetailRoute(
        programId: programId,
        date: day == null ? null : formatDayKey(day),
      ),
    );
  }

  @override
  Future<String?> openNewProgram() =>
      _router.root.push<String>(const NewProgramRoute());

  @override
  void close([Object? result]) => _router.pop(result);
}
