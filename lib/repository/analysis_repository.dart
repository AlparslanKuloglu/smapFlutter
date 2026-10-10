import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class AnalysisRepository {
  final Dio _dio;

  // Repository artık hangi öğrenci için çalışacağını nesne üretilirken biliyor
  final String? studentId;

  // 🧠 AKILLI CONSTRUCTOR:
  // Eğer çağrıldığı yerde 'dio' enjekte edilmezse, arka planda otomatik olarak
  // bizim yeni çerez interceptor'lı 'DioClient().dio' nesnesini bağlar.
  // Bu sayede projedeki diğer hiçbir sayfa veya dosya derleme hatası vermez!
  AnalysisRepository({Dio? dio, this.studentId})
    : _dio = dio ?? DioClient().dio;

  /// 1. Çizgi grafik verilerini getirir
  Future<Map<String, dynamic>> getLineChartData({
    String? type,
    dynamic lesson,
    dynamic selectedAimType,
  }) async {
    final Map<String, dynamic> params = {
      'type': type,
      'lesson': lesson,
      'aimType': selectedAimType,
    };

    params.removeWhere((key, value) {
      if (value == null || value == '') return true;
      if (key == 'lesson' && value is String && value.length <= 12) return true;
      if (key == 'aimType') {
        final currentType = params['type']?.toString();
        if (currentType == "1" || value == 1) return true;
      }
      return false;
    });

    final response = await _makeRequest(
      (finalQuery) =>
          _dio.get('/student/getLineChartData', queryParameters: finalQuery),
      initialParams: params,
    );
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLessons() async {
    final response = await _makeRequest(
      (finalQuery) =>
          _dio.get('/student/getLessons', queryParameters: finalQuery),
    );
    return response['lessons'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getTotal({
    dynamic general,
    String? type,
    String? lesson,
    dynamic selectedAimType,
  }) async {
    final queryParams = {
      'general': general,
      'type': type,
      'lesson': lesson,
      'aimType': selectedAimType,
    };

    queryParams.removeWhere((key, value) {
      if (value == null || value == '') return true;
      if (key == 'aimType' && value == 0) return true;
      if (key == 'lesson' && value is String && value.length <= 12) return true;
      if (key == 'aimType') {
        final currentType = queryParams['type']?.toString();
        if (currentType == "1" || value == 1) return true;
      }
      return false;
    });

    // DÜZELTİLDİ: queryParameters alanına queryParams yerine finalQuery verildi.
    final response = await _makeRequest(
      (finalQuery) =>
          _dio.get('/student/getTotal', queryParameters: finalQuery),
      initialParams: queryParams,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyMockExams({
    dynamic page,
    List<String>? types,
    List<String>? dates,
    List<String>? nets,
  }) async {
    final Map<String, dynamic> queryParams = {
      if (page != null) 'page': page,
      'perPage': 8,
    };

    final Map<String, dynamic> bodyData = {
      "filter": {
        "types": types ?? [],
        "nets": nets ?? [],
        "dates": dates ?? [],
      },
    };

    final response = await _makeRequest(
      (finalQuery) => _dio.post(
        '/student/getMyMockExams',
        queryParameters: finalQuery,
        data: bodyData,
      ),
      initialParams: queryParams,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMexamSubjectDetail({String? mexamId}) async {
    final queryParams = {'mexamId': mexamId};
    final response = await _makeRequest(
      (finalQuery) => _dio.get(
        '/student/getMexamSubjectDetail',
        queryParameters: finalQuery,
      ),
      initialParams: queryParams,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMexamItemDetail({String? mexamId}) async {
    final queryParams = {'mexamId': mexamId};
    final response = await _makeRequest(
      (finalQuery) =>
          _dio.get('/student/getMexamItemDetail', queryParameters: finalQuery),
      initialParams: queryParams,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getQuestion({
    required dynamic mexam,
    required int questionOrder,
    required int lessonOrder,
  }) async {
    final Map<String, dynamic> bodyData = {
      "mexam": mexam,
      "questionOrder": questionOrder,
      "lessonOrder": lessonOrder,
    };

    final response = await _makeRequest(
      (finalQuery) => _dio.post(
        '/student/getQuestion',
        queryParameters: finalQuery,
        data: bodyData,
      ),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMainSubjects({String? lessonId}) async {
    final Map<String, dynamic> params = {'lessonId': lessonId};

    // DÜZELTİLDİ: queryParameters alanına params yerine finalQuery verildi.
    final response = await _makeRequest(
      (finalQuery) =>
          _dio.get('/student/mainSubjects', queryParameters: finalQuery),
      initialParams: params,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSubSubjectsAndItems({
    String? mainSubjectId,
    String? edebiyat,
    String? yazarEserMode,
    int? type,
  }) async {
    final Map<String, dynamic> params = {'mainSubjectId': mainSubjectId};
    final subSubjectsResponse =
        await _makeRequest(
              (finalQuery) => _dio.get(
                '/student/getSubSubjects',
                queryParameters: finalQuery,
              ),
              initialParams: params,
            )
            as Map<String, dynamic>;

    if (subSubjectsResponse['success'] == true &&
        subSubjectsResponse['subSubjects'] != null) {
      final List<dynamic> subSubjectsList = subSubjectsResponse['subSubjects'];
      final List<String> subjectIds = subSubjectsList
          .map((item) => item['_id'].toString())
          .toList();

      if (subjectIds.isNotEmpty) {
        final Map<String, dynamic> paramsGetItems = {
          'edebiyat': edebiyat,
          "yazarEserMode": yazarEserMode,
          "type": type,
        };

        final itemsResponse =
            await _makeRequest(
                  (finalQuery) => _dio.post(
                    '/student/getItems',
                    data: {'subjectIds': subjectIds, 'type': type},
                    queryParameters: finalQuery,
                  ),
                  initialParams: paramsGetItems,
                )
                as Map<String, dynamic>;

        return {
          'success': true,
          'subSubjects': subSubjectsList,
          'itemsArray': itemsResponse['itemsArray'] ?? [],
        };
      }
    }
    return {'success': false, 'message': 'Sub-subjects or items not found'};
  }

  Future<Map<String, dynamic>> getYazarEserMainSubjects() async {
    final response = await _makeRequest(
      (finalQuery) => _dio.get(
        '/student/yazarEserMainSubjects',
        queryParameters: finalQuery,
      ),
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSubjectAuthors(String? itemId) async {
    final Map<String, dynamic> params = {'itemId': itemId};
    final response = await _makeRequest(
      (finalQuery) =>
          _dio.get('/student/getSubjectAuthors', queryParameters: finalQuery),
      initialParams: params,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> learnedItem(String? itemId) async {
    final Map<String, dynamic> params = {'itemId': itemId};
    final response = await _makeRequest(
      (finalQuery) =>
          _dio.get('/student/learnedItem', queryParameters: finalQuery),
      initialParams: params,
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
      //print('🚀 [API ISTEK]: ${response.requestOptions.uri}');
      //print('📥 [API RESPONSE]: ${response.data}');
      //print("makeRequest: ${response.requestOptions.uri}, $studentId ");

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
