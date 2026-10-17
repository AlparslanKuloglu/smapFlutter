import 'package:get_it/get_it.dart';

import 'package:smap/core/network/network_service.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/lessons/application/lessons_service.dart';
import 'package:smap/features/lessons/application/literature_service.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';

/// Phase 2 (`kDataModules`): the lesson-content endpoints. Stateless, one lazy
/// singleton in the root scope.
void registerLessonsData(GetIt l) {
  l.registerLazySingleton<LessonContentRepository>(
    () => LessonContentRepository(l<NetworkService>()),
  );
}

/// `kSessionModules`: the lessons cache and the Yazar ve Eserler tree live and
/// die with the signed-in session, so the next user never sees the previous
/// user's lessons, missing counts, authors or a waiting "Öğrendim".
void registerLessonsSession(GetIt l) {
  l.registerLazySingleton<LessonsService>(
    () => LessonsService(repository: l<LessonContentRepository>()),
    dispose: (service) => service.dispose(),
  );
  l.registerLazySingleton<LiteratureService>(
    () => LiteratureService(
      repository: l<LessonContentRepository>(),
      toast: l<ToastService>(),
      online: l<ConnectivityService>().online,
      onSaved: () => l<LessonsService>().refresh(),
    ),
    dispose: (service) => service.dispose(),
  );
}
