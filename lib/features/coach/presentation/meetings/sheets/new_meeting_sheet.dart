import 'package:flutter/material.dart';

import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/application/note_rules.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/meetings/sheets/meeting_date_sheet.dart';
import 'package:smap/features/coach/presentation/meetings/sheets/meeting_picker_field.dart';
import 'package:smap/features/coach/presentation/meetings/sheets/student_picker_sheet.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/inputs/app_text_area.dart';
import 'package:smap/shared/ui/pickers/app_time_wheel.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// "Yeni görüşme" (`NewMeetingSheet`; pano 10.5 kare 2; flow 13.11): the
/// student (a field that opens the list from below), "Kiminle" ("Öğrenci" or
/// "Veli"), "Tarih" and "Saat", the optional "Not (isteğe bağlı)" and the
/// primary "Görüşmeyi Kaydet".
///
/// It starts on today's next half hour, so every field already holds a
/// plausible value; only the student must be chosen: the button stays live and
/// a missing student is told under the field ("Bir öğrenci seç.", the kit
/// rule against a mute disabled button). The board draws no pickers for the
/// day and the time: the day is the kit calendar in a sheet, the time the
/// time wheel in a sheet.
///
/// Saving is the caller's [MeetingSubmit]; while it runs the sheet is busy,
/// and a failure keeps it open with everything typed (the caller toasts).
/// `true` closes it. [studentId] opens it with that student chosen (the
/// "Görüşme Planla" of Öğrenci Profili).
class NewMeetingSheet extends StatefulWidget {
  const NewMeetingSheet._({
    required this.students,
    required this.submit,
    this.studentId,
  });

  final List<CoachStudentDto> students;
  final MeetingSubmit submit;
  final String? studentId;

  /// Opens the sheet; completes with `true` when a meeting was saved.
  static Future<bool> show({
    required List<CoachStudentDto> students,
    required MeetingSubmit submit,
    String? studentId,
    BuildContext? context,
  }) async {
    final saved = await AppSheet.show<bool>(
      context: context,
      builder: (_) => NewMeetingSheet._(
        students: students,
        submit: submit,
        studentId: studentId,
      ),
    );
    return saved ?? false;
  }

  @override
  State<NewMeetingSheet> createState() => _NewMeetingSheetState();
}

class _NewMeetingSheetState extends State<NewMeetingSheet> {
  final TextEditingController _note = TextEditingController();
  late final DateTime _today = DateTime.now();
  late DateTime _moment = MeetingSchedule.initialMoment(_today);
  CoachStudentDto? _student;
  InterviewType _type = InterviewType.student;
  bool _studentMissing = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final id = widget.studentId;
    if (id != null) {
      for (final student in widget.students) {
        if (student.id == id) _student = student;
      }
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickStudent() async {
    final chosen = await StudentPickerSheet.show(
      students: widget.students,
      selectedId: _student?.id,
    );
    if (chosen == null || !mounted) return;
    setState(() {
      _student = chosen;
      _studentMissing = false;
    });
  }

  Future<void> _pickDay() async {
    final day = await MeetingDateSheet.show(initial: _moment, today: _today);
    if (day == null || !mounted) return;
    setState(() {
      _moment = MeetingSchedule.combine(
        day,
        hour: _moment.hour,
        minute: _moment.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final l10n = AppLocalizations.of(context);
    final time = await AppTimeWheelSheet.show(
      title: l10n.coachMeetings_timeTitle,
      saveLabel: l10n.common_ok,
      initial: TimeOfDay(hour: _moment.hour, minute: _moment.minute),
    );
    if (time == null || !mounted) return;
    setState(() {
      _moment = MeetingSchedule.combine(
        _moment,
        hour: time.hour,
        minute: time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_busy) return;
    final student = _student;
    final id = student?.id;
    if (id == null) {
      setState(() => _studentMissing = true);
      return;
    }
    setState(() => _busy = true);
    final saved = await widget.submit(
      MeetingDraft(
        studentId: id,
        type: _type,
        moment: _moment,
        note: MeetingSchedule.noteOf(_note.text),
      ),
    );
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _busy = false);
  }

  /// A gap between fields of a sheet form (pano 10.5 kare 2: "aralık 16").
  static const double _gap = AppSpacing.s16;

  /// The day column is wider than the time column (pano 10.5: 1,4fr / 1fr).
  static const int _dayFlex = 14;
  static const int _timeFlex = 10;

  /// The note field's height (pano 10.5 kare 2: min-height 88).
  static const double _noteMinHeight = 88;

  /// The avatar inside the student field (pano 10.5 kare 2: 28).
  static const double _fieldAvatar = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = context.appText;
    final colors = context.appColors;
    final student = _student;
    final name = student?.displayName;
    final asset = AvatarAsset.pathOf(student?.photo);
    return AppSheetFrame(
      title: l10n.coachMeetings_newTitle,
      busy: _busy,
      bodyPadding: const EdgeInsets.fromLTRB(
        AppSpacing.s24,
        AppSpacing.s12,
        AppSpacing.s24,
        0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MeetingPickerField(
            label: l10n.coachMeetings_studentLabel,
            hintText: l10n.coachMeetings_studentHint,
            value: name,
            errorText: _studentMissing
                ? l10n.coachMeetings_studentMissing
                : null,
            leading: name == null
                ? null
                : AppAvatar(
                    name: name,
                    image: asset == null ? null : AssetImage(asset),
                    size: _fieldAvatar,
                    decorative: true,
                  ),
            onTap: _pickStudent,
          ),
          const SizedBox(height: _gap),
          Semantics(
            container: true,
            label: l10n.coachMeetings_withLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExcludeSemantics(
                  child: Text(
                    l10n.coachMeetings_withLabel,
                    style: text.labelMd.copyWith(color: colors.textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                AppSegmented<InterviewType>(
                  value: _type,
                  onChanged: (type) => setState(() => _type = type),
                  segments: [
                    AppSegment(
                      value: InterviewType.student,
                      label: l10n.coachMeetings_kindStudent,
                    ),
                    AppSegment(
                      value: InterviewType.parent,
                      label: l10n.coachMeetings_kindParent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: _gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: _dayFlex,
                child: MeetingPickerField(
                  label: l10n.coachMeetings_dateLabel,
                  value:
                      '${TrFormat.uzunTarih(_moment)} ${TrFormat.gunKisa(_moment)}',
                  onTap: _pickDay,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                flex: _timeFlex,
                child: MeetingPickerField(
                  label: l10n.coachMeetings_timeLabel,
                  value: TrFormat.saat(_moment),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: _gap),
          AppTextArea(
            label: l10n.coachMeetings_noteLabel,
            optional: true,
            controller: _note,
            hintText: l10n.coachMeetings_noteHint,
            minHeight: _noteMinHeight,
            maxLength: NoteRules.maxLength,
          ),
          const SizedBox(height: AppSpacing.s8),
        ],
      ),
      primary: AppSheetAction(
        label: l10n.coachMeetings_saveAction,
        loading: _busy,
        onPressed: _save,
      ),
    );
  }
}
