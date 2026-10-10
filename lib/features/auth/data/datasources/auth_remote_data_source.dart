import 'package:dio/dio.dart';
import 'package:smap/core/network/dio_client.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  // Dışarıdan bir dio verilmezse, otomatik olarak bizim akıllı ve interceptor'lı DioClient().dio nesnemizi bağlar.
  AuthRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<Response<dynamic>> login({
    required String username,
    required String password,
  }) async {
    return _dio.post<dynamic>(
      '/student/login',
      data: <String, String>{'username': username, 'password': password},
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );
  }

  Future<Response<dynamic>> register({
    required Map<String, dynamic> payload,
  }) async {
    // 🧼 TEMİZLİK: Manuel çerez ekleme satırları ve sessionCookie parametresi uçuruldu.
    final int userType = payload["userType"];
    final Map<String, dynamic> userJson = payload["userJson"];

    return _dio.post<dynamic>(
      '/student/register',
      data: {"userType": userType, "data": userJson},
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );
  }

  Future<Response<String>> validateSession() {
    // 🧼 TEMİZLİK: Manuel çerez ekleme satırları ve sessionCookie parametresi uçuruldu.
    return _dio.get<String>(
      '/ajax/checkUser',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(seconds: 5),
        sendTimeout: const Duration(seconds: 5),
      ),
    );
  }

  Future<Response<dynamic>> logout() async {
    return _dio.get<dynamic>(
      '/ajax/logout',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );
  }

  Future<Response<dynamic>> getLegalDocuments() async {
    return _dio.get<dynamic>(
      '/ajax/getLegalDocuments',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );
  }

  Future<Response<dynamic>> deleteAccount() async {
    return _dio.get<dynamic>(
      '/ajax/deleteAccount',
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
        receiveTimeout: const Duration(seconds: 8),
        sendTimeout: const Duration(seconds: 8),
      ),
    );
  }
}
