import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/account/presentation/account_texts.dart';
import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/l10n/app_localizations.dart';

/// The Turkish lines the student list writes for a row (pano 10.2 kare 1).
/// The values carry no text (`SchoolGrade`, `StudyTrack`); the labels are the
/// account screens' ("12. Sınıf", "Mezun", "Eşit Ağırlık").
abstract final class StudentTexts {
  /// The parts of the meta line the student has data for, in the board's
  /// order: the grade, the track, the exam count ("12. Sınıf", "Eşit
  /// Ağırlık", "10 deneme"). A student without any of them has none.
  static List<String> metaParts(AppLocalizations l10n, StudentRowData row) {
    final grade = row.grade;
    final track = row.track;
    final count = row.examCount;
    return [
      if (grade != null) accountGradeLabel(l10n, grade),
      if (track != null) accountTrackLabel(l10n, track),
      if (count != null) l10n.students_examCount(TrFormat.sira(count)),
    ];
  }

  /// The meta line under the name, "12. Sınıf · Eşit Ağırlık · 10 deneme";
  /// `null` when the student has nothing to say (no line is drawn).
  static String? meta(AppLocalizations l10n, StudentRowData row) {
    final parts = metaParts(l10n, row);
    if (parts.isEmpty) return null;
    return parts.reduce((joined, next) => l10n.students_metaJoin(joined, next));
  }

  /// The reading of a whole row: "Alparslan Kuloğlu, 12. Sınıf, Eşit Ağırlık,
  /// 10 deneme".
  static String semanticLabel(AppLocalizations l10n, StudentRowData row) {
    final parts = metaParts(l10n, row);
    if (parts.isEmpty) return row.name;
    return l10n.students_rowA11y(row.name, parts.join(', '));
  }
}
