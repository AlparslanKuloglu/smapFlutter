import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

part 'generated/login_response.mapper.dart';

/// Answer of `POST /student/login`.
///
/// A 2xx or 302 status alone proves nothing (the legacy code counted a
/// redirect as success), so [isAuthenticated] looks at the body.
@MappableClass(ignoreNull: true)
class LoginResponse with LoginResponseMappable {
  const LoginResponse({this.success, this.message, this.user});

  /// Reads the body of a login answer. A body that is not a JSON object (the
  /// HTML of a redirect page, an empty answer) is an empty response, which is
  /// not authenticated.
  factory LoginResponse.fromBody(Object? data) {
    if (data is! Map) return const LoginResponse();
    return LoginResponseMapper.fromJson(Map<String, dynamic>.from(data));
  }

  /// The backend's own flag, when it sends one.
  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  /// The backend's message, when it sends one.
  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: ObjectOrNullHook())
  final UserDto? user;

  /// The credentials were accepted: the backend did not say `success: false`,
  /// and either said `success: true` or sent the user.
  bool get isAuthenticated =>
      success != false && (success == true || user != null);
}
