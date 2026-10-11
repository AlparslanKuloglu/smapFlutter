import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';

/// The lesson of the built-in catalog as a [GeneralLesson], for a screen that
/// opens before (or without) `getGeneralLessons`: the legacy screens always
/// read the catalog, and the ids in it are the backend's own.
extension GeneralLessonSpecLesson on GeneralLessonSpec {
  GeneralLesson toGeneralLesson() => GeneralLesson(
    id: id,
    name: name,
    order: order,
    ids: ids,
    hasTrackChoice: hasTrackChoice,
    isWebOnly: isWebOnly,
    isLiterature: isLiterature,
  );
}
