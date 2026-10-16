import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class WeeklyRepository {
  final DioClient _dioClient = DioClient();

  final String? studentId;

  WeeklyRepository({this.studentId});

  Map<String, dynamic>? _cachedSubjects;

  Future<Map<String, dynamic>> getAllMainSubjects() async {
    if (_cachedSubjects != null) {
      return _cachedSubjects!;
    }
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.get(
        '/student/getAllMainSubjects',
        queryParameters: finalQuery,
      ),
    );
    if (response['success']) {
      _cachedSubjects = response; // Gelen veriyi önbelleğe al
    }
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyWeeklies([
    Map<String, dynamic>? bodyData,
  ]) async {
    // Eğer bodyData gönderilmemişse veya null ise default yükü ata
    final Map<String, dynamic> requestBody =
        bodyData ??
        {
          "filter": {"dates": []},
        };

    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.post(
        '/student/getMyWeeklies',
        data: requestBody,
        queryParameters: finalQuery, // studentId otomatik enjekte edilir
      ),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addWeekly(Map<String, dynamic> payload) async {
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.post(
        '/student/addNewProgram',
        data: payload,
        queryParameters: finalQuery, // studentId otomatik enjekte edilir
      ),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProgram(
    Map<String, dynamic> payload,
  ) async {
    final response = await _makeRequest(
      (finalQuery) => _dioClient.dio.post(
        '/student/updateProgram',
        data: payload,
        queryParameters: finalQuery, // studentId otomatik enjekte edilir
      ),
    );

    return response as Map<String, dynamic>;
  }

  /// Merkezi İstek Yönetimi (Sihirli Nokta 🪄)
  Future<dynamic> _makeRequest(
    Future<Response> Function(Map<String, dynamic> finalQuery) request, {
    Map<String, dynamic>? initialParams,
  }) async {
    try {
      final Map<String, dynamic> finalQuery = initialParams != null
          ? Map<String, dynamic>.from(initialParams)
          : <String, dynamic>{};

      // Reponun kendi instance'ındaki studentId'yi otomatik enjekte ediyoruz!
      if (studentId != null && studentId!.isNotEmpty) {
        finalQuery['studentId'] = studentId;
      }

      final response = await request(finalQuery);

      // --- DEBUG PRINT BÖLÜMÜ ---
      print('🚀 [API ISTEK]: ${response.requestOptions.uri}');
      print('📥 [API RESPONSE]: ${response.data}');
      print("makeRequest: ${response.requestOptions.uri}, $studentId ");
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
      print('❌ [SUNUCUDAN GELEN HATA MESAJI]: ${e.response?.data}');
      print('❌ [API HATA - URL]: ${e.requestOptions.uri}');
      print('❌ [API HATA - MESAJ]: ${e.message}');
      throw Exception('Ağ hatası: ${e.message}');
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }
}
