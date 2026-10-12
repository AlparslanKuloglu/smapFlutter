import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/features/coach/application/note_rules.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_dialogs.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';

/// The note sheet (`NoteSheet`; pano 10.6 kare 1 and 2): "Not ekle" and
/// "Notu düzenle", a modal over Görüşme Detayı, not a route.
///
/// **Not ekle** has the context line "12 Ekim 2026 · Alparslan Kuloğlu", an
/// empty multi-line field with the example "Örn: Deneme sonucunu birlikte
/// inceleyeceğiz.", the counter "0/500" and "Notu Kaydet", which is off while
/// there is no text. **Notu düzenle** has no context line, the field holds the
/// note ("Tarih eksikleri için haftada 3 saat ayrıldı.", "44/500") and
/// "Kaydet" works only for a change.
///
/// The field has focus on opening. Saving is the caller's [NoteSubmit]: while
/// it runs the sheet is busy (the close button hides, drag and scrim do not
/// close it); a failure leaves it open with the text ("Kaydetme hatası: sheet
/// açık kalır, metin korunur, toast"; the caller toasts). `true` closes it.
class NoteSheet extends StatefulWidget {
  const NoteSheet._({
    required this.submit,
    this.initialText,
    this.date,
    this.studentName,
  });

  final NoteSubmit submit;

  /// The note being edited; `null` is a new note.
  final String? initialText;

  /// The meeting's day, for the context line of a new note.
  final DateTime? date;
  final String? studentName;

  /// Opens the sheet; completes with `true` when the note was saved.
  static Future<bool> show({
    required NoteSubmit submit,
    String? initialText,
    DateTime? date,
    String? studentName,
    BuildContext? context,
  }) async {
    final saved = await AppSheet.show<bool>(
      context: context,
      builder: (_) => NoteSheet._(
        submit: submit,
        initialText: initialText,
        date: date,
        studentName: studentName,
      ),
    );
    return saved ?? false;
  }

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initialText,
  );
  bool _busy = false;

  bool get _editing => widget.initialText != null;

  @override
  void initState() {
    super.initState();
    _text.addListener(_edited);
  }

  @override
  void dispose() {
    _text
      ..removeListener(_edited)
      ..dispose();
    super.dispose();
  }

  void _edited() => setState(() {});

  bool get _canSave => _editing
      ? NoteRules.canSaveEdit(_text.text, original: widget.initialText ?? '')
      : NoteRules.canAdd(_text.text);

  Future<void> _save() async {
    if (_busy || !_canSave) return;
    setState(() => _busy = true);
    final saved = await widget.submit(_text.text);
    if (!mounted) return;
    if (saved) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _busy = false);
  }

  /// "12 Ekim 2026 · Alparslan Kuloğlu": what is missing is left out.
  String? _contextLine(AppLocalizations l10n) {
    final date = widget.date;
    final name = widget.studentName;
    if (date != null && name != null) {
      return l10n.coachMeetings_noteContext(TrFormat.uzunTarih(date), name);
    }
    if (date != null) return TrFormat.uzunTarih(date);
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSheetFrame(
      title: _editing
          ? l10n.coachMeetings_noteEditTitle
          : l10n.coachMeetings_noteAddTitle,
      subtitle: _editing ? null : _contextLine(l10n),
      busy: _busy,
      body: _NoteField(controller: _text),
      primary: AppSheetAction(
        label: _editing ? l10n.common_save : l10n.coachMeetings_noteSave,
        loading: _busy,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}

/// The multi-line field of the sheet (C13 "TextArea", Tur 9 G7): the chrome
/// of the kit's inputs with a 120 high box, no visible label (the sheet's
/// title names it), the example as placeholder and the counter "0/500". It is
/// `AppTextArea` without the label the sheet does not draw.
class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller});

  final TextEditingController controller;

  /// The note sheet's field height (C13: "the meeting note sheet uses 120").
  static const double _minHeight = 120;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return AppFieldFrame(
      semanticLabel: l10n.coachMeetings_noteFieldA11y,
      minHeight: _minHeight,
      verticalPadding: 12,
      alignTop: true,
      counter: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => Text(
          '${TrFormat.sira(value.text.characters.length)}/'
          '${TrFormat.sira(NoteRules.maxLength)}',
          style: context.appText.caption.copyWith(color: colors.textSecondary),
        ),
      ),
      inputBuilder: (context, node, style, cursor) => TextField(
        controller: controller,
        focusNode: node,
        autofocus: true,
        minLines: 3,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: [
          LengthLimitingTextInputFormatter(NoteRules.maxLength),
        ],
        style: style,
        cursorColor: cursor,
        decoration: bareFieldDecoration(
          hintText: l10n.coachMeetings_noteHint,
          hintStyle: style.copyWith(color: colors.textPlaceholder),
        ),
      ),
    );
  }
}
