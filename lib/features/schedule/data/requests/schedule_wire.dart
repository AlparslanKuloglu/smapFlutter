import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// How a [WeeklyDraft] looks on the wire (`dataObj` of `addNewProgram` and
/// `updateProgram`), after the legacy editor's `_submitSchedule`.

/// The `dataObj`: `{name, motto, tasks: [...]}`, plus `weeklyId` for an update.
Map<String, Object> weeklyToDataObj(WeeklyDraft draft, {String? weeklyId}) =>
    <String, Object>{
      'name': draft.name.trim(),
      'motto': draft.motto.trim(),
      'tasks': [for (final task in draft.tasks) taskToWire(task)],
      'weeklyId': ?weeklyId,
    };

/// One task as the backend stores it. Missing ids go out as empty text, as
/// the legacy editor sent them; `category` is the constant `"0"`.
Map<String, Object> taskToWire(ProgramTaskDraft task) => <String, Object>{
  'id': task.id,
  'day': task.dayKey,
  'hour': task.hour,
  'minute': task.minute,
  'lesson': task.lessonId,
  'lessonName': task.lessonName ?? '',
  'mainSubject': task.mainSubjectId ?? '',
  'subject': task.subjectId ?? '',
  'item': task.itemId ?? '',
  'title': task.title,
  'category': '0',
  'lessonColor': normalizeHexColor(task.lessonColor) ?? '#000000',
  'mapImage': (task.mapImage ?? '').split('/').last,
};

final RegExp _hex6 = RegExp(r'^[0-9a-fA-F]{6}$');
final RegExp _hex8 = RegExp(r'^[0-9a-fA-F]{8}$');

/// `#RRGGBB` (upper case) from `#RRGGBB`, `RRGGBB`, `0xAARRGGBB`, `#AARRGGBB`
/// (alpha dropped) or the legacy `Color(alpha: 1.0, red: 0.2, ...)` text;
/// `null` when [raw] is none of them.
String? normalizeHexColor(String? raw) {
  if (raw == null) return null;
  final text = raw.trim();
  if (text.isEmpty) return null;

  if (text.contains('Color(')) {
    int? channel(String name) {
      final match = RegExp('$name:\\s*([0-9.]+)').firstMatch(text);
      final value = match == null ? null : double.tryParse(match.group(1)!);
      return value == null ? null : (value * 255).round().clamp(0, 255);
    }

    final red = channel('red');
    final green = channel('green');
    final blue = channel('blue');
    if (red == null || green == null || blue == null) return null;
    String two(int value) => value.toRadixString(16).padLeft(2, '0');
    return '#${(two(red) + two(green) + two(blue)).toUpperCase()}';
  }

  var digits = text.replaceAll('#', '');
  if (digits.startsWith('0x') || digits.startsWith('0X')) {
    digits = digits.substring(2);
  }
  if (_hex8.hasMatch(digits)) digits = digits.substring(2);
  if (!_hex6.hasMatch(digits)) return null;
  return '#${digits.toUpperCase()}';
}
