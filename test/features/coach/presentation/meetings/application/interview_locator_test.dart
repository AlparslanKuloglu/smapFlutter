import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/coach/application/interview_locator.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';

import '../meetings_fakes.dart';

/// [count] filler meetings on [day] so the list has several pages.
List<InterviewDto> filler(int count, DateTime day) => [
  for (var i = 0; i < count; i++)
    interview(
      id: 'f-${day.day}-$i',
      studentId: 's$i',
      first: 'Öğrenci',
      last: '$i',
      date: day,
    ),
];

void main() {
  test('with a hint it asks for the three days around it first', () async {
    final repository = FakeInterviewRepository([
      ...filler(20, DateTime(2026, 9, 1, 10)),
      alparslanMeeting(),
    ]);

    final found = (await InterviewLocator(
      repository,
    ).find('iv-1', hint: DateTime(2026, 10, 12, 16))).rightOrNull;

    expect(found?.id, 'iv-1');
    expect(repository.filters.first.dates, [
      DateTime(2026, 10, 11),
      DateTime(2026, 10, 12),
      DateTime(2026, 10, 13),
    ]);
    expect(repository.log, ['list:1'], reason: 'one request was enough');
  });

  test('walks the pages of the window until it is found', () async {
    final repository = FakeInterviewRepository([
      ...filler(10, DateTime(2026, 10, 12, 9)),
      alparslanMeeting(),
    ]);

    final found = (await InterviewLocator(
      repository,
    ).find('iv-1', hint: DateTime(2026, 10, 12, 16))).rightOrNull;

    expect(found?.id, 'iv-1');
    expect(repository.log, ['list:1', 'list:2']);
  });

  test('falls back to the whole list when the window misses it', () async {
    // The server reads the day in another time zone: the hint is two days off.
    final repository = FakeInterviewRepository([
      ...filler(9, DateTime(2026, 10, 1, 9)),
      alparslanMeeting(),
    ]);

    final found = (await InterviewLocator(
      repository,
    ).find('iv-1', hint: DateTime(2026, 10, 20, 16))).rightOrNull;

    expect(found?.id, 'iv-1');
    expect(repository.filters.last.isEmpty, isTrue);
  });

  test('without a hint it walks the whole list', () async {
    final repository = FakeInterviewRepository([
      ...filler(16, DateTime(2026, 9, 1, 10)),
      alparslanMeeting(),
    ]);

    final found = (await InterviewLocator(repository).find('iv-1')).rightOrNull;

    expect(found?.id, 'iv-1');
    expect(repository.log, ['list:1', 'list:2', 'list:3']);
    expect(repository.filters.every((f) => f.isEmpty), isTrue);
  });

  test('a meeting that is not there is a plain null', () async {
    final repository = FakeInterviewRepository([alparslanMeeting()]);

    final result = await InterviewLocator(
      repository,
    ).find('missing', hint: DateTime(2026, 10, 12));

    expect(result.isRight(), isTrue);
    expect(result.rightOrNull, isNull);
  });

  test('the walk is bounded', () async {
    final repository = FakeInterviewRepository(
      filler(80, DateTime(2026, 9, 1, 10)),
    );

    final result = await InterviewLocator(
      repository,
      listPages: 3,
    ).find('missing');

    expect(result.rightOrNull, isNull);
    expect(repository.listCalls, 3);
  });

  test('a failed request is a failure at once, not "not found"', () async {
    final repository = FakeInterviewRepository([alparslanMeeting()])
      ..listFailure = offline;

    final result = await InterviewLocator(
      repository,
    ).find('iv-1', hint: DateTime(2026, 10, 12));

    expect(result.leftOrNull, offline);
    expect(repository.listCalls, 1);
  });
}
