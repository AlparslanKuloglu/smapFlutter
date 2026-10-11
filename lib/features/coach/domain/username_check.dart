import 'package:flutter/foundation.dart';

/// Answer of the live username check (`GET /ajax/checkUsername`).
///
/// The server sends no suggestion (spec §6.3 #12 asks for one); the form shows
/// only taken or free.
@immutable
class UsernameCheck {
  const UsernameCheck({required this.available});

  /// `true` when nobody has the name.
  final bool available;
}
