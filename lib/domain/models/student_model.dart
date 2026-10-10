import 'package:flutter/foundation.dart';

@immutable
class Student {
  final String id;
  final String name;
  final String userName;
  final String password;
  final String photo;
  final int schoolNo;
  final int totalMexam;
  final int status;
  final int seasonType;
  final int aimType;
  final int registerType;
  final String email;
  final int degreePoint;
  final DateTime date;
  final String firstName;
  final String surname;
  final int v;
  final String phone;
  final String coach;

  const Student({
    required this.id,
    required this.name,
    required this.userName,
    required this.password,
    required this.photo,
    required this.schoolNo,
    required this.totalMexam,
    required this.status,
    required this.seasonType,
    required this.aimType,
    required this.registerType,
    required this.email,
    required this.degreePoint,
    required this.date,
    required this.firstName,
    required this.surname,
    required this.v,
    required this.phone,
    required this.coach,
  });

  Student copyWith({
    String? id,
    String? name,
    String? userName,
    String? password,
    String? photo,
    int? schoolNo,
    int? totalMexam,
    int? status,
    int? seasonType,
    int? aimType,
    int? registerType,
    String? email,
    int? degreePoint,
    DateTime? date,
    String? firstName,
    String? surname,
    int? v,
    String? phone,
    String? coach,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      photo: photo ?? this.photo,
      schoolNo: schoolNo ?? this.schoolNo,
      totalMexam: totalMexam ?? this.totalMexam,
      status: status ?? this.status,
      seasonType: seasonType ?? this.seasonType,
      aimType: aimType ?? this.aimType,
      registerType: registerType ?? this.registerType,
      email: email ?? this.email,
      degreePoint: degreePoint ?? this.degreePoint,
      date: date ?? this.date,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      v: v ?? this.v,
      phone: phone ?? this.phone,
      coach: coach ?? this.coach,
    );
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: (json['_id'] ?? '') as String,
      name: (json['name'] ?? 'Öğrenci') as String,
      userName: (json['userName'] ?? '') as String,
      password: (json['password'] ?? '') as String,
      photo: (json['photo'] ?? 'avatars/1avatarN3.png') as String,

      // Sayısal alanlarda null gelirse 0 veya varsayılan bir sayı atıyoruz
      schoolNo: (json['schoolNo'] ?? 0) as int,
      totalMexam: (json['totalMexam'] ?? 0) as int,
      status: (json['status'] ?? 0) as int,
      seasonType: (json['seasonType'] ?? 0) as int,
      aimType: (json['aimType'] ?? 0) as int,
      registerType: (json['registerType'] ?? 0) as int,
      degreePoint: (json['degreePoint'] ?? 0) as int,
      v: (json['__v'] ?? 0) as int,

      email: (json['email'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      surname: (json['surname'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      coach: (json['coach'] ?? '') as String,

      // Tarih alanı null gelirse veya parse edilemezse bugünün tarihini atasın
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'userName': userName,
      'password': password,
      'photo': photo,
      'schoolNo': schoolNo,
      'totalMexam': totalMexam,
      'status': status,
      'seasonType': seasonType,
      'aimType': aimType,
      'registerType': registerType,
      'email': email,
      'degreePoint': degreePoint,
      'date': date.toIso8601String(),
      'firstName': firstName,
      'surname': surname,
      '__v': v,
      'phone': phone,
      'coach': coach,
    };
  }
}
