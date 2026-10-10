import 'package:rest_api_package/rest_api_package.dart';
import 'dart:convert';

class SendNfoundExamRequest extends IRestApiRequest {
  final Map<String, dynamic> examData;

  SendNfoundExamRequest({required this.examData}) {
    // Endpoint'i ihtiyacına göre güncelleyebilirsin (Örn: 'verify-answers')
    endPoint = 'examrequest';
    requestMethod = RequestMethod.POST;

    // Eğer giriş yapmış bir kullanıcıysa true yapabilirsin
    authorize = false;

    // Body artık sadece senin JSON verini içeriyor
    body = json.encode(examData);
  }
}
