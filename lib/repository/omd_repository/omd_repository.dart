import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:rest_api_package/rest_api_package.dart';
import 'package:smap/domain/models/answer_response_model.dart';
import 'package:smap/domain/models/image_response_model.dart';
import 'package:smap/domain/models/nFoundexam_response_model.dart';
import 'package:smap/http_service/rest_api_http_service.dart';
import 'package:smap/repository/optic_requests/requests/send_answers_request.dart';
import 'package:smap/repository/optic_requests/requests/send_notfoundexam_request.dart';
import 'package:smap/repository/optic_requests/requests/send_om_image_request.dart';


@immutable
final class OmdRepository {
  RestApiHttpService get _restApiHttpService =>
      RestApiHttpServiceClass.restApiHttpService;

  ///
  /// İşlem başarılı ise geriye ImageResponseModel döner değilse String hata mesajı döner
  ///
  Future<Either<String, ImageResponseModel>> sendOMImageToServer({
    required Map<String, dynamic> data, // String yerine Map yaptık
  }) async {
    try {
      return await _restApiHttpService
          .requestAndHandle<ImageResponseModel?>(
            // Request modeline tüm map'i gönderiyoruz
            SendOmImageRequest(data: data),
            parseModel: ImageResponseModel.fromJson,
          )
          .then((response) {
            if (response != null) {
              return Right(response);
            } else {
              throw "Response is Null";
            }
          });
    } catch (e) {
      debugPrint("Http Image Send Error $e");
      return Left("Http Image Send Error $e");
    }
  }

  Future<Either<String, AnswerResponseModel>> sendAnswerArrayToServer({
    required Map<String, dynamic> responseData, // Sadece JSON verisi
  }) async {
    try {
      return await _restApiHttpService
          .requestAndHandle<AnswerResponseModel?>(
            // Request sınıfınızın sadece responseData (JSON) kabul ettiğini varsayıyorum
            SendAnswerRequest(answerData: responseData),
            parseModel: AnswerResponseModel.fromJson,
          )
          .then((response) {
            if (response != null) {
              return Right(response);
            } else {
              throw "Sunucudan boş yanıt döndü.";
            }
          });
    } catch (e) {
      debugPrint("JSON Gönderim Hatası 69: $e");
      return Left("Hata: $e");
    }
  }

  Future<Either<String, NfoundExamResponseModel>> sendExamDetailToServer({
    required Map<String, dynamic> examData, // Sadece JSON verisi
  }) async {
    try {
      return await _restApiHttpService
          .requestAndHandle<NfoundExamResponseModel?>(
            // Request sınıfınızın sadece responseData (JSON) kabul ettiğini varsayıyorum
            SendNfoundExamRequest(examData: examData),
            parseModel: NfoundExamResponseModel.fromJson,
          )
          .then((response) {
            if (response != null) {
              return Right(response);
            } else {
              throw "Sunucudan boş yanıt döndü.";
            }
          });
    } catch (e) {
      debugPrint("JSON Gönderim Hatası 92: $e");
      return Left("Hata: $e");
    }
  }
}
