import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

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

  /// 🚀 ASENKRON BAŞLATICI: Uygulama açılırken main.dart içinden çağrılacak.
  /// Çerezlerin telefona kalıcı olarak yazılacağı klasörü hazırlar ve interceptor'ı bağlar.
  Future<void> init() async {
    if (_isInitialized) return;

    // Telefon hafızasında çerezler için güvenli bir klasör yolu alıyoruz
    final appDocDir = await getApplicationDocumentsDirectory();
    final String cookiePath = '${appDocDir.path}/.cookies/';

    // Kapanıp açıldığında silinmeyen kalıcı çerez kavanozu oluşturuyoruz
    cookieJar = PersistCookieJar(
      storage: FileStorage(cookiePath),
      ignoreExpires:
          false, // Süresi dolan çerezleri backend kurallarına göre siler
    );

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
