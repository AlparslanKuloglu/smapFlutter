// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../login_response.dart';

class LoginResponseMapper extends ClassMapperBase<LoginResponse> {
  LoginResponseMapper._();

  static LoginResponseMapper? _instance;
  static LoginResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LoginResponseMapper._());
      UserDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LoginResponse';

  static bool? _$success(LoginResponse v) => v.success;
  static const Field<LoginResponse, bool> _f$success = Field(
    'success',
    _$success,
    opt: true,
    hook: BoolOrNullHook(),
  );
  static String? _$message(LoginResponse v) => v.message;
  static const Field<LoginResponse, String> _f$message = Field(
    'message',
    _$message,
    opt: true,
    hook: TextOrNullHook(),
  );
  static UserDto? _$user(LoginResponse v) => v.user;
  static const Field<LoginResponse, UserDto> _f$user = Field(
    'user',
    _$user,
    opt: true,
    hook: ObjectOrNullHook(),
  );

  @override
  final MappableFields<LoginResponse> fields = const {
    #success: _f$success,
    #message: _f$message,
    #user: _f$user,
  };
  @override
  final bool ignoreNull = true;

  static LoginResponse _instantiate(DecodingData data) {
    return LoginResponse(
      success: data.dec(_f$success),
      message: data.dec(_f$message),
      user: data.dec(_f$user),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static LoginResponse fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LoginResponse>(map);
  }

  static LoginResponse fromJsonString(String json) {
    return ensureInitialized().decodeJson<LoginResponse>(json);
  }
}

mixin LoginResponseMappable {
  String toJsonString() {
    return LoginResponseMapper.ensureInitialized().encodeJson<LoginResponse>(
      this as LoginResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return LoginResponseMapper.ensureInitialized().encodeMap<LoginResponse>(
      this as LoginResponse,
    );
  }

  LoginResponseCopyWith<LoginResponse, LoginResponse, LoginResponse>
  get copyWith => _LoginResponseCopyWithImpl<LoginResponse, LoginResponse>(
    this as LoginResponse,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return LoginResponseMapper.ensureInitialized().stringifyValue(
      this as LoginResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return LoginResponseMapper.ensureInitialized().equalsValue(
      this as LoginResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return LoginResponseMapper.ensureInitialized().hashValue(
      this as LoginResponse,
    );
  }
}

extension LoginResponseValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LoginResponse, $Out> {
  LoginResponseCopyWith<$R, LoginResponse, $Out> get $asLoginResponse =>
      $base.as((v, t, t2) => _LoginResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LoginResponseCopyWith<$R, $In extends LoginResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  UserDtoCopyWith<$R, UserDto, UserDto>? get user;
  $R call({bool? success, String? message, UserDto? user});
  LoginResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LoginResponseCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LoginResponse, $Out>
    implements LoginResponseCopyWith<$R, LoginResponse, $Out> {
  _LoginResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LoginResponse> $mapper =
      LoginResponseMapper.ensureInitialized();
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
  LoginResponse $make(CopyWithData data) => LoginResponse(
    success: data.get(#success, or: $value.success),
    message: data.get(#message, or: $value.message),
    user: data.get(#user, or: $value.user),
  );

  @override
  LoginResponseCopyWith<$R2, LoginResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LoginResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

