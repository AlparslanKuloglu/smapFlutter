import 'package:studentmap/features/auth/domain/repositories/auth_repository.dart';

enum AppLaunchDestination { onboarding, login, home }

class GetAppLaunchDestinationUseCase {
  const GetAppLaunchDestinationUseCase(this._repository);

  final AuthRepository _repository;

  Future<AppLaunchDestination> call() async {
    final onboardingCompleted = await _repository.getOnboardingCompleted();
    if (!onboardingCompleted) return AppLaunchDestination.onboarding;
    final isLoggedIn = await _repository.validateSession();
    return isLoggedIn ? AppLaunchDestination.home : AppLaunchDestination.login;
  }
}
