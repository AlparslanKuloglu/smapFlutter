import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentmapwebflutter/views/optic_mark_detection_view/optic_mark_detection_view.dart';

@immutable
final class MainInappWebView extends StatefulWidget {
  const MainInappWebView({super.key, this.initialToken});
  // Giriş yapıldıktan sonra gelen token veya kullanıcı bilgisini buradan alabiliriz
  final String? initialToken;

  @override
  State<MainInappWebView> createState() => _MainInappWebViewState();
}

class _MainInappWebViewState extends State<MainInappWebView> {
  final String initialUrl = 'https://www.smaptr.com';
  final GlobalKey webViewKey = GlobalKey();
  CookieManager cookieManager = CookieManager.instance();
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    supportZoom: false,
    iframeAllow: 'camera; microphone',
    iframeAllowFullscreen: true,

    // iOS için cookie paylaşımını aktif et
    // sharedCookiesEnabled: true,
  );

  WebViewEnvironment? webViewEnvironment;

  late final SharedPreferences _prefs;
  String? _sessionCookie;

  // Cookie hazır olana kadar WebView'i gösterme
  bool _cookieReady = false;

  @override
  void initState() {
    super.initState();

    _initializeWebView();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeWebView() async {
    _prefs = await SharedPreferences.getInstance();
    _sessionCookie = _prefs.getString('connect_sid');
    debugPrint("📦 SharedPreferences'dan okunan cookie: $_sessionCookie");

    await _injectSessionCookie();

    // Cookie hazır, artık WebView'i gösterebiliriz
    if (mounted) {
      setState(() {
        _cookieReady = true;
      });
    }
  }

  Future<void> _injectSessionCookie() async {
    try {
      final url = WebUri(initialUrl);

      // Önce mevcut tüm cookie'leri temizle
      await cookieManager.deleteAllCookies();
      debugPrint("🗑️ Mevcut cookie'ler temizlendi");

      if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
        final expiresDate = DateTime.now()
            .add(const Duration(days: 3))
            .millisecondsSinceEpoch;

        debugPrint('🍪 Setlenecek cookie değeri: $_sessionCookie');

        // iOS ve Android için cookie set et
        // Domain başına nokta eklenerek tüm subdomain'ler için geçerli olması sağlanır
        // (www.smaptr.com, smaptr.com, api.smaptr.com vb.)
        await cookieManager.setCookie(
          url: url,
          name: 'connect.sid',
          value: _sessionCookie!,
          expiresDate: expiresDate,
          domain: '.smaptr.com',
          isSecure: true,
          isHttpOnly: true,
          sameSite: HTTPCookieSameSitePolicy.LAX,
        );

        // iOS için ek olarak webViewController üzerinden de cookie inject et
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          debugPrint('🍎 iOS için ek cookie işlemi yapılıyor...');
          // iOS'te cookie'lerin sync olması için küçük bir bekleme
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }

        // Doğrulama için cookie'leri oku
        final Cookie? cookie = await cookieManager.getCookie(
          url: url,
          name: 'connect.sid',
        );
        final cookies = await cookieManager.getCookies(url: url);
        debugPrint('✅ Setlenen cookie: $cookie');
        debugPrint("📋 Tüm cookie'ler: $cookies");
      } else {
        debugPrint('⚠️ Session cookie bulunamadı!');
      }
    } catch (e) {
      debugPrint('❌ Cookie enjeksiyon hatası: $e');
    }
  }

  // JS mesajlarını yönetmek için ayrı bir metod (temiz kod için)
  void _handleJsMessage(String message) {
    debugPrint('Gelen mesaj: $message');

    if (message == 'opticReader') {
      _navigatePreview(context);
    } else if (message == 'logout') {
      // Eğer web içinden çıkış yapılırsa yerel giriş ekranına dön
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _navigatePreview(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const OpticMarkDetectionView2(),
      ),
    );
  }

  // iOS için cookie header'lı URLRequest oluştur
  URLRequest _buildUrlRequest() {
    final url = WebUri(initialUrl);

    // iOS için cookie'yi header'a ekle
    if (defaultTargetPlatform == TargetPlatform.iOS && _sessionCookie != null) {
      return URLRequest(
        url: url,
        headers: {'Cookie': 'connect.sid=$_sessionCookie'},
      );
    }

    return URLRequest(url: url);
  }

  @override
  Widget build(BuildContext context) {
    // BURADAN HEX KODUNU DEĞİŞTİREBİLİRSİNİZ (Örn: 0xFF123456)
    const Color topAreaColor = Color(0xFF162A40);

    // Cookie hazır olana kadar loading göster
    if (!_cookieReady) {
      return const Scaffold(
        backgroundColor: topAreaColor,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      backgroundColor: topAreaColor,
      body: Column(
        children: [
          // Telefonun çentik (status bar) yüksekliği + 40 birim ekstra alan
          Container(
            height: MediaQuery.paddingOf(context).top + 15,
            color: topAreaColor,
          ),
          // WebView'ın geri kalan alanı kaplaması için Expanded kullanıldı
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: _buildUrlRequest(),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller
                  ..addWebMessageListener(
                    WebMessageListener(
                      jsObjectName: 'Toaster',
                      onPostMessage:
                          (message, sourceOrigin, isMainFrame, replyProxy) {
                            _handleJsMessage(message?.data as String);
                          },
                    ),
                  );
              },

              onLoadStart: (controller, url) async {
                debugPrint('🌐 Sayfa yükleniyor: $url');
                if (url.toString().contains('/giris') ||
                    url.toString().contains('/login')) {
                  await Navigator.of(context).pushReplacementNamed('/login');
                  return;
                }
              },

              onLoadStop: (controller, url) async {
                debugPrint('✅ Sayfa yüklendi: $url');

                if (url.toString().contains('/giris') ||
                    url.toString().contains('/login')) {
                  await Navigator.of(context).pushReplacementNamed('/login');
                  return;
                }

                // Yükleme sonrası cookie durumunu kontrol et
                final cookies = await cookieManager.getCookies(
                  url: WebUri(initialUrl),
                );
                debugPrint("🍪 Yükleme sonrası cookie'ler: $cookies");
              },
              onReceivedError: (controller, request, error) {
                debugPrint(
                  '❌ WebView hatası: ${error.type} - ${error.description}',
                );
              },
              onProgressChanged: (controller, progress) {},
              onUpdateVisitedHistory: (controller, url, androidIsReload) {},
              onConsoleMessage: (controller, consoleMessage) {
                if (kDebugMode) {
                  print(consoleMessage);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
