import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/exams/data/exam_repository.dart';

/// Phase 2 (`kDataModules`): the exam endpoints. Stateless, so one lazy
/// singleton in the root scope serves every session; a coach passes the
/// student's id per call.
void registerExamsData(GetIt l) {
  l.registerLazySingleton<ExamRepository>(
    () => ExamRepository(l<NetworkService>()),
  );
}
