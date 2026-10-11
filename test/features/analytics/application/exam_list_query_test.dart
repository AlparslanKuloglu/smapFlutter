import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/analytics/application/exam_favorites.dart';
import 'package:smap/features/analytics/application/exam_list_query.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

ExamSummary _exam(String id, DateTime? date) => ExamSummary(
  id: id,
  definition: const ExamDefinition(kind: NetExamType.tyt),
  date: date,
);

void main() {
  final now = DateTime(2026, 10, 11, 15, 30);

  group('ExamDatePreset.startOf', () {
    test('Tüm tarihler has no start', () {
      expect(ExamDatePreset.all.startOf(now), isNull);
    });

    test('Son 30 gün starts 30 days before today', () {
      expect(ExamDatePreset.last30Days.startOf(now), DateTime(2026, 9, 11));
    });

    test('Son 3 ay starts three months before today', () {
      expect(ExamDatePreset.last3Months.startOf(now), DateTime(2026, 7, 11));
      expect(
        ExamDatePreset.last3Months.startOf(DateTime(2026, 2, 15)),
        DateTime(2025, 11, 15),
      );
    });

    test('Bu eğitim yılı starts on 1 September', () {
      expect(ExamDatePreset.academicYear.startOf(now), DateTime(2026, 9));
      expect(
        ExamDatePreset.academicYear.startOf(DateTime(2027, 3, 2)),
        DateTime(2026, 9),
      );
      expect(
        ExamDatePreset.academicYear.startOf(DateTime(2026, 9)),
        DateTime(2026, 9),
      );
    });
  });

  group('ExamListQuery', () {
    test('the server gets the type only', () {
      expect(ExamListQuery.initial.serverFilter.isEmpty, isTrue);
      const ayt = ExamListQuery(type: ExamTypeFilter.ayt);
      expect(ayt.serverFilter.types, {NetExamType.ayt});
      expect(ayt.serverFilter.dates, isEmpty);
    });

    test('a range accepts the start day and later, never undated exams', () {
      const query = ExamListQuery(date: ExamDatePreset.last30Days);
      expect(query.accepts(_exam('a', DateTime(2026, 9, 11)), now), isTrue);
      expect(query.accepts(_exam('b', DateTime(2026, 9, 10)), now), isFalse);
      expect(query.accepts(_exam('c', null), now), isFalse);
      expect(ExamListQuery.initial.accepts(_exam('d', null), now), isTrue);
    });

    test('a page with an older exam ends the range', () {
      const query = ExamListQuery(date: ExamDatePreset.academicYear);
      expect(
        query.endsRange([
          _exam('a', DateTime(2026, 9, 20)),
          _exam('b', DateTime(2026, 8, 30)),
        ], now),
        isTrue,
      );
      expect(
        query.endsRange([_exam('a', DateTime(2026, 9, 20))], now),
        isFalse,
      );
      expect(
        ExamListQuery.initial.endsRange([_exam('x', DateTime(2000))], now),
        isFalse,
      );
    });

    test('knows its initial state and compares by value', () {
      expect(ExamListQuery.initial.isInitial, isTrue);
      const query = ExamListQuery(type: ExamTypeFilter.tyt);
      expect(query.isInitial, isFalse);
      expect(query, const ExamListQuery(type: ExamTypeFilter.tyt));
      expect(query.copyWith(type: ExamTypeFilter.all), ExamListQuery.initial);
    });
  });

  group('ExamFavorites', () {
    setUp(() {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
    });

    test('stars and unstars, and keeps them on the device', () async {
      final preferences = await DevicePreferences.load();
      final favorites = ExamFavorites(preferences);
      expect(favorites.ids, isEmpty);

      expect(await favorites.toggle('res-1'), isTrue);
      expect(await favorites.toggle('res-2'), isTrue);
      expect(favorites.contains('res-1'), isTrue);
      expect(await favorites.toggle('res-1'), isFalse);
      expect(favorites.ids, {'res-2'});

      expect(ExamFavorites(preferences).ids, {'res-2'});
    });

    test('a damaged value reads as no favorites', () async {
      final preferences = await DevicePreferences.load();
      await preferences.setString(DevicePreferences.favoriteExamsKey, '{oops');
      expect(ExamFavorites(preferences).ids, isEmpty);
      await preferences.setString(
        DevicePreferences.favoriteExamsKey,
        jsonEncode(['a', 3, '', 'b']),
      );
      expect(ExamFavorites(preferences).ids, {'a', 'b'});
    });
  });
}
