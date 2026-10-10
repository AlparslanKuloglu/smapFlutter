/*
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // json.encode için gerekli

// --------------------------------------------------------------------------
// 1. LOGIN VIEW (Giriş Ekranı)
// --------------------------------------------------------------------------
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'student');
  final _passwordController = TextEditingController(text: 'smap2025');

  bool _isLoading = false;
  bool _rememberMe = false;

  // AYARLAR
  final String loginUrl = 'https://www.smaptr.com/student/login';

  Future<void> _loginAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      // Session cookie'sini al
      final prefs = await SharedPreferences.getInstance();

      // HTTP isteği ile login yap
      final dio = Dio();

      // Login isteği
      // 1. Response tipini dynamic veya Map yapalım ki veriye erişebilelim
      final response = await dio.post(
        loginUrl,
        data: {'username': username, 'password': password},
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      // Cookie işlemleri aynı kalıyor
      final setCookieHeader = response.headers.value('set-cookie');

      // Başarılı login kontrolü (200 veya 302 redirect)
      if (response.statusCode == 200 || response.statusCode == 302) {
        // Login başarılı flag'ini kaydet
        await prefs.setBool('isLoggedIn', true);
        _onLoginSuccess();
      } else {
        _showError('Kullanıcı adı veya şifre hatalı');
      }
    } catch (e) {
      debugPrint('Login hatası: $e');
      _showError('Giriş işlemi hatası: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onLoginSuccess() {
    debugPrint('BAŞARILI: Ana sayfaya yönlendiriliyorsunuz.');
    if (mounted) {
      // '/home' rotanızın tanımlı olduğundan emin olun
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş Başarılı! Yönlendiriliyor...')),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // Tasarımdaki Renkler
    const Color darkBlue = Color(0xFF0D2744);
    const Color inputFillColor = Color(0xFFE8F1FA); // Açık mavi kutular

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // Genel arka plan
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // --- LOGO ve BAŞLIK KISMI ---
                Image.asset(
                  'assets/smapLogo.png',
                  height: 50,
                ), // Görseldeki ikon seti
                const SizedBox(height: 15),
                const Text(
                  "SMAP'e hoş geldin!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Öğrenme yolculuğunuza başlamaya hazır mısınız?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 20),

                // --- İLLÜSTRASYON (Resim) ---
                // Kendi asset'inizi buraya koyabilirsiniz: Image.asset("assets/login_img.png")
                Image.asset(
                  'assets/loginImage.png',
                  height: 180,
                ), // Görseldeki ikon seti

                const SizedBox(height: 30),

                // --- FORM ALANI ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kullanıcı Girişi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // KULLANICI ADI
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'student',
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        // validator: (v) => v!.isEmpty ? 'Kullanıcı adı gerekli' : null,
                      ),
                      const SizedBox(height: 15),
                      // ŞİFRE
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          filled: true,
                          fillColor: inputFillColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        // validator: (v) => v!.isEmpty ? 'Şifre gerekli' : null,
                      ),
                    ],
                  ),
                ),

                // --- BENİ HATIRLA & ŞİFREMİ UNUTTUM ---
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: darkBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              setState(() => _rememberMe = val ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Beni Hatırla',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // Şifremi unuttum işlemi
                      },
                      child: const Text(
                        'Şifremi unuttum',
                        style: TextStyle(color: darkBlue, fontSize: 13),
                      ),
                    ),
                  ],
                ),

                // --- SOSYAL MEDYA GİRİŞ (Opsiyonel) ---
                const SizedBox(height: 20),
                Text(
                  'veya hesabınızla bağlanın',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(Icons.apple, Colors.black),
                    const SizedBox(width: 20),
                    // Google ikonu yerine renkli ikon kullanmak daha iyi olur ama standart Icon kullanıyorum
                    _socialButton(Icons.g_mobiledata, Colors.red, iconSize: 35),
                  ],
                ),

                const SizedBox(height: 25),

                // --- GİRİŞ YAP BUTONU ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isLoading ? null : _loginAction,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Giriş Yap',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // --- KAYIT OL LİNKİ ---
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hesabın yok mu? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const RegisterView(),
                          ),
                        );
                      },
                      child: const Text(
                        'Kayıt ol',
                        style: TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color, {double iconSize = 30}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: color),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 2. REGISTER VIEW (Yeni Eklenen Kayıt Ekranı)
// --------------------------------------------------------------------------
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0D2744);
    const Color inputFillColor = Color(0xFFE8F1FA);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kayıt Ol',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Yeni bir hesap oluşturarak aramıza katıl.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Form Alanları (Görsel temsil)
              _buildRegisterInput('Ad Soyad', inputFillColor),
              const SizedBox(height: 15),
              _buildRegisterInput('E-posta', inputFillColor),
              const SizedBox(height: 15),
              _buildRegisterInput('Şifre', inputFillColor, obscure: true),
              const SizedBox(height: 15),
              _buildRegisterInput(
                'Şifre Tekrar',
                inputFillColor,
                obscure: true,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // Kayıt olma mantığı buraya
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kayıt işlemi başlatıldı...'),
                      ),
                    );
                  },
                  child: const Text(
                    'Hesap Oluştur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterInput(
    String hint,
    Color fillColor, {
    bool obscure = false,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

*/
