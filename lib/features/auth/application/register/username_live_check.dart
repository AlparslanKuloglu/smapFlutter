import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/coach/domain/username_check.dart';

/// Asks the server whether a user name is free
/// (`CoachStudentRepository.checkUsername`; no session needed).
typedef UsernameChecker =
    Future<AppResult<UsernameCheck>> Function(String name);

/// How long the sign-up form waits after the last key before it asks whether
/// the user name is free (task E4: 600 ms; the design token
/// `SmapDurations.usernameDebounce` and pano 2.5 say 400 ms).
const Duration kUsernameDebounce = Duration(milliseconds: 600);

/// How many other names are tried when one is taken, to offer a free one
/// (pano 2.6 kare 1 "Boşta olan:").
const int kMaxSuggestionChecks = 3;

/// Where the live check of the user name stands.
enum UsernameStatus {
  /// Nothing asked (empty name, still typing, or the answer was unusable).
  idle,

  /// The server is being asked: a spinner at the right of the field.
  checking,

  /// "Bu kullanıcı adı boşta."
  available,

  /// "Bu kullanıcı adı alınmış."
  taken,

  /// The device has no connection: "Bağlanınca kontrol edilecek."
  offline,
}

/// The state of the live check, the value a selector compares.
@immutable
class UsernameCheckState {
  const UsernameCheckState({
    this.status = UsernameStatus.idle,
    this.name = '',
    this.suggestion,
  });

  final UsernameStatus status;

  /// The name [status] is about.
  final String name;

  /// A free name found by asking the server, offered while [status] is
  /// [UsernameStatus.taken].
  final String? suggestion;

  @override
  bool operator ==(Object other) =>
      other is UsernameCheckState &&
      other.status == status &&
      other.name == name &&
      other.suggestion == suggestion;

  @override
  int get hashCode => Object.hash(status, name, suggestion);

  @override
  String toString() => 'UsernameCheckState($status, $name, $suggestion)';
}

/// The live "is this user name free" check of the sign-up form (pano 2.5 kare
/// 1, 2.6 kare 1).
///
/// [input] restarts the debounce; when it runs out the name goes to
/// [checker]. An answer that arrives after the name changed is dropped. A
/// taken name starts a short search for a free one built from it and the
/// surname ([UsernameSuggestions]); each candidate is checked by the server
/// too, so a suggestion is never a guess.
///
/// A failed check changes nothing but the offline case: the register call
/// itself answers the question in the end.
class UsernameLiveCheck {
  UsernameLiveCheck({
    required UsernameChecker checker,
    required VoidCallback onChanged,
    this.debounce = kUsernameDebounce,
  }) : _checker = checker,
       _onChanged = onChanged;

  final UsernameChecker _checker;
  final VoidCallback _onChanged;
  final Duration debounce;

  UsernameCheckState _state = const UsernameCheckState();
  Timer? _timer;
  int _epoch = 0;
  Future<void> _running = Future<void>.value();
  bool _disposed = false;

  UsernameCheckState get state => _state;

  /// Reports a new value of the user name field. [name] is already
  /// normalized; [fullName] feeds the suggestions.
  ///
  /// With [immediately] the check starts now (a tapped suggestion, a submit).
  void input(String name, {String fullName = '', bool immediately = false}) {
    // The same name again (a focus change, a re-typed last character) keeps
    // the answer it has, or the check already running.
    if (name == _state.name && _state.status != UsernameStatus.idle) return;
    _timer?.cancel();
    final epoch = ++_epoch;
    _set(UsernameCheckState(name: name));
    if (name.isEmpty) return;
    if (immediately) {
      _running = _check(name, fullName, epoch);
    } else {
      _timer = Timer(debounce, () => _running = _check(name, fullName, epoch));
    }
  }

  /// Marks [name] as taken, for a register call that came back with "user
  /// name in use". Starts the search for a suggestion.
  void markTaken(String name, {String fullName = ''}) {
    _timer?.cancel();
    final epoch = ++_epoch;
    _set(UsernameCheckState(status: UsernameStatus.taken, name: name));
    _running = _suggest(name, fullName, epoch);
  }

  /// Completes when the check in flight (if any) has an answer; starts a
  /// pending debounced one at once.
  Future<void> settle(String name, {String fullName = ''}) async {
    if (_timer?.isActive ?? false) {
      input(name, fullName: fullName, immediately: true);
    }
    await _running;
  }

  Future<void> _check(String name, String fullName, int epoch) async {
    _timer = null;
    _set(UsernameCheckState(status: UsernameStatus.checking, name: name));
    final result = await _checker(name);
    if (_stale(epoch)) return;
    final check = result.fold<UsernameCheck?>((failure) {
      _set(
        UsernameCheckState(
          status: failure.code == AppErrorCode.offline
              ? UsernameStatus.offline
              : UsernameStatus.idle,
          name: name,
        ),
      );
      return null;
    }, (check) => check);
    if (check == null) return;
    if (check.available) {
      _set(UsernameCheckState(status: UsernameStatus.available, name: name));
      return;
    }
    _set(UsernameCheckState(status: UsernameStatus.taken, name: name));
    await _suggest(name, fullName, epoch);
  }

  Future<void> _suggest(String name, String fullName, int epoch) async {
    final candidates = UsernameSuggestions.candidates(
      name,
      fullName,
    ).take(kMaxSuggestionChecks);
    for (final candidate in candidates) {
      final result = await _checker(candidate);
      if (_stale(epoch)) return;
      final free = result.fold((_) => false, (check) => check.available);
      if (free) {
        _set(
          UsernameCheckState(
            status: UsernameStatus.taken,
            name: name,
            suggestion: candidate,
          ),
        );
        return;
      }
    }
  }

  bool _stale(int epoch) => _disposed || epoch != _epoch;

  void _set(UsernameCheckState next) {
    if (_disposed || next == _state) return;
    _state = next;
    _onChanged();
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
  }
}

/// Other user names to try when one is taken.
abstract final class UsernameSuggestions {
  /// Candidates in the order they are tried: the name with the initial of the
  /// surname ("alparslan" + "Kuloğlu" → "alparslan.k"), then with a number.
  /// Each is a valid user name; none equals [taken].
  static List<String> candidates(String taken, String fullName) {
    if (taken.isEmpty) return const [];
    final words = fullName.trim().split(RegExp(r'\s+'));
    final initial = words.length > 1 && words.last.isNotEmpty
        ? _initial(words.last)
        : '';
    final result = <String>[
      if (initial.isNotEmpty) '$taken.$initial',
      '${taken}1',
      '${taken}2',
      '${taken}3',
    ];
    return result.where((name) => name != taken).toList(growable: false);
  }

  static String _initial(String word) {
    final first = String.fromCharCode(word.runes.first);
    return RegExp(r'^[\p{L}\p{N}]$', unicode: true).hasMatch(first)
        ? TurkishText.lower(first)
        : '';
  }
}
