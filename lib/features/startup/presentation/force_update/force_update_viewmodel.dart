import 'package:stacked/stacked.dart';

import 'package:smap/features/startup/application/store_launcher.dart';

/// "Yeni sürüm gerekli": the only action opens the store page of the app.
class ForceUpdateViewModel extends BaseViewModel {
  ForceUpdateViewModel({required StoreLauncher launcher})
    : _launcher = launcher;

  final StoreLauncher _launcher;

  /// Opens the store page; does nothing while the store address of this
  /// platform is not configured.
  Future<void> update() => _launcher.openStorePage();
}
