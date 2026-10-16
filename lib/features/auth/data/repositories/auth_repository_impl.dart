import 'package:dio/dio.dart';
import 'package:studentmap/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:studentmap/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:studentmap/features/auth/domain/repositories/auth_repository.dart';
import 'dart:convert';
import 'package:studentmap/features/shared/presentation/provider/user_provider.dart';
import 'package:studentmap/core/network/dio_client.dart';
import 'package:studentmap/domain/models/legal_document.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required UserProvider userProvider,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource,
       _userProvider = userProvider;

  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final UserProvider _userProvider;

  @override
  Future<bool> validateSession() async {
    try {
      // 🧼 TEMİZLİK: sessionCookie parametresi remoteDataSource'tan kaldırıldığı için kaldırıldı.
      final response = await _remoteDataSource.validateSession();

      dynamic responseData = response.data;
      Map<String, dynamic> mappedData;

      if (responseData is String) {
        mappedData = jsonDecode(responseData) as Map<String, dynamic>;
      } else if (responseData is Map) {
        mappedData = Map<String, dynamic>.from(responseData);
      } else {
        await _localDataSource.setLoggedIn(false);
        return false;
      }

      final bool success = mappedData['success'] == true;
      final userData = mappedData['user'];

      if (success && userData != null) {
        await _localDataSource.setLoggedIn(true);

        final userString = jsonEncode(userData);
        await _localDataSource.setUserData(userString);

        // 🧼 TEMİZLİK: Manuel cookie güncelleyen satır kaldırıldı.
        await _userProvider.loadUserData();

        return true;
      }

      await _localDataSource.setLoggedIn(false);
      return false;
    } catch (e) {
      await _localDataSource.setLoggedIn(false);
      return false;
    }
  }

  @override
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      username: username,
      password: password,
    );
    var userData = response.data['user'];

    final isSuccess = response.statusCode == 200 || response.statusCode == 302;
    await _localDataSource.setLoggedIn(isSuccess);
    if (isSuccess) {
      final userString = jsonEncode(userData);
      await _localDataSource.setUserData(userString);
      // 🧼 TEMİZLİK: Manuel cookie güncelleyen satır kaldırıldı.
      await _userProvider.loadUserData();
    }
    return isSuccess;
  }

  @override
  Future<bool> register({required Map<String, dynamic> payload}) async {
    // 🧼 TEMİZLİK: sessionCookie parametreleri kaldırıldı.
    final response = await _remoteDataSource.register(payload: payload);

    print(response);

    dynamic responseData = response.data;
    Map<String, dynamic> mappedData = {};

    if (responseData is String) {
      mappedData = jsonDecode(responseData) as Map<String, dynamic>;
    } else if (responseData is Map) {
      mappedData = Map<String, dynamic>.from(responseData);
    }

    final isHttpSuccess =
        response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 302;
    final isBackendSuccess = mappedData['success'] == true;

    if (isHttpSuccess && isBackendSuccess) {
      await _localDataSource.setLoggedIn(true);
      var userData = mappedData['user'];
      if (userData != null) {
        final userString = jsonEncode(userData);
        await _localDataSource.setUserData(userString);
      }
      // 🧼 TEMİZLİK: Manuel cookie güncelleyen satır kaldırıldı.
      await _userProvider.loadUserData();
      return true;
    } else {
      await _localDataSource.setLoggedIn(false);

      final serverMessage =
          mappedData['message'] ?? 'Kayıt işlemi gerçekleştirilemedi.';
      throw Exception(serverMessage);
    }
  }

  @override
  Future<bool> getOnboardingCompleted() {
    return _localDataSource.getOnboardingCompleted();
  }

  @override
  Future<void> completeOnboarding() {
    return _localDataSource.setOnboardingCompleted(true);
  }

  @override
  Future<List<LegalDocument>> getLegalDocuments() async {
    try {
      final response = await _remoteDataSource.getLegalDocuments();

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);

        return data.map((json) => LegalDocument.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> logout() async {
    try {
      // 1. Sunucuya logout isteği at (Çerezler henüz duruyorken)
      final response = await _remoteDataSource.logout();
      final isSuccess =
          response.statusCode == 200 || response.statusCode == 302;

      // 2. Local durumu ve session/cookie verilerini temizle
      await _localDataSource.setLoggedIn(false);
      await _localDataSource
          .clearSessionCookie(); // SharedPreferences işlemlerini buraya taşı
      await DioClient().cookieJar.deleteAll();

      return isSuccess;
    } catch (e) {
      // İstek hata alsa bile kullanıcının yerel oturumunu temizleyebilirsin
      await _localDataSource.setLoggedIn(false);
      await _localDataSource.clearSessionCookie();
      await DioClient().cookieJar.deleteAll();
      return false;
    }
  }
}
