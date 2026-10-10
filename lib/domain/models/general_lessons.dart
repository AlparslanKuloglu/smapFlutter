import 'package:flutter/foundation.dart';

@immutable
class GeneralLesson {
  final String id;
  final String name;
  final String image;
  final int order;
  final bool isTytAyt;
  final bool isMindMap;
  final Map<String, dynamic>? stats;

  const GeneralLesson({
    required this.id,
    required this.name,
    required this.image,
    required this.order,
    required this.isTytAyt,
    required this.isMindMap,
    this.stats,
  });

  GeneralLesson copyWith({Map<String, dynamic>? stats}) {
    return GeneralLesson(
      id: id,
      name: name,
      image: image,
      order: order,
      isTytAyt: isTytAyt,
      isMindMap: isMindMap,
      stats: stats ?? this.stats,
    );
  }

  factory GeneralLesson.fromJson(Map<String, dynamic> json) {
    return GeneralLesson(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isTytAyt: (json['tytAyt'] as int?) == 1,
      isMindMap: (json['mindMap'] as int?) == 1,
      stats: json['stats'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'order': order,
      'tytAyt': isTytAyt ? 1 : 0,
      'mindMap': isMindMap ? 1 : 0,
      if (stats != null) 'stats': stats,
    };
  }

  /// Boş varsayılan nesne
  factory GeneralLesson.empty() {
    return const GeneralLesson(
      id: '',
      name: '',
      image: '',
      order: 0,
      isTytAyt: false,
      isMindMap: false,
      stats: {},
    );
  }
}
