final class NfoundExamResponseModel {
  final bool? success;

  NfoundExamResponseModel({this.success});

  factory NfoundExamResponseModel.fromJson(Map<String, dynamic> json) {
    return NfoundExamResponseModel(success: json['success'] as bool?);
  }

  Map<String, dynamic> toJson() {
    return {'success': success};
  }
}
