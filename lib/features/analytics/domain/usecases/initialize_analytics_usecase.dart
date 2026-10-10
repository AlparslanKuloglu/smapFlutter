import 'package:smap/features/analytics/domain/repositories/analytics_repository.dart';

class InitializeAnalyticsUseCase {
  const InitializeAnalyticsUseCase(this._repository);

  final AnalyticsRepository _repository;

  Future<void> call() {
    return _repository.initialize();
  }
}
