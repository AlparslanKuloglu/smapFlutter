// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:studentmapwebflutter/views/optic_mark_detection_view/optic_mark_detection_view.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// @immutable
// final class MainWebView extends StatefulWidget {
//   const MainWebView({super.key, this.initialToken});
//   // Giriş yapıldıktan sonra gelen token veya kullanıcı bilgisini buradan alabiliriz
//   final String? initialToken;

//   @override
//   State<MainWebView> createState() => _MainWebViewState();
// }

// class _MainWebViewState extends State<MainWebView> {
//   late final WebViewController _controller;
//   late final WebViewCookieManager _cookieManager;
//   late final SharedPreferences _prefs;
//   String? _sessionCookie;
//   bool _needsJsInit = false;
//   final bool _jsInitDone = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//   }

//   Future<void> _initializeWebView() async {
//     _prefs = await SharedPreferences.getInstance();
//     _sessionCookie = _prefs.getString('connect_sid');

//     // Cookie storage daha önce JavaScript ile initialize edilmiş mi?
//     final cookieStorageInitialized = _prefs.getBool('cookie_storage_initialized') ?? false;
//     _needsJsInit = !cookieStorageInitialized;

//     debugPrint('🔧 Cookie storage initialized: $cookieStorageInitialized');

//     _controller = WebViewController();
//     _cookieManager = WebViewCookieManager();

//     _controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(Colors.white)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageFinished: (String url) async {
//             debugPrint('📄 Sayfa yüklendi: $url');

//             // // İlk seferse JavaScript ile cookie set et ve reload yap
//             // if (_needsJsInit &&
//             //     !_jsInitDone &&
//             //     url.contains('studentmap.com.tr') &&
//             //     _sessionCookie != null &&
//             //     _sessionCookie!.isNotEmpty) {
//             //   _jsInitDone = true;
//             //   debugPrint('🍪 İlk sefer: JavaScript ile cookie enjekte ediliyor...');

//             // JavaScript ile cookie set et (cookie storage'ı aktif etmek için)
//             // await _controller.runJavaScript('''
//             //     document.cookie = "connect.sid=$_sessionCookie; path=/; domain=.studentmap.com.tr;";
//             //   ''');

//             final cookies = await _controller.runJavaScriptReturningResult(
//               'document.cookie',
//             );
//             print('cookies: $cookies');

//             //   // // WebViewCookieManager ile de set et
//             //   // await _injectSessionCookie();

//             //   // Flag'i kaydet - bir dahaki seferde JS gerekmeyecek
//             //   await _prefs.setBool('cookie_storage_initialized', true);

//             //   // Sayfayı yenile
//             //   await Future<void>.delayed(const Duration(milliseconds: 100));
//             //   debugPrint('🔄 Sayfa yenileniyor...');
//             //   await _controller.reload();
//             // }
//           },
//         ),
//       )
//       ..addJavaScriptChannel(
//         'Toaster',
//         onMessageReceived: (JavaScriptMessage message) {
//           _handleJsMessage(message.message);
//         },
//       );

//     // Eğer daha önce JS ile initialize edilmişse, sadece WebViewCookieManager kullan
//     // if (!_needsJsInit) {
//     //   debugPrint('✨ Cookie storage zaten initialize edilmiş, WebViewCookieManager kullanılıyor');
//     await _injectSessionCookie();
//     // }

//     // URL'i yükle
//     await _controller.loadRequest(Uri.parse('https://www.smaptr.com'));
//   }

//   Future<void> _injectSessionCookie() async {
//     try {
//       if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
//         final cookie = WebViewCookie(
//           name: 'connect.sid',
//           value: _sessionCookie!,
//           domain: 'https://www.smaptr.com',
//         );

//         final cookie2 = WebViewCookie(
//           name: 'connect.sid',
//           value: _sessionCookie!,
//           domain: 'studentmap.com.tr',
//         );

//         await _cookieManager.setCookie(cookie);
//         // await _cookieManager.setCookie(cookie2);

//         print('cookie.domain: ${cookie.domain}');
//         print('cookie2.domain: ${cookie2.domain}');
//         print('cookie.name: ${cookie.name}');
//         print('cookie2.name: ${cookie2.name}');
//         print('cookie.path: ${cookie.path}');
//         print('cookie2.path: ${cookie2.path}');
//         print('cookie.value: ${cookie.value}');
//         print('cookie2.value: ${cookie2.value}');

//         debugPrint('✅ WebViewCookieManager ile cookie enjekte edildi');
//       }
//     } catch (e) {
//       debugPrint('❌ Cookie enjeksiyon hatası: $e');
//     }
//   }

//   // JS mesajlarını yönetmek için ayrı bir metod (temiz kod için)
//   void _handleJsMessage(String message) {
//     debugPrint('Gelen mesaj: $message');

//     if (message == 'opticReader') {
//       _navigatePreview(context);
//     } else if (message == 'logout') {
//       // Eğer web içinden çıkış yapılırsa yerel giriş ekranına dön
//       Navigator.of(context).pushReplacementNamed('/login');
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message)),
//       );
//     }
//   }

//   Future<void> _navigatePreview(BuildContext context) async {
//     await Navigator.of(context).push(
//       MaterialPageRoute<void>(
//         builder: (context) => const OpticMarkDetectionView2(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // SafeArea kullanarak status bar çakışmalarını önlüyoruz
//       body: SafeArea(
//         child: WebViewWidget(controller: _controller),
//       ),
//     );
//   }
// }
