import 'package:rest_api_package/rest_api_package.dart';
import 'dart:convert';

class SendAnswerRequest extends IRestApiRequest {
  final Map<String, dynamic> answerData;

  SendAnswerRequest({required this.answerData}) {
    // Endpoint'i ihtiyacına göre güncelleyebilirsin (Örn: 'verify-answers')
    endPoint = 'answerArray';
    requestMethod = RequestMethod.POST;

    // Eğer giriş yapmış bir kullanıcıysa true yapabilirsin
    authorize = false;

    // Body artık sadece senin JSON verini içeriyor
    body = json.encode(answerData);
  }
}
