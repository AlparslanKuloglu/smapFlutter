import 'package:studentmap/features/analytics/data/datasources/analytics_local_data_source.dart';
import 'package:studentmap/features/analytics/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._localDataSource);

  final AnalyticsLocalDataSource _localDataSource;

  @override
  Future<void> initialize() {
    return _localDataSource.initialize();
  }
}
