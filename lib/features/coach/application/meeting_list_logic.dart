import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/coach/application/meeting_models.dart';

/// Pure list logic of "Görüşmelerim" (pano 10.5 kare 1; spec §4.C 10.5).
abstract final class MeetingListLogic {
  /// [incoming] added to [loaded], without a meeting that is already there (a
  /// reload can shift the pages): the first copy stays, the order is kept.
  static List<MeetingEntry> merge(
    List<MeetingEntry> loaded,
    Iterable<MeetingEntry> incoming,
  ) {
    final seen = {for (final entry in loaded) entry.id};
    return [
      ...loaded,
      for (final entry in incoming)
        if (seen.add(entry.id)) entry,
    ];
  }

  /// [entries] narrowed to [kind] and to the student names that match
  /// [query], split into the sections of the list.
  ///
  /// - **"Kiminle"**: [MeetingWith.all] keeps everything; the other two keep
  ///   only that kind (a meeting of an unknown kind is left out of them).
  /// - **Search**: every word of the query starts some word of the student's
  ///   name, in any order, ignoring case and the Turkish marks
  ///   (`TurkishText.matchesTokens`; "zey ka" finds "Zeynep Kaya"). A blank
  ///   query keeps everyone; a meeting without a student name matches no
  ///   query. The server has no search parameter (spec §6.3 #31), so this
  ///   runs on the pages that are loaded.
  /// - **Sections**: a meeting at or after [now] is "Yaklaşan", nearest
  ///   first; the rest is past, newest first, and a meeting without a time
  ///   goes to the end of the past ones. Equal times keep the loaded order.
  static MeetingSections sections(
    Iterable<MeetingEntry> entries, {
    required DateTime now,
    String query = '',
    MeetingWith kind = MeetingWith.all,
  }) {
    final indexed = <(int, MeetingEntry)>[];
    var position = 0;
    for (final entry in entries) {
      final at = position++;
      if (kind.type != null && entry.type != kind.type) continue;
      if (!matches(entry, query)) continue;
      indexed.add((at, entry));
    }

    final upcoming = <(int, MeetingEntry)>[];
    final past = <(int, MeetingEntry)>[];
    for (final item in indexed) {
      final moment = item.$2.moment;
      (moment != null && !moment.isBefore(now) ? upcoming : past).add(item);
    }
    upcoming.sort((a, b) {
      final byTime = a.$2.moment!.compareTo(b.$2.moment!);
      return byTime != 0 ? byTime : a.$1.compareTo(b.$1);
    });
    past.sort((a, b) {
      final left = a.$2.moment;
      final right = b.$2.moment;
      if (left == null && right == null) return a.$1.compareTo(b.$1);
      if (left == null) return 1;
      if (right == null) return -1;
      final byTime = right.compareTo(left);
      return byTime != 0 ? byTime : a.$1.compareTo(b.$1);
    });
    return MeetingSections(
      upcoming: List.unmodifiable([for (final item in upcoming) item.$2]),
      past: List.unmodifiable([for (final item in past) item.$2]),
    );
  }

  /// Whether [entry]'s student name matches [query] (a blank query matches
  /// everyone).
  static bool matches(MeetingEntry entry, String query) {
    if (query.trim().isEmpty) return true;
    final name = entry.studentName;
    return name != null && TurkishText.matchesTokens(name, query);
  }
}
