import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class CardsRepository {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> getInfoCardsInfo() async {
    final response = await _makeRequest(
      () => _dioClient.dio.get('/student/getInfoCardsInfo'),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLessonInfoCards([String? lessonId]) async {
    final Map<String, dynamic>? queryParameters = lessonId != null
        ? {'lesson': lessonId}
        : null;

    final response = await _makeRequest(
      () => _dioClient.dio.get(
        '/student/getLessonInfoCards',
        queryParameters: queryParameters,
      ),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> learnedCard([String? itemId]) async {
    final Map<String, dynamic>? queryParameters = itemId != null
        ? {'item': itemId}
        : null;

    final response = await _makeRequest(
      () => _dioClient.dio.get(
        '/student/learnedCard',
        queryParameters: queryParameters,
      ),
    );

    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addFavoriteMobil([String? itemId]) async {
    final Map<String, dynamic>? queryParameters = itemId != null
        ? {'item': itemId}
        : null;

    final response = await _makeRequest(
      () => _dioClient.dio.get(
        '/student/addFavoriteMobil',
        queryParameters: queryParameters,
      ),
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
