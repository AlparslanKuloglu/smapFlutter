import 'package:flutter/foundation.dart';
import 'package:smap/features/auth/domain/usecases/get_app_launch_destination_usecase.dart';

class AppStartNotifier extends ChangeNotifier {
  AppStartNotifier(this._getAppLaunchDestinationUseCase)
    : _state = const AppStartState.loading();

  final GetAppLaunchDestinationUseCase _getAppLaunchDestinationUseCase;
  AppStartState _state;
  AppStartState get state => _state;

  Future<void> resolveStartRoute() async {
    _updateState(const AppStartState.loading());
    try {
      final destination = await _getAppLaunchDestinationUseCase();
      _updateState(AppStartState.resolved(destination));
    } catch (_) {
      _updateState(const AppStartState.resolved(AppLaunchDestination.login));
    }
  }

  void _updateState(AppStartState newState) {
    _state = newState;
    notifyListeners();
  }
}

class AppStartState {
  const AppStartState._({required this.isLoading, required this.destination});

  const AppStartState.loading()
    : this._(isLoading: true, destination: AppLaunchDestination.login);

  const AppStartState.resolved(AppLaunchDestination destination)
    : this._(isLoading: false, destination: destination);

  final bool isLoading;
  final AppLaunchDestination destination;
}
