import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/data/interview_repository.dart';

/// Phase 2 (`kDataModules`): the coach's student and interview endpoints.
void registerCoachData(GetIt l) {
  l
    ..registerLazySingleton<CoachStudentRepository>(
      () => CoachStudentRepository(l<NetworkService>()),
    )
    ..registerLazySingleton<InterviewRepository>(
      () => InterviewRepository(l<NetworkService>()),
    );
}

/// `kSessionModules`: the coach's student list. Registered for every session
/// but created lazily, so a student's session never builds it; only the coach
/// shell asks for it.
void registerCoachSession(GetIt l) {
  l.registerLazySingleton<CoachStudentsService>(
    () => CoachStudentsService(repository: l<CoachStudentRepository>()),
    dispose: (service) => service.dispose(),
  );
}
