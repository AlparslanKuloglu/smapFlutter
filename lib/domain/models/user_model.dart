import 'dart:convert';

class UserModel {
  final String name;
  final String role;
  final int? aimType;
  final String photo;
  final int points;
  final double progress;

  UserModel({
    required this.name,
    this.aimType,
    required this.photo,
    required this.role,
    this.points = 0,
    this.progress = 0.0,
  });

  // JSON string'i modele çevirir
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      role: json['role'] ?? 'student',
      aimType: json['aimType'] ?? 2,
      photo: json['photo'] ?? 'user.png',
      points: json['points'] ?? 0,
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }
}
