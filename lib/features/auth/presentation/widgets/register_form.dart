import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studentmap/features/auth/presentation/widgets/auth_enums.dart';
import 'package:studentmap/features/auth/presentation/widgets/role_toggle_button.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/features/auth/presentation/provider/register_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_html/flutter_html.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  static const Color _darkBlue = Color(0xFF0D2744);
  static const Color _inputFill = Color(0xFFE8F1FA);

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController(text: "");
  final _usernameController = TextEditingController(text: "");
  final _emailController = TextEditingController(text: "");
  final _passwordController = TextEditingController(text: "");
  final _confirmPasswordController = TextEditingController(text: "");
  final _coachCodeController = TextEditingController();

  RegisterRole _role = RegisterRole.student;
  String? _selectedClass;
  String? _selectedField;
  String? _classError;
  String? _fieldError;

  // Avatar Yönetimi (Ok butonları ile geçiş için index)
  int _currentAvatarIndex = 0;

  final List<String> _avatars = AppColors.studentAvatars;

  // Kullanıcı Adı Kontrol Durumları ve Debounce Timer
  Timer? _debounceTimer;
  bool _isUsernameChecking = false;
  bool? _isUsernameAvailable;
  String? _usernameError;

  // Şifre Görünürlük Durumları
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  static const _classOptions = ['9', '10', '11', '12', 'Mezun'];
  static const _fieldOptions = ['Sayısal', 'Eşit Ağırlık', 'Sözel'];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _coachCodeController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _inputFill,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      );

  // Kullanıcı Adı Kontrol Fonksiyonu (Debounce ile tetiklenir)
  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _usernameError = 'Lütfen önce bir kullanıcı adı yazın');
      return;
    }

    setState(() {
      _isUsernameChecking = true;
      _isUsernameAvailable = null;
      _usernameError = null;
    });

    try {
      // TODO: Backend/Repository entegrasyonu buraya gelecek
      // final available = await ref.read(authRepositoryProvider).checkUsername(username);
      await Future.delayed(const Duration(milliseconds: 600)); // Simülasyon
      final available = username.toLowerCase() != 'admin';

      setState(() {
        _isUsernameAvailable = available;
        _usernameError = available ? null : 'Bu kullanıcı adı zaten kullanımda';
      });
    } catch (_) {
      setState(() {
        _isUsernameAvailable = false;
        _usernameError = 'Kontrol edilirken bir hata oluştu';
      });
    } finally {
      setState(() => _isUsernameChecking = false);
    }
  }

  // Sınıf seçimine göre Alan bilgisinin görünüp görünmeyeceğini belirleyen lojik
  // 9 ve 10. sınıflarda alan seçimi (Sayısal/EA/Sözel) olmadığı için gizlenir.
  bool get _shouldShowField {
    if (_role != RegisterRole.student) return false;
    if (_selectedClass == null) return false;
    return _selectedClass == '11' ||
        _selectedClass == '12' ||
        _selectedClass == 'Mezun';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // 1. Öğrenciye özel validasyonlar
    if (_role == RegisterRole.student) {
      setState(() {
        _classError = _selectedClass == null ? 'Lütfen sınıfınızı seçin' : null;
        _fieldError = _shouldShowField && _selectedField == null
            ? 'Lütfen alanınızı seçin'
            : null;
      });
      if (_classError != null || _fieldError != null) return;
    }

    // 2. Kullanıcı adı onay kontrolü
    if (_isUsernameAvailable == false) {
      setState(
        () => _usernameError = 'Lütfen geçerli bir kullanıcı adı seçiniz',
      );
      return;
    }

    // --- PAYLOAD OLUŞTURMA ADIMI ---

    // 'Mezun' seçildiyse seasonType için özel bir int (örn: 13) veya varsayılan 0 atayabilirsin.
    // Dropdown'dan '9', '10' gibi değerler gelirse int.tryParse doğrudan çevirir.
    final int seasonType = _role == RegisterRole.student
        ? (_selectedClass == 'Mezun'
              ? 13
              : (int.tryParse(_selectedClass ?? '') ?? 9))
        : 0; // Koç ise varsayılan bir değer veya null (backend beklentisine göre)

    // Alan (Field) seçimine göre aimTypeId belirleme (Sayısal=1, EA=2, Sözel=3 gibi)
    // Eğer öğrenci 9-10. sınıftaysa veya rol koç ise aimType'ı null ya da 0 gönderebilirsin.
    int? aimTypeId;
    if (_role == RegisterRole.student && _shouldShowField) {
      switch (_selectedField) {
        case 'Sayısal':
          aimTypeId = 3;
          break;
        case 'Eşit Ağırlık':
          aimTypeId = 2;
          break;
        case 'Sözel':
          aimTypeId = 4;
          break;
      }
    }

    // Asset path'inden sadece dosya adını ayıklamak için (örn: "assets/avatars/avatar1.png" -> "avatar1.png")
    final String fullPhotoPath = _avatars[_currentAvatarIndex];
    final String cleanPhotoPath = fullPhotoPath.split('/').last;

    final String fullName = _fullNameController.text.trim();
    final List<String> nameParts = fullName.split(' ');
    final String surname = nameParts.length > 1 ? nameParts.last : '';
    final String firstName = nameParts.length > 1
        ? nameParts.sublist(0, nameParts.length - 1).join(' ')
        : fullName;

    final int userType = _role == RegisterRole.student ? 1 : 2;

    final Map<String, dynamic> dataObj = {
      "name": fullName, // Adın tam hali (Full Name)
      "firstName": firstName, // Sadece adı
      "surname": surname, // Soyadı
      "userName": _usernameController.text.trim(),
      "email": _emailController.text.trim(),
      "password": _passwordController.text,
      "password2": _confirmPasswordController.text,
      "seasonType": seasonType,
      "aimType": aimTypeId,
      "photo": cleanPhotoPath,
    };

    final Map<String, dynamic> finalPayload = {
      "userType": userType,
      "userJson":
          dataObj, // Backend 'jsonum' ismini bekliyorsa bu şekilde map'liyoruz
    };

    // Çağrıyı gerçekleştiriyoruz
    context.read<RegisterNotifier>().register(payload: finalPayload);
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ),
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Html(
              data: content,
              style: {
                "body": Style(
                  fontSize: FontSize(14.0),
                  lineHeight: LineHeight(1.5),
                  color: Colors.black87,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "h1": Style(fontSize: FontSize(18.0)),
                "h2": Style(fontSize: FontSize(16.0)),
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.appBarBackground,
            ),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Üst Başlık
          SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _darkBlue,
                      size: 22,
                    ),
                    onPressed: widget.onBackPressed,
                  ),
                ),
                const Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
              ],
            ),
          ),
          //const SizedBox(height: 16),
          Row(
            children: [
              /*

              Expanded(
                child: RoleToggleButton(
                  label: 'Öğrenci',
                  selected: _role == RegisterRole.student,
                  onTap: () => setState(() => _role = RegisterRole.student),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RoleToggleButton(
                  label: 'Öğrenci Koçu',
                  selected: _role == RegisterRole.coach,
                  onTap: () => setState(() => _role = RegisterRole.coach),
                ),
              ),
              */
            ],
          ),
          // Ok Butonlu Avatar Seçim Alanı
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: _darkBlue,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _currentAvatarIndex =
                        (_currentAvatarIndex - 1 + _avatars.length) %
                        _avatars.length;
                  });
                },
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 45,
                backgroundColor: _inputFill,
                backgroundImage: AssetImage(_avatars[_currentAvatarIndex]),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _darkBlue,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _currentAvatarIndex =
                        (_currentAvatarIndex + 1) % _avatars.length;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Ad Soyad
          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('Ad Soyad *'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Ad soyad gerekli' : null,
          ),
          const SizedBox(height: 14),

          // Kullanıcı Adı Yapısı (Debounce Kontrollü)
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            onChanged: (text) {
              setState(() {
                _isUsernameAvailable = null;
                _usernameError = null;
                _isUsernameChecking = text.trim().isNotEmpty;
              });

              _debounceTimer?.cancel();
              if (text.trim().isNotEmpty) {
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  _checkUsername();
                });
              }
            },
            decoration: _inputDecoration(
              'Kullanıcı adı *',
              suffixIcon: _isUsernameChecking
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _darkBlue,
                        ),
                      ),
                    )
                  : _isUsernameAvailable == null
                  ? null
                  : _isUsernameAvailable!
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                  : const Icon(Icons.error_rounded, color: Colors.red),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Kullanıcı adı gerekli' : null,
          ),
          if (_usernameError != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                _usernameError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // E-posta
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration('E-posta *'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
              if (!v.contains('@')) return 'Geçerli bir e-posta girin';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Şifre
          TextFormField(
            controller: _passwordController,
            obscureText: _isPasswordObscured,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              'Şifre *',
              suffixIcon: IconButton(
                focusNode: FocusNode(
                  skipTraversal: true,
                ), // EKLENDİ: Klavyenin buraya takılmasını engeller
                icon: Icon(
                  _isPasswordObscured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: _darkBlue.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Şifre gerekli' : null,
          ),
          const SizedBox(height: 14),

          // Şifre Yeniden
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _isConfirmPasswordObscured,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              'Şifre yeniden *',
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordObscured
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: _darkBlue.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  });
                },
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Şifre tekrarı gerekli';
              if (v != _passwordController.text) return 'Şifreler eşleşmiyor';
              return null;
            },
          ),

          // Öğrenci Alanları (Dinamik Sınıf ve Koşullu Alan Seçimi)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _role == RegisterRole.student
                ? Column(
                    key: const ValueKey('student_section'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) => DropdownMenu<String>(
                          width: constraints.maxWidth,
                          initialSelection: _selectedClass,
                          hintText: 'Sınıfınız',
                          menuHeight: 240,
                          textStyle: const TextStyle(color: _darkBlue),
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          alignmentOffset: const Offset(0, 8),
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: _inputFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                          dropdownMenuEntries: _classOptions
                              .map(
                                (v) => DropdownMenuEntry<String>(
                                  value: v,
                                  label: v == 'Mezun' ? 'Mezun' : '$v. Sınıf',
                                ),
                              )
                              .toList(),
                          onSelected: (v) => setState(() {
                            _selectedClass = v;
                            _classError = null;
                            _selectedField = null;
                          }),
                        ),
                      ),
                      if (_classError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _classError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      // KOŞULLU ALAN: Sadece 11, 12 ve Mezun seçildiğinde görünür hale gelir
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _shouldShowField
                            ? Column(
                                key: const ValueKey('field_dropdown_active'),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 14),
                                  LayoutBuilder(
                                    builder: (context, constraints) =>
                                        DropdownMenu<String>(
                                          width: constraints.maxWidth,
                                          initialSelection: _selectedField,
                                          hintText: 'Alanınız',
                                          menuHeight: 220,
                                          textStyle: const TextStyle(
                                            color: _darkBlue,
                                          ),
                                          menuStyle: MenuStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                  Colors.white,
                                                ),
                                            shape: WidgetStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                          alignmentOffset: const Offset(0, 8),
                                          inputDecorationTheme:
                                              InputDecorationTheme(
                                                filled: true,
                                                fillColor: _inputFill,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 15,
                                                    ),
                                              ),
                                          dropdownMenuEntries: _fieldOptions
                                              .map(
                                                (v) =>
                                                    DropdownMenuEntry<String>(
                                                      value: v,
                                                      label: v,
                                                    ),
                                              )
                                              .toList(),
                                          onSelected: (v) => setState(() {
                                            _selectedField = v;
                                            _fieldError = null;
                                          }),
                                        ),
                                  ),
                                  if (_fieldError != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      _fieldError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('field_dropdown_hidden'),
                              ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(key: ValueKey('coach_section')),
          ),

          const SizedBox(height: 8),

          // Yasal Metinler ve Bilgilendirme
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                // 1. Cümle: Kullanım Koşulları
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: 'Kayıt olarak '),
                      TextSpan(
                        text: 'Kullanım Koşulları',
                        style: const TextStyle(
                          color: _darkBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final doc = context
                                .read<RegisterNotifier>()
                                .getDocumentByName('kullanim_kosullari');

                            _showLegalDialog(
                              context,
                              doc?.title ?? 'Kullanım Koşulları',
                              doc?.content ??
                                  'Sözleşme metni yüklenemedi veya bulunamadı.',
                            );
                          },
                      ),
                      const TextSpan(text: '\'nı kabul etmiş olursunuz.'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // 2. Cümle: KVKK ve Gizlilik Politikası
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'KVKK Aydınlatma Metni',
                        style: const TextStyle(
                          color: _darkBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final doc = context
                                .read<RegisterNotifier>()
                                .getDocumentByName('kvkk_aydinlatma_metni');

                            _showLegalDialog(
                              context,
                              doc?.title ?? 'KVKK Aydınlatma Metni',
                              doc?.content ??
                                  'Sözleşme metni yüklenemedi veya bulunamadı.',
                            );
                          },
                      ),
                      const TextSpan(text: ' ve '),
                      TextSpan(
                        text: 'Gizlilik Politikası',
                        style: const TextStyle(
                          color: _darkBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            final doc = context
                                .read<RegisterNotifier>()
                                .getDocumentByName('gizlilik_politikasi');

                            _showLegalDialog(
                              context,
                              doc?.title ?? 'Gizlilik Politikası',
                              doc?.content ??
                                  'Sözleşme metni yüklenemedi veya bulunamadı.',
                            );
                          },
                      ),
                      const TextSpan(text: '\'nı inceleyebilirsiniz.'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Kayıt Tamamla Butonu
          Consumer<RegisterNotifier>(
            builder: (context, notifier, child) {
              // Sadece registerState'i dinliyoruz, tüm form etkilenmiyor
              final state = notifier.state;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. EĞER HATA VARSA: Butonun hemen üzerinde kırmızı yazı belirir
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50, // Hafif kırmızı arka plan
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ), // Hata yazısı ile buton arasındaki boşluk
                  ],

                  // 2. BUTON ALANI
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _darkBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      // Eğer yükleniyorsa (isLoading) butona basılmasını engelle (null yap)
                      onPressed: state.isLoading ? null : _submit,
                      child: state.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Tamamla',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
