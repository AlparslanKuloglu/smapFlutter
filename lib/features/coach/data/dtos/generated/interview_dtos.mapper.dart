// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of '../interview_dtos.dart';

class InterviewStudentDtoMapper extends ClassMapperBase<InterviewStudentDto> {
  InterviewStudentDtoMapper._();

  static InterviewStudentDtoMapper? _instance;
  static InterviewStudentDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InterviewStudentDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'InterviewStudentDto';

  static String? _$id(InterviewStudentDto v) => v.id;
  static const Field<InterviewStudentDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$name(InterviewStudentDto v) => v.name;
  static const Field<InterviewStudentDto, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$firstName(InterviewStudentDto v) => v.firstName;
  static const Field<InterviewStudentDto, String> _f$firstName = Field(
    'firstName',
    _$firstName,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$surname(InterviewStudentDto v) => v.surname;
  static const Field<InterviewStudentDto, String> _f$surname = Field(
    'surname',
    _$surname,
    opt: true,
    hook: TextOrNullHook(),
  );
  static String? _$photo(InterviewStudentDto v) => v.photo;
  static const Field<InterviewStudentDto, String> _f$photo = Field(
    'photo',
    _$photo,
    opt: true,
    hook: TextOrNullHook(),
  );

  @override
  final MappableFields<InterviewStudentDto> fields = const {
    #id: _f$id,
    #name: _f$name,
    #firstName: _f$firstName,
    #surname: _f$surname,
    #photo: _f$photo,
  };
  @override
  final bool ignoreNull = true;

  static InterviewStudentDto _instantiate(DecodingData data) {
    return InterviewStudentDto(
      id: data.dec(_f$id),
      name: data.dec(_f$name),
      firstName: data.dec(_f$firstName),
      surname: data.dec(_f$surname),
      photo: data.dec(_f$photo),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static InterviewStudentDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InterviewStudentDto>(map);
  }

  static InterviewStudentDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<InterviewStudentDto>(json);
  }
}

mixin InterviewStudentDtoMappable {
  String toJsonString() {
    return InterviewStudentDtoMapper.ensureInitialized()
        .encodeJson<InterviewStudentDto>(this as InterviewStudentDto);
  }

  Map<String, dynamic> toJson() {
    return InterviewStudentDtoMapper.ensureInitialized()
        .encodeMap<InterviewStudentDto>(this as InterviewStudentDto);
  }

  InterviewStudentDtoCopyWith<
    InterviewStudentDto,
    InterviewStudentDto,
    InterviewStudentDto
  >
  get copyWith =>
      _InterviewStudentDtoCopyWithImpl<
        InterviewStudentDto,
        InterviewStudentDto
      >(this as InterviewStudentDto, $identity, $identity);
  @override
  String toString() {
    return InterviewStudentDtoMapper.ensureInitialized().stringifyValue(
      this as InterviewStudentDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return InterviewStudentDtoMapper.ensureInitialized().equalsValue(
      this as InterviewStudentDto,
      other,
    );
  }

  @override
  int get hashCode {
    return InterviewStudentDtoMapper.ensureInitialized().hashValue(
      this as InterviewStudentDto,
    );
  }
}

extension InterviewStudentDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InterviewStudentDto, $Out> {
  InterviewStudentDtoCopyWith<$R, InterviewStudentDto, $Out>
  get $asInterviewStudentDto => $base.as(
    (v, t, t2) => _InterviewStudentDtoCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class InterviewStudentDtoCopyWith<
  $R,
  $In extends InterviewStudentDto,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? id,
    String? name,
    String? firstName,
    String? surname,
    String? photo,
  });
  InterviewStudentDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InterviewStudentDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InterviewStudentDto, $Out>
    implements InterviewStudentDtoCopyWith<$R, InterviewStudentDto, $Out> {
  _InterviewStudentDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InterviewStudentDto> $mapper =
      InterviewStudentDtoMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    Object? name = $none,
    Object? firstName = $none,
    Object? surname = $none,
    Object? photo = $none,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (name != $none) #name: name,
      if (firstName != $none) #firstName: firstName,
      if (surname != $none) #surname: surname,
      if (photo != $none) #photo: photo,
    }),
  );
  @override
  InterviewStudentDto $make(CopyWithData data) => InterviewStudentDto(
    id: data.get(#id, or: $value.id),
    name: data.get(#name, or: $value.name),
    firstName: data.get(#firstName, or: $value.firstName),
    surname: data.get(#surname, or: $value.surname),
    photo: data.get(#photo, or: $value.photo),
  );

  @override
  InterviewStudentDtoCopyWith<$R2, InterviewStudentDto, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _InterviewStudentDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InterviewNoteDtoMapper extends ClassMapperBase<InterviewNoteDto> {
  InterviewNoteDtoMapper._();

  static InterviewNoteDtoMapper? _instance;
  static InterviewNoteDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InterviewNoteDtoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'InterviewNoteDto';

  static String? _$note(InterviewNoteDto v) => v.note;
  static const Field<InterviewNoteDto, String> _f$note = Field(
    'note',
    _$note,
    opt: true,
    hook: TextOrNullHook(),
  );
  static DateTime? _$date(InterviewNoteDto v) => v.date;
  static const Field<InterviewNoteDto, DateTime> _f$date = Field(
    'date',
    _$date,
    opt: true,
    hook: DateOrNullHook(),
  );

  @override
  final MappableFields<InterviewNoteDto> fields = const {
    #note: _f$note,
    #date: _f$date,
  };
  @override
  final bool ignoreNull = true;

  static InterviewNoteDto _instantiate(DecodingData data) {
    return InterviewNoteDto(note: data.dec(_f$note), date: data.dec(_f$date));
  }

  @override
  final Function instantiate = _instantiate;

  static InterviewNoteDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InterviewNoteDto>(map);
  }

  static InterviewNoteDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<InterviewNoteDto>(json);
  }
}

mixin InterviewNoteDtoMappable {
  String toJsonString() {
    return InterviewNoteDtoMapper.ensureInitialized()
        .encodeJson<InterviewNoteDto>(this as InterviewNoteDto);
  }

  Map<String, dynamic> toJson() {
    return InterviewNoteDtoMapper.ensureInitialized()
        .encodeMap<InterviewNoteDto>(this as InterviewNoteDto);
  }

  InterviewNoteDtoCopyWith<InterviewNoteDto, InterviewNoteDto, InterviewNoteDto>
  get copyWith =>
      _InterviewNoteDtoCopyWithImpl<InterviewNoteDto, InterviewNoteDto>(
        this as InterviewNoteDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InterviewNoteDtoMapper.ensureInitialized().stringifyValue(
      this as InterviewNoteDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return InterviewNoteDtoMapper.ensureInitialized().equalsValue(
      this as InterviewNoteDto,
      other,
    );
  }

  @override
  int get hashCode {
    return InterviewNoteDtoMapper.ensureInitialized().hashValue(
      this as InterviewNoteDto,
    );
  }
}

extension InterviewNoteDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InterviewNoteDto, $Out> {
  InterviewNoteDtoCopyWith<$R, InterviewNoteDto, $Out>
  get $asInterviewNoteDto =>
      $base.as((v, t, t2) => _InterviewNoteDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InterviewNoteDtoCopyWith<$R, $In extends InterviewNoteDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? note, DateTime? date});
  InterviewNoteDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _InterviewNoteDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InterviewNoteDto, $Out>
    implements InterviewNoteDtoCopyWith<$R, InterviewNoteDto, $Out> {
  _InterviewNoteDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InterviewNoteDto> $mapper =
      InterviewNoteDtoMapper.ensureInitialized();
  @override
  $R call({Object? note = $none, Object? date = $none}) => $apply(
    FieldCopyWithData({
      if (note != $none) #note: note,
      if (date != $none) #date: date,
    }),
  );
  @override
  InterviewNoteDto $make(CopyWithData data) => InterviewNoteDto(
    note: data.get(#note, or: $value.note),
    date: data.get(#date, or: $value.date),
  );

  @override
  InterviewNoteDtoCopyWith<$R2, InterviewNoteDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InterviewNoteDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class InterviewDtoMapper extends ClassMapperBase<InterviewDto> {
  InterviewDtoMapper._();

  static InterviewDtoMapper? _instance;
  static InterviewDtoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = InterviewDtoMapper._());
      InterviewStudentDtoMapper.ensureInitialized();
      InterviewNoteDtoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'InterviewDto';

  static String? _$id(InterviewDto v) => v.id;
  static const Field<InterviewDto, String> _f$id = Field(
    'id',
    _$id,
    key: r'_id',
    opt: true,
    hook: TextOrNullHook(),
  );
  static int? _$type(InterviewDto v) => v.type;
  static const Field<InterviewDto, int> _f$type = Field(
    'type',
    _$type,
    opt: true,
    hook: IntOrNullHook(),
  );
  static DateTime? _$date(InterviewDto v) => v.date;
  static const Field<InterviewDto, DateTime> _f$date = Field(
    'date',
    _$date,
    opt: true,
    hook: DateOrNullHook(),
  );
  static InterviewStudentDto? _$student(InterviewDto v) => v.student;
  static const Field<InterviewDto, InterviewStudentDto> _f$student = Field(
    'student',
    _$student,
    opt: true,
    hook: InterviewStudentHook(),
  );
  static List<InterviewNoteDto> _$notes(InterviewDto v) => v.notes;
  static const Field<InterviewDto, List<InterviewNoteDto>> _f$notes = Field(
    'notes',
    _$notes,
    key: r'notesStr',
    opt: true,
    def: const [],
    hook: InterviewNotesHook(),
  );

  @override
  final MappableFields<InterviewDto> fields = const {
    #id: _f$id,
    #type: _f$type,
    #date: _f$date,
    #student: _f$student,
    #notes: _f$notes,
  };
  @override
  final bool ignoreNull = true;

  static InterviewDto _instantiate(DecodingData data) {
    return InterviewDto(
      id: data.dec(_f$id),
      type: data.dec(_f$type),
      date: data.dec(_f$date),
      student: data.dec(_f$student),
      notes: data.dec(_f$notes),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static InterviewDto fromJson(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<InterviewDto>(map);
  }

  static InterviewDto fromJsonString(String json) {
    return ensureInitialized().decodeJson<InterviewDto>(json);
  }
}

mixin InterviewDtoMappable {
  String toJsonString() {
    return InterviewDtoMapper.ensureInitialized().encodeJson<InterviewDto>(
      this as InterviewDto,
    );
  }

  Map<String, dynamic> toJson() {
    return InterviewDtoMapper.ensureInitialized().encodeMap<InterviewDto>(
      this as InterviewDto,
    );
  }

  InterviewDtoCopyWith<InterviewDto, InterviewDto, InterviewDto> get copyWith =>
      _InterviewDtoCopyWithImpl<InterviewDto, InterviewDto>(
        this as InterviewDto,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return InterviewDtoMapper.ensureInitialized().stringifyValue(
      this as InterviewDto,
    );
  }

  @override
  bool operator ==(Object other) {
    return InterviewDtoMapper.ensureInitialized().equalsValue(
      this as InterviewDto,
      other,
    );
  }

  @override
  int get hashCode {
    return InterviewDtoMapper.ensureInitialized().hashValue(
      this as InterviewDto,
    );
  }
}

extension InterviewDtoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, InterviewDto, $Out> {
  InterviewDtoCopyWith<$R, InterviewDto, $Out> get $asInterviewDto =>
      $base.as((v, t, t2) => _InterviewDtoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class InterviewDtoCopyWith<$R, $In extends InterviewDto, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  InterviewStudentDtoCopyWith<$R, InterviewStudentDto, InterviewStudentDto>?
  get student;
  ListCopyWith<
    $R,
    InterviewNoteDto,
    InterviewNoteDtoCopyWith<$R, InterviewNoteDto, InterviewNoteDto>
  >
  get notes;
  $R call({
    String? id,
    int? type,
    DateTime? date,
    InterviewStudentDto? student,
    List<InterviewNoteDto>? notes,
  });
  InterviewDtoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _InterviewDtoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, InterviewDto, $Out>
    implements InterviewDtoCopyWith<$R, InterviewDto, $Out> {
  _InterviewDtoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<InterviewDto> $mapper =
      InterviewDtoMapper.ensureInitialized();
  @override
  InterviewStudentDtoCopyWith<$R, InterviewStudentDto, InterviewStudentDto>?
  get student => $value.student?.copyWith.$chain((v) => call(student: v));
  @override
  ListCopyWith<
    $R,
    InterviewNoteDto,
    InterviewNoteDtoCopyWith<$R, InterviewNoteDto, InterviewNoteDto>
  >
  get notes => ListCopyWith(
    $value.notes,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(notes: v),
  );
  @override
  $R call({
    Object? id = $none,
    Object? type = $none,
    Object? date = $none,
    Object? student = $none,
    List<InterviewNoteDto>? notes,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (type != $none) #type: type,
      if (date != $none) #date: date,
      if (student != $none) #student: student,
      if (notes != null) #notes: notes,
    }),
  );
  @override
  InterviewDto $make(CopyWithData data) => InterviewDto(
    id: data.get(#id, or: $value.id),
    type: data.get(#type, or: $value.type),
    date: data.get(#date, or: $value.date),
    student: data.get(#student, or: $value.student),
    notes: data.get(#notes, or: $value.notes),
  );

  @override
  InterviewDtoCopyWith<$R2, InterviewDto, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _InterviewDtoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

