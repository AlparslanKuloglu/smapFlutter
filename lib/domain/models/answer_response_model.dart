final class AnswerResponseModel {
  final dynamic
  mexamFound; // Map? yerine dynamic yaptık çünkü bazen bool (false) geliyor
  final List<dynamic>? answersArray; // Map değil, List olmalı
  final String? opticImageFileName;
  final bool? success;

  AnswerResponseModel({
    this.mexamFound,
    this.success,
    this.answersArray,
    this.opticImageFileName,
  });

  factory AnswerResponseModel.fromJson(Map<String, dynamic> json) {
    return AnswerResponseModel(
      mexamFound: json['mexamFound'],
      success: json['success'] as bool?,
      // List dökümü yaparken 'as List<dynamic>?' kullanıyoruz
      answersArray: json['answersArray'] as List<dynamic>?,
      opticImageFileName: json['opticImageFileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mexamFound': mexamFound,
      'success': success,
      'answersArray': answersArray, // List olarak gönderiyoruz
      'opticImageFileName': opticImageFileName,
    };
  }
}
