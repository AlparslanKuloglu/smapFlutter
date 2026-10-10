final class ImageResponseModel {
  final Map<String, dynamic>? mexamFound;
  final List<dynamic>? answersArray; // Map değil, List olmalı
  final String? opticImageFileName;
  final String? originalImageFileName;
  final bool? success;

  ImageResponseModel({
    this.mexamFound,
    this.success,
    this.answersArray,
    this.opticImageFileName,
    this.originalImageFileName,
  });

  factory ImageResponseModel.fromJson(Map<String, dynamic> json) {
    return ImageResponseModel(
      mexamFound: json['mexamFound'] as Map<String, dynamic>?,
      success: json['success'] as bool?,
      // List dökümü yaparken 'as List<dynamic>?' kullanıyoruz
      answersArray: json['answersArray'] as List<dynamic>?,
      opticImageFileName: json['opticImageFileName'] as String?,
      originalImageFileName: json['originalImageFileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mexamFound': mexamFound,
      'success': success,
      'answersArray': answersArray, // List olarak gönderiyoruz
      'opticImageFileName': opticImageFileName,
      'originalImageFileName': originalImageFileName,
    };
  }
}
