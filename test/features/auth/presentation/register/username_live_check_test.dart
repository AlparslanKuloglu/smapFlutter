import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/auth/application/register/username_live_check.dart';
import 'package:smap/features/coach/domain/username_check.dart';

const _debounce = Duration(milliseconds: 20);

/// A checker that answers from a set of free names and records every call.
class _Server {
  _Server({Set<String> free = const {}}) : free = {...free};

  final Set<String> free;
  final List<String> asked = [];
  AppErrorCode? failWith;
  Completer<void>? gate;

  Future<AppResult<UsernameCheck>> check(String name) async {
    asked.add(name);
    await gate?.future;
    final code = failWith;
    if (code != null) return Left(AppException(code: code));
    return Right(UsernameCheck(available: free.contains(name)));
  }
}

Future<void> _wait([int ms = 80]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  late _Server server;
  late List<UsernameCheckState> states;
  late UsernameLiveCheck live;

  setUp(() {
    server = _Server();
    states = [];
    live = UsernameLiveCheck(
      checker: server.check,
      onChanged: () => states.add(live.state),
      debounce: _debounce,
    );
  });

  tearDown(() => live.dispose());

  test('asks nothing before the debounce runs out', () async {
    server.free.add('alpar');
    live.input('alp');
    live.input('alpa');
    live.input('alpar');

    expect(server.asked, isEmpty);
    await _wait();

    expect(server.asked, ['alpar'], reason: 'only the last name is asked');
  });

  test('a free name: checking, then available', () async {
    server.free.add('alparslan.k');

    live.input('alparslan.k');
    await _wait();

    expect(states.map((s) => s.status), [
      UsernameStatus.idle,
      UsernameStatus.checking,
      UsernameStatus.available,
    ]);
    expect(live.state.name, 'alparslan.k');
  });

  test('a taken name is taken, and a free candidate is offered', () async {
    server.free.add('alparslan.k');

    live.input('alparslan', fullName: 'Alparslan Kuloğlu');
    await _wait();

    expect(live.state.status, UsernameStatus.taken);
    expect(live.state.suggestion, 'alparslan.k');
    expect(server.asked, ['alparslan', 'alparslan.k']);
  });

  test('without a surname the suggestions are numbered', () async {
    server.free.add('alparslan2');

    live.input('alparslan', fullName: 'Alparslan');
    await _wait();

    expect(live.state.suggestion, 'alparslan2');
    expect(server.asked, ['alparslan', 'alparslan1', 'alparslan2']);
  });

  test(
    'no free candidate in three tries: taken without a suggestion',
    () async {
      live.input('alparslan', fullName: 'Alparslan Kuloğlu');
      await _wait();

      expect(live.state.status, UsernameStatus.taken);
      expect(live.state.suggestion, isNull);
      expect(server.asked, hasLength(1 + kMaxSuggestionChecks));
    },
  );

  test('an answer for an old name is dropped', () async {
    server.gate = Completer<void>();
    live.input('ali', immediately: true);
    await _wait(10);
    server.free.add('veli');

    server.gate!.complete();
    live.input('veli', immediately: true);
    await _wait();

    expect(live.state.name, 'veli');
    expect(live.state.status, UsernameStatus.available);
  });

  test('clearing the field goes back to idle and asks nothing', () async {
    live.input('ali');
    live.input('');
    await _wait();

    expect(server.asked, isEmpty);
    expect(live.state, const UsernameCheckState());
  });

  test('offline is reported; other failures stay idle', () async {
    server.failWith = AppErrorCode.offline;
    live.input('ali', immediately: true);
    await _wait(10);
    expect(live.state.status, UsernameStatus.offline);

    server.failWith = AppErrorCode.server;
    live.input('veli', immediately: true);
    await _wait(10);
    expect(live.state.status, UsernameStatus.idle);
    expect(live.state.name, 'veli');
  });

  test('the same name again does not ask twice', () async {
    server.free.add('ali');
    live.input('ali', immediately: true);
    await _wait(10);

    live.input('ali');
    live.input('ali', immediately: true);
    await _wait();

    expect(server.asked, ['ali']);
    expect(live.state.status, UsernameStatus.available);
  });

  test('settle starts a pending check at once and waits for it', () async {
    server.free.add('ali');
    live.input('ali');

    await live.settle('ali');

    expect(live.state.status, UsernameStatus.available);
    expect(server.asked, ['ali']);
  });

  test('markTaken shows taken and looks for a suggestion', () async {
    server.free.add('ali.k');

    live.markTaken('ali', fullName: 'Ali Kaya');
    await _wait(10);

    expect(live.state.status, UsernameStatus.taken);
    expect(live.state.suggestion, 'ali.k');
  });

  test('typing after a taken name drops its suggestion', () async {
    server.free.add('ali.k');
    live.input('ali', fullName: 'Ali Kaya', immediately: true);
    await _wait(10);
    expect(live.state.suggestion, 'ali.k');

    live.input('alin');

    expect(live.state.suggestion, isNull);
    expect(live.state.status, UsernameStatus.idle);
  });

  group('UsernameSuggestions', () {
    test('the surname initial first, then numbers', () {
      expect(UsernameSuggestions.candidates('alparslan', 'Alparslan Kuloğlu'), [
        'alparslan.k',
        'alparslan1',
        'alparslan2',
        'alparslan3',
      ]);
    });

    test('the initial is Turkish lower case', () {
      expect(UsernameSuggestions.candidates('ali', 'Ali Işık').first, 'ali.ı');
      expect(UsernameSuggestions.candidates('ali', 'Ali İpek').first, 'ali.i');
    });

    test('no name, no candidates', () {
      expect(UsernameSuggestions.candidates('', 'Ali Kaya'), isEmpty);
    });
  });
}
