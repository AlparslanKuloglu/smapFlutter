// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../check_user_response.dart';

class CheckUserResponseMapper extends ClassMapperBase<CheckUserResponse> {
  CheckUserResponseMapper._();

  static CheckUserResponseMapper? _instance;
  static CheckUserResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CheckUserResponseMapper._());
      UserDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'CheckUserResponse';

  static bool? _$success(CheckUserResponse v) => v.success;
  static const Field<CheckUserResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(CheckUserResponse v) => v.message;
  static const Field<CheckUserResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static UserDto? _$user(CheckUserResponse v) => v.user;
  static const Field<CheckUserResponse, UserDto> _f$user = Field(
    'user',
    _$user,
    opt: true,
    hook: ObjectOrNullHook(),
  );

  @override
  final MappableFields<CheckUserResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #user: _f$user,
  };
  @override
  final bool ignoreNull = true;

  static CheckUserResponse _instantiate(DecodingData data) {
    return CheckUserResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      user: data.dec(_f$user),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CheckUserResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CheckUserResponse>(map);
  }

  static CheckUserResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<CheckUserResponse>(json);
  }
}

mixin CheckUserResponseMappable {
  String toJsonString() {
    return CheckUserResponseMapper.ensureInitialized()
        .encodeJson<CheckUserResponse>(this as CheckUserResponse);
  }

  Map<String, dynamic> toJson() {
    return CheckUserResponseMapper.ensureInitialized()
        .encodeMap<CheckUserResponse>(this as CheckUserResponse);
  }

  CheckUserResponseCopyWith<
    CheckUserResponse,
    CheckUserResponse,
    CheckUserResponse
  >
  get copyWith =>
      _CheckUserResponseCopyWithImpl<CheckUserResponse, CheckUserResponse>(
        this as CheckUserResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CheckUserResponseMapper.ensureInitialized().stringifyValue(
      this as CheckUserResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return CheckUserResponseMapper.ensureInitialized().equalsValue(
      this as CheckUserResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return CheckUserResponseMapper.ensureInitialized().hashValue(
      this as CheckUserResponse,
    );
  }
}

extension CheckUserResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CheckUserResponse, $Out> {
  CheckUserResponseCopyWith<$R, CheckUserResponse, $Out>
  get $asCheckUserResponse => $base.as(
    (v, t, t2) => _CheckUserResponseCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class CheckUserResponseCopyWith<
  $R,
  $In extends CheckUserResponse,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  UserDtoCopyWith<$R, UserDto, UserDto>? get user;
  $R call({bool? success, String? message, UserDto? user});
  CheckUserResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CheckUserResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CheckUserResponse, $Out>
    implements CheckUserResponseCopyWith<$R, CheckUserResponse, $Out> {
  _CheckUserResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CheckUserResponse> $mapper =
      CheckUserResponseMapper.ensureInitialized();
  @override
  UserDtoCopyWith<$R, UserDto, UserDto>? get user =>
      $value.user?.copyWith.$chain((v) => call(user: v));
  @override
  $R call({
    Object? success = $none,
    Object? message = $none,
    Object? user = $none,
  }) => $apply(
    FieldCopyWithData({
      if (success != $none) #success: success,
      if (message != $none) #message: message,
      if (user != $none) #user: user,
    }),
  );
  @override
  CheckUserResponse $make(CopyWithData data) => CheckUserResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    user: data.get(#user, or: $value.user),
  );

  @override
  CheckUserResponseCopyWith<$R2, CheckUserResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CheckUserResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

