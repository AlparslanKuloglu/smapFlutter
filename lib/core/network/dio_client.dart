import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/dependency_injection/injection_container.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  late final PersistCookieJar cookieJar;
  bool _isInitialized = false;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://www.smaptr.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }

  /// Başlatıcı: `configureDependencies()` bittikten sonra, uygulama açılırken
  /// çağrılır (`MainInitializer`).
  ///
  /// Kendi çerez kavanozunu kurmaz: `NetworkService`'in kavanozunu paylaşır
  /// (`<documents>/.cookies/`, `PersistCookieJar`). Böylece eski ve yeni ağ
  /// yığını aynı oturum çerezini görür ve çıkışta (`SessionManager`) ikisi
  /// birden temizlenir.
  Future<void> init() async {
    if (_isInitialized) return;

    cookieJar = locator<NetworkService>().cookieJar as PersistCookieJar;

    // Dio'ya otomatik çerez yöneticisini ekliyoruz
    dio.interceptors.add(CookieManager(cookieJar));

    _isInitialized = true;
    /*
    print(
      "[DioClient]: Otomatik Çerez Yönetim Sistemi Başarıyla Ayağa Kaldırıldı!",
    );
    */
  }
}
