import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class ProfileRepository {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> getProfileData({String? mexamId}) async {
    final queryParams = {'mexamId': mexamId};

    final response = await _makeRequest(
      () => _dioClient.dio.get(
        '/student/getMexamSubjectDetail',
        queryParameters: queryParams,
      ),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStudentsCoach() async {
    final response = await _makeRequest(
      () => _dioClient.dio.get('/student/getStudentsCoach'),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addCoach({String? refCode}) async {
    final queryParams = {'code': refCode};
    final response = await _makeRequest(
      () =>
          _dioClient.dio.get('/student/addCoach', queryParameters: queryParams),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteCoach({String? coachId}) async {
    final queryParams = {'coach': coachId};
    final response = await _makeRequest(
      () => _dioClient.dio.get('/student/deleteCoach'),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> bodyData,
  ) async {
    // Not: Endpoint'i kendi backend yapına göre (örn: '/student/update-profile') güncelleyebilirsin.
    final response = await _makeRequest(
      () => _dioClient.dio.post('/student/updateStudent', data: bodyData),
    );

    return response as Map<String, dynamic>;
  }

  /// Merkezi İstek Yönetimi (Private)
  Future<dynamic> _makeRequest(Future<Response> Function() request) async {
    try {
      final response = await request();

      // --- DEBUG PRINT BÖLÜMÜ ---
      /*
      print(
        '🚀 [API ISTEK]: ${response.requestOptions.uri}',
      ); // Tam URL (Query params dahil)
      print('📥 [API RESPONSE]: ${response.data}');
      */
      // --------------------------

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? 'Sunucu hata bildirdi');
        }
      } else {
        throw Exception('Bağlantı hatası: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Hata durumunda da hangi URL'de hata olduğunu görmek hayat kurtarır
      print(
        '❌ [SUNUCUDAN GELEN HATA MESAJI]: ${e.response?.data}',
      ); // <-- Bunu ekle
      print('❌ [API HATA - URL]: ${e.requestOptions.uri}');
      print('❌ [API HATA - MESAJ]: ${e.message}');
      throw Exception('Ağ hatası: ${e.message}');
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}
