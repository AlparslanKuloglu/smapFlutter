import 'package:dart_mappable/dart_mappable.dart';

import 'package:smap/features/auth/data/dtos/lenient_hooks.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

part 'generated/check_user_response.mapper.dart';

/// Answer of `GET /ajax/checkUser`: is the cookie session valid, and who owns
/// it.
@MappableClass(ignoreNull: true)
class CheckUserResponse with CheckUserResponseMappable {
  const CheckUserResponse({this.success, this.message, this.user});

  /// Reads the body of a check answer. A body that is not a JSON object is an
  /// empty response, which is not signed in.
  factory CheckUserResponse.fromBody(Object? data) {
    if (data is! Map) return const CheckUserResponse();
    return CheckUserResponseMapper.fromJson(Map<String, dynamic>.from(data));
  }

  @MappableField(hook: BoolOrNullHook())
  final bool? success;

  @MappableField(hook: TextOrNullHook())
  final String? message;

  @MappableField(hook: ObjectOrNullHook())
  final UserDto? user;

  /// The session is valid: the legacy check (`success == true` and a user).
  bool get isSignedIn => success == true && user != null;
}
