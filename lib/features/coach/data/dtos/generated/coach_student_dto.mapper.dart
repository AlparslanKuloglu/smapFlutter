// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../coach_student_dto.dart';

class CoachStudentDtoMapper extends ClassMapperBase<CoachStudentDto> {
  CoachStudentDtoMapper._();

  static CoachStudentDtoMapper? _instance;
  static CoachStudentDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CoachStudentDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CoachStudentDto';

  static String? _$id(CoachStudentDto v) => v.id;
  static const Field<CoachStudentDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(CoachStudentDto v) => v.name;
  static const Field<CoachStudentDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$firstName(CoachStudentDto v) => v.firstName;
  static const Field<CoachStudentDto, String> _f$firstName = Field(
    'firstName',
    _$firstName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$surname(CoachStudentDto v) => v.surname;
  static const Field<CoachStudentDto, String> _f$surname = Field(
    'surname',
    _$surname,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$userName(CoachStudentDto v) => v.userName;
  static const Field<CoachStudentDto, String> _f$userName = Field(
    'userName',
    _$userName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$email(CoachStudentDto v) => v.email;
  static const Field<CoachStudentDto, String> _f$email = Field(
    'email',
    _$email,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$phone(CoachStudentDto v) => v.phone;
  static const Field<CoachStudentDto, String> _f$phone = Field(
    'phone',
    _$phone,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$photo(CoachStudentDto v) => v.photo;
  static const Field<CoachStudentDto, String> _f$photo = Field(
    'photo',
    _$photo,
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$schoolNo(CoachStudentDto v) => v.schoolNo;
  static const Field<CoachStudentDto, int> _f$schoolNo = Field(
    'schoolNo',
    _$schoolNo,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$totalMexam(CoachStudentDto v) => v.totalMexam;
  static const Field<CoachStudentDto, int> _f$totalMexam = Field(
    'totalMexam',
    _$totalMexam,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$status(CoachStudentDto v) => v.status;
  static const Field<CoachStudentDto, int> _f$status = Field(
    'status',
    _$status,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$seasonType(CoachStudentDto v) => v.seasonType;
  static const Field<CoachStudentDto, int> _f$seasonType = Field(
    'seasonType',
    _$seasonType,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$aimType(CoachStudentDto v) => v.aimType;
  static const Field<CoachStudentDto, int> _f$aimType = Field(
    'aimType',
    _$aimType,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$registerType(CoachStudentDto v) => v.registerType;
  static const Field<CoachStudentDto, int> _f$registerType = Field(
    'registerType',
    _$registerType,
    opt: true,
    hook: IntOrNullHook(),
  );
  static int? _$degreePoint(CoachStudentDto v) => v.degreePoint;
  static const Field<CoachStudentDto, int> _f$degreePoint = Field(
    'degreePoint',
    _$degreePoint,
    opt: true,
    hook: IntOrNullHook(),
  );
  static DateTime? _$date(CoachStudentDto v) => v.date;
  static const Field<CoachStudentDto, DateTime> _f$date = Field(
    'date',
    _$date,
    opt: true,
    hook: DateOrNullHook(),
  );
  static String? _$coach(CoachStudentDto v) => v.coach;
  static const Field<CoachStudentDto, String> _f$coach = Field(
    'coach',
    _$coach,
    opt: true,
    hook: CoachRefHook(),
  );

  @override
  final MappableFields<CoachStudentDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #firstName: _f$firstName,
    #surname: _f$surname,
    #userName: _f$userName,
    #email: _f$email,
    #phone: _f$phone,
    #photo: _f$photo,
    #schoolNo: _f$schoolNo,
    #totalMexam: _f$totalMexam,
    #status: _f$status,
    #seasonType: _f$seasonType,
    #aimType: _f$aimType,
    #registerType: _f$registerType,
    #degreePoint: _f$degreePoint,
    #date: _f$date,
    #coach: _f$coach,
  };
  @override
  final bool ignoreNull = true;

  static CoachStudentDto _instantiate(DecodingData data) {
    return CoachStudentDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      firstName: data.dec(_f$firstName),
      surname: data.dec(_f$surname),
      userName: data.dec(_f$userName),
      email: data.dec(_f$email),
      phone: data.dec(_f$phone),
      photo: data.dec(_f$photo),
      schoolNo: data.dec(_f$schoolNo),
      totalMexam: data.dec(_f$totalMexam),
      status: data.dec(_f$status),
      seasonType: data.dec(_f$seasonType),
      aimType: data.dec(_f$aimType),
      registerType: data.dec(_f$registerType),
      degreePoint: data.dec(_f$degreePoint),
      date: data.dec(_f$date),
      coach: data.dec(_f$coach),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static CoachStudentDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CoachStudentDto>(map);
  }

  static CoachStudentDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<CoachStudentDto>(json);
  }
}

mixin CoachStudentDtoMappable {
  String toJsonString() {
    return CoachStudentDtoMapper.ensureInitialized()
        .encodeJson<CoachStudentDto>(this as CoachStudentDto);
  }

  Map<String, dynamic> toJson() {
    return CoachStudentDtoMapper.ensureInitialized().encodeMap<CoachStudentDto>(
      this as CoachStudentDto,
    );
  }

  CoachStudentDtoCopyWith<CoachStudentDto, CoachStudentDto, CoachStudentDto>
  get copyWith =>
      _CoachStudentDtoCopyWithImpl<CoachStudentDto, CoachStudentDto>(
        this as CoachStudentDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CoachStudentDtoMapper.ensureInitialized().stringifyValue(
      this as CoachStudentDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return CoachStudentDtoMapper.ensureInitialized().equalsValue(
      this as CoachStudentDto,
      other,
    );
  }

  @override
  int get hashCode {
    return CoachStudentDtoMapper.ensureInitialized().hashValue(
      this as CoachStudentDto,
    );
  }
}

extension CoachStudentDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, CoachStudentDto, $Out> {
  CoachStudentDtoCopyWith<$R, CoachStudentDto, $Out> get $asCoachStudentDto =>
      $base.as((v, t, t2) => _CoachStudentDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CoachStudentDtoCopyWith<$R, $In extends CoachStudentDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? firstName,
    String? surname,
    String? userName,
    String? email,
    String? phone,
    String? photo,
    int? schoolNo,
    int? totalMexam,
    int? status,
    int? seasonType,
    int? aimType,
    int? registerType,
    int? degreePoint,
    DateTime? date,
    String? coach,
  });
  CoachStudentDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CoachStudentDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CoachStudentDto, $Out>
    implements CoachStudentDtoCopyWith<$R, CoachStudentDto, $Out> {
  _CoachStudentDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CoachStudentDto> $mapper =
      CoachStudentDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? firstName = $none,
    Object? surname = $none,
    Object? userName = $none,
    Object? email = $none,
    Object? phone = $none,
    Object? photo = $none,
    Object? schoolNo = $none,
    Object? totalMexam = $none,
    Object? status = $none,
    Object? seasonType = $none,
    Object? aimType = $none,
    Object? registerType = $none,
    Object? degreePoint = $none,
    Object? date = $none,
    Object? coach = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (firstName != $none) #firstName: firstName,
      if (surname != $none) #surname: surname,
      if (userName != $none) #userName: userName,
      if (email != $none) #email: email,
      if (phone != $none) #phone: phone,
      if (photo != $none) #photo: photo,
      if (schoolNo != $none) #schoolNo: schoolNo,
      if (totalMexam != $none) #totalMexam: totalMexam,
      if (status != $none) #status: status,
      if (seasonType != $none) #seasonType: seasonType,
      if (aimType != $none) #aimType: aimType,
      if (registerType != $none) #registerType: registerType,
      if (degreePoint != $none) #degreePoint: degreePoint,
      if (date != $none) #date: date,
      if (coach != $none) #coach: coach,
    }),
  );
  @override
  CoachStudentDto $make(CopyWithData data) => CoachStudentDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    firstName: data.get(#firstName, or: $value.firstName),
    surname: data.get(#surname, or: $value.surname),
    userName: data.get(#userName, or: $value.userName),
    email: data.get(#email, or: $value.email),
    phone: data.get(#phone, or: $value.phone),
    photo: data.get(#photo, or: $value.photo),
    schoolNo: data.get(#schoolNo, or: $value.schoolNo),
    totalMexam: data.get(#totalMexam, or: $value.totalMexam),
    status: data.get(#status, or: $value.status),
    seasonType: data.get(#seasonType, or: $value.seasonType),
    aimType: data.get(#aimType, or: $value.aimType),
    registerType: data.get(#registerType, or: $value.registerType),
    degreePoint: data.get(#degreePoint, or: $value.degreePoint),
    date: data.get(#date, or: $value.date),
    coach: data.get(#coach, or: $value.coach),
  );

  @override
  CoachStudentDtoCopyWith<$R2, CoachStudentDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CoachStudentDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

