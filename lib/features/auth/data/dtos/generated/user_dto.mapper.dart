// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../user_dto.dart';

class UserDtoMapper extends ClassMapperBase<UserDto> {
  UserDtoMapper._();

  static UserDtoMapper? _instance;
  static UserDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = UserDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'UserDto';

  static String? _$id(UserDto v) => v.id;
  static const Field<UserDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(UserDto v) => v.name;
  static const Field<UserDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$firstName(UserDto v) => v.firstName;
  static const Field<UserDto, String> _f$firstName = Field(
    'firstName',
    _$firstName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$surname(UserDto v) => v.surname;
  static const Field<UserDto, String> _f$surname = Field(
    'surname',
    _$surname,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$userName(UserDto v) => v.userName;
  static const Field<UserDto, String> _f$userName = Field(
    'userName',
    _$userName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$email(UserDto v) => v.email;
  static const Field<UserDto, String> _f$email = Field(
    'email',
    _$email,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$phone(UserDto v) => v.phone;
  static const Field<UserDto, String> _f$phone = Field(
    'phone',
    _$phone,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$country(UserDto v) => v.country;
  static const Field<UserDto, String> _f$country = Field(
    'country',
    _$country,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$city(UserDto v) => v.city;
  static const Field<UserDto, String> _f$city = Field(
    'city',
    _$city,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$role(UserDto v) => v.role;
  static const Field<UserDto, String> _f$role = Field(
    'role',
    _$role,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$photo(UserDto v) => v.photo;
  static const Field<UserDto, String> _f$photo = Field(
    'photo',
    _$photo,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$seasonType(UserDto v) => v.seasonType;
  static const Field<UserDto, int> _f$seasonType = Field(
    'seasonType',
    _$seasonType,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$aimType(UserDto v) => v.aimType;
  static const Field<UserDto, int> _f$aimType = Field(
    'aimType',
    _$aimType,
    opt: true,
    hook: IntOrNullHook(),
  );
  static String? _$refCode(UserDto v) => v.refCode;
  static const Field<UserDto, String> _f$refCode = Field(
    'refCode',
    _$refCode,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$coach(UserDto v) => v.coach;
  static const Field<UserDto, String> _f$coach = Field(
    'coach',
    _$coach,
    opt: true,
    hook: CoachRefHook(),
  );
  static int? _$schoolNo(UserDto v) => v.schoolNo;
  static const Field<UserDto, int> _f$schoolNo = Field(
    'schoolNo',
    _$schoolNo,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$totalMexam(UserDto v) => v.totalMexam;
  static const Field<UserDto, int> _f$totalMexam = Field(
    'totalMexam',
    _$totalMexam,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$status(UserDto v) => v.status;
  static const Field<UserDto, int> _f$status = Field(
    'status',
    _$status,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$registerType(UserDto v) => v.registerType;
  static const Field<UserDto, int> _f$registerType = Field(
    'registerType',
    _$registerType,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$degreePoint(UserDto v) => v.degreePoint;
  static const Field<UserDto, int> _f$degreePoint = Field(
    'degreePoint',
    _$degreePoint,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$points(UserDto v) => v.points;
  static const Field<UserDto, int> _f$points = Field(
    'points',
    _$points,
    opt: true,
    hook: IntOrNullHook(),
  );
  static double? _$progress(UserDto v) => v.progress;
  static const Field<UserDto, double> _f$progress = Field(
    'progress',
    _$progress,
    opt: true,
    hook: DoubleOrNullHook(),
  );
  static DateTime? _$date(UserDto v) => v.date;
  static const Field<UserDto, DateTime> _f$date = Field(
    'date',
    _$date,
    opt: true,
    hook: DateOrNullHook(),
  );

  @override
  final MappableFields<UserDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #firstName: _f$firstName,
    #surname: _f$surname,
    #userName: _f$userName,
    #email: _f$email,
    #phone: _f$phone,
    #country: _f$country,
    #city: _f$city,
    #role: _f$role,
    #photo: _f$photo,
    #seasonType: _f$seasonType,
    #aimType: _f$aimType,
    #refCode: _f$refCode,
    #coach: _f$coach,
    #schoolNo: _f$schoolNo,
    #totalMexam: _f$totalMexam,
    #status: _f$status,
    #registerType: _f$registerType,
    #degreePoint: _f$degreePoint,
    #points: _f$points,
    #progress: _f$progress,
    #date: _f$date,
  };
  @override
  final bool ignoreNull = true;

  static UserDto _instantiate(DecodingData data) {
    return UserDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      firstName: data.dec(_f$firstName),
      surname: data.dec(_f$surname),
      userName: data.dec(_f$userName),
      email: data.dec(_f$email),
      phone: data.dec(_f$phone),
      country: data.dec(_f$country),
      city: data.dec(_f$city),
      role: data.dec(_f$role),
      photo: data.dec(_f$photo),
      seasonType: data.dec(_f$seasonType),
      aimType: data.dec(_f$aimType),
      refCode: data.dec(_f$refCode),
      coach: data.dec(_f$coach),
      schoolNo: data.dec(_f$schoolNo),
      totalMexam: data.dec(_f$totalMexam),
      status: data.dec(_f$status),
      registerType: data.dec(_f$registerType),
      degreePoint: data.dec(_f$degreePoint),
      points: data.dec(_f$points),
      progress: data.dec(_f$progress),
      date: data.dec(_f$date),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static UserDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<UserDto>(map);
  }

  static UserDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<UserDto>(json);
  }
}

mixin UserDtoMappable {
  String toJsonString() {
    return UserDtoMapper.ensureInitialized().encodeJson<UserDto>(
      this as UserDto,
    );
  }

  Map<String, dynamic> toJson() {
    return UserDtoMapper.ensureInitialized().encodeMap<UserDto>(
      this as UserDto,
    );
  }

  UserDtoCopyWith<UserDto, UserDto, UserDto> get copyWith =>
      _UserDtoCopyWithImpl<UserDto, UserDto>(
        this as UserDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return UserDtoMapper.ensureInitialized().stringifyValue(this as UserDto);
  }

  @override
  bool operator ==(Object other) {
    return UserDtoMapper.ensureInitialized().equalsValue(
      this as UserDto,
      other,
    );
  }

  @override
  int get hashCode {
    return UserDtoMapper.ensureInitialized().hashValue(this as UserDto);
  }
}

extension UserDtoValueCopy<$R, $Out> on ObjectCopyWith<$R, UserDto, $Out> {
  UserDtoCopyWith<$R, UserDto, $Out> get $asUserDto =>
      $base.as((v, t, t2) => _UserDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class UserDtoCopyWith<$R, $In extends UserDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? firstName,
    String? surname,
    String? userName,
    String? email,
    String? phone,
    String? country,
    String? city,
    String? role,
    String? photo,
    int? seasonType,
    int? aimType,
    String? refCode,
    String? coach,
    int? schoolNo,
    int? totalMexam,
    int? status,
    int? registerType,
    int? degreePoint,
    int? points,
    double? progress,
    DateTime? date,
  });
  UserDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _UserDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, UserDto, $Out>
    implements UserDtoCopyWith<$R, UserDto, $Out> {
  _UserDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<UserDto> $mapper =
      UserDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? firstName = $none,
    Object? surname = $none,
    Object? userName = $none,
    Object? email = $none,
    Object? phone = $none,
    Object? country = $none,
    Object? city = $none,
    Object? role = $none,
    Object? photo = $none,
    Object? seasonType = $none,
    Object? aimType = $none,
    Object? refCode = $none,
    Object? coach = $none,
    Object? schoolNo = $none,
    Object? totalMexam = $none,
    Object? status = $none,
    Object? registerType = $none,
    Object? degreePoint = $none,
    Object? points = $none,
    Object? progress = $none,
    Object? date = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (firstName != $none) #firstName: firstName,
      if (surname != $none) #surname: surname,
      if (userName != $none) #userName: userName,
      if (email != $none) #email: email,
      if (phone != $none) #phone: phone,
      if (country != $none) #country: country,
      if (city != $none) #city: city,
      if (role != $none) #role: role,
      if (photo != $none) #photo: photo,
      if (seasonType != $none) #seasonType: seasonType,
      if (aimType != $none) #aimType: aimType,
      if (refCode != $none) #refCode: refCode,
      if (coach != $none) #coach: coach,
      if (schoolNo != $none) #schoolNo: schoolNo,
      if (totalMexam != $none) #totalMexam: totalMexam,
      if (status != $none) #status: status,
      if (registerType != $none) #registerType: registerType,
      if (degreePoint != $none) #degreePoint: degreePoint,
      if (points != $none) #points: points,
      if (progress != $none) #progress: progress,
      if (date != $none) #date: date,
    }),
  );
  @override
  UserDto $make(CopyWithData data) => UserDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    firstName: data.get(#firstName, or: $value.firstName),
    surname: data.get(#surname, or: $value.surname),
    userName: data.get(#userName, or: $value.userName),
    email: data.get(#email, or: $value.email),
    phone: data.get(#phone, or: $value.phone),
    country: data.get(#country, or: $value.country),
    city: data.get(#city, or: $value.city),
    role: data.get(#role, or: $value.role),
    photo: data.get(#photo, or: $value.photo),
    seasonType: data.get(#seasonType, or: $value.seasonType),
    aimType: data.get(#aimType, or: $value.aimType),
    refCode: data.get(#refCode, or: $value.refCode),
    coach: data.get(#coach, or: $value.coach),
    schoolNo: data.get(#schoolNo, or: $value.schoolNo),
    totalMexam: data.get(#totalMexam, or: $value.totalMexam),
    status: data.get(#status, or: $value.status),
    registerType: data.get(#registerType, or: $value.registerType),
    degreePoint: data.get(#degreePoint, or: $value.degreePoint),
    points: data.get(#points, or: $value.points),
    progress: data.get(#progress, or: $value.progress),
    date: data.get(#date, or: $value.date),
  );

  @override
  UserDtoCopyWith<$R2, UserDto, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _UserDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

