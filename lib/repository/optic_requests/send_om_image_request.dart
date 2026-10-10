import 'package:rest_api_package/rest_api_package.dart';
import 'dart:convert';

class SendOmImageRequest extends IRestApiRequest {
  // Artık sadece String değil, dinamik bir Map alıyoruz
  final Map<String, dynamic> data;

  SendOmImageRequest({required this.data}) {
    endPoint = 'opticimage';
    requestMethod = RequestMethod.POST;

    /// Token gerekiyorsa true, gerekmiyorsa false kalabilir
    authorize = false;

    /// UI tarafında hazırladığın 'sendImageData' paketini
    /// doğrudan JSON'a çevirip body'e veriyoruz.
    body = json.encode(data);
  }
}
