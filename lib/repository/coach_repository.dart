import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class CoachRepository {
  final DioClient _dioClient = DioClient();

  Future<dynamic> getInterviews({
    required int page,
    required int limit,
    List<int>? types, // İstediğin filtre tipleri örn: [2]
    List<String>? dates, // İstediğin tarihler örn: ["2026-06-28"]
  }) async {
    // Backend'in beklediği body (json) yapısı
    final Map<String, dynamic> requestBody = {
      "filter": {"types": types ?? [], "dates": dates ?? []},
    };

    // İstek sayfalama parametrelerini initialParams olarak gönderiyoruz,
    // _makeRequest içindeki finalQuery buraya bağlanıyor.
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.post(
        '/coach/getInterviews',
        queryParameters:
            finalQuery, // {'page': page, 'limit': limit} buraya gelecek
        data: requestBody,
      ),
      initialParams: {'page': page, 'limit': limit},
    );

    return response;
  }

  Future<Map<String, dynamic>> addInterview(
    Map<String, dynamic> payload,
  ) async {
    final response = await _makeRequest(
      (finalQuery) =>
          _dioClient.dio.post('/coach/addNewInterview', data: payload),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addNewNote(Map<String, dynamic> payload) async {
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.post('/coach/addNewNote', data: payload),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> editNote(Map<String, dynamic> payload) async {
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.post('/coach/editNote', data: payload),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteNote(Map<String, dynamic> payload) async {
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.post('/coach/deleteNote', data: payload),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkUsername(String username) async {
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.get(
        '/ajax/checkUsername',
        queryParameters: {'name': username},
      ),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addStudent(Map<String, dynamic> payload) async {
    final response = await _makeRequest(
      (finalQuery) =>
          _dioClient.dio.post('/coach/addNewStudent', data: payload),
    );

    return response as Map<String, dynamic>;
  }

  // -------------------------------------------------------------------------------------------------

  Future<dynamic> _makeRequest(
    Future<Response<dynamic>> Function(Map<String, dynamic> finalQuery)
    request, {
    Map<String, dynamic>? initialParams,
  }) async {
    try {
      final Map<String, dynamic> finalQuery = initialParams != null
          ? Map<String, dynamic>.from(initialParams)
          : <String, dynamic>{};

      // İstek burada atılıyor
      final response = await request(finalQuery);
      print('🚀 [API ISTEK]: ${response.requestOptions.uri}');
      print('📥 [API RESPONSE]: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) return data;
        throw Exception(data['message'] ?? 'Sunucu hata bildirdi');
      }
      throw Exception('Bağlantı hatası: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ [SUNUCUDAN GELEN HATA MESAJI]: ${e.response?.data}');
      throw Exception('Ağ hatası: ${e.message}');
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}
