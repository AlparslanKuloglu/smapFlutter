import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/coach/application/student_list_logic.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';
import 'package:smap/shared/ui/controls/clear_color.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/inputs/app_search_field.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The list the "Öğrenci" field opens from below (pano 10.5 kare 2: "Alttan
/// öğrenci listesi açar"; built from the kit): a row per student with the
/// 40 pt avatar and the name, the chosen one marked with a check. A list of
/// more than [searchFrom] students gets a search field on top, with the same
/// Turkish folding as "Öğrencilerim" (`searchStudents`).
///
/// A tap closes the sheet with that student; dismissing it changes nothing.
class StudentPickerSheet extends StatefulWidget {
  const StudentPickerSheet._({required this.students, this.selectedId});

  /// The students, already in order.
  final List<CoachStudentDto> students;
  final String? selectedId;

  /// A list longer than this is searchable.
  static const int searchFrom = 6;

  /// Opens the sheet; completes with the chosen student or `null`.
  static Future<CoachStudentDto?> show({
    required List<CoachStudentDto> students,
    String? selectedId,
    BuildContext? context,
  }) => AppSheet.show<CoachStudentDto>(
    context: context,
    size: AppSheetSize.medium,
    builder: (_) =>
        StudentPickerSheet._(students: students, selectedId: selectedId),
  );

  @override
  State<StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<StudentPickerSheet> {
  String _query = '';

  bool get _searchable =>
      widget.students.length > StudentPickerSheet.searchFrom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final shown = searchStudents(widget.students, _query);
    return AppSheetFrame(
      title: l10n.coachMeetings_pickStudentTitle,
      bodyPadding: const EdgeInsets.only(bottom: AppSpacing.s16),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_searchable)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s16,
                AppSpacing.s24,
                AppSpacing.s8,
              ),
              child: AppSearchField(
                semanticLabel: l10n.coachMeetings_pickStudentSearch,
                hintText: l10n.coachMeetings_pickStudentSearch,
                onQueryChanged: (query) => setState(() => _query = query),
              ),
            ),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Text(
                l10n.coachMeetings_pickStudentNoMatch,
                style: context.appText.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          for (final student in shown)
            _StudentOption(
              student: student,
              selected: student.id == widget.selectedId,
            ),
        ],
      ),
    );
  }
}

/// One student of the list: avatar, name and, when chosen, a check.
class _StudentOption extends StatelessWidget {
  const _StudentOption({required this.student, required this.selected});

  final CoachStudentDto student;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final name = student.displayName ?? '';
    final asset = AvatarAsset.pathOf(student.photo);
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      onTap: () => Navigator.of(context).pop(student),
      child: AppPressable(
        onTap: () => Navigator.of(context).pop(student),
        scale: 1,
        haptic: true,
        builder: (context, states) => AnimatedContainer(
          duration: context.motion(AppMotion.instant, reduced: Duration.zero),
          constraints: const BoxConstraints(minHeight: AppSize.rowMin),
          color: states.contains(WidgetState.pressed)
              ? colors.bgSunken
              : colors.bgRaised.clear,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s8,
          ),
          child: Row(
            children: [
              AppAvatar(
                name: name,
                image: asset == null ? null : AssetImage(asset),
                decorative: true,
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  name,
                  style: text.titleSm.copyWith(color: colors.textPrimary),
                ),
              ),
              if (selected)
                PhosphorIcon(
                  PhosphorIconsBold.check,
                  size: AppSize.icon,
                  color: colors.textAction,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
