import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/home/presentation/provider/home_provider.dart';

class AddStudentDialog extends StatefulWidget {
  final dynamic
  repository; // Kendi repository veya service yapınızı bağlayabilirsiniz
  const AddStudentDialog({super.key, required this.repository});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controller Yapıları
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Durum Yönetimleri
  String? _selectedClass; // 9, 10, 11, 12
  String? _selectedBranch; // Sayısal, Eşit Ağırlık, Sözel, Dil
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Kullanıcı Adı Kontrol Durumları
  bool _checkUserLoading = false;
  bool?
  _isUsernameAvailable; // null: kontrol edilmedi, true: müsait, false: alınmış

  // Tasarımdaki Avatar Seçici İçin Örnek Liste
  final List<String> _avatars = AppColors.studentAvatars;
  int _currentAvatarIndex = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Kullanıcı Adı Kontrol Fonksiyonu
  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      return;
    }

    setState(() {
      _checkUserLoading = true;
      _isUsernameAvailable = null; // Eski durumu sıfırla
    });

    try {
      final response = await widget.repository.checkUsername(username);
      final bool isAvailable = response['available'] ?? false;

      // Test amaçlı şimdilik direkt true/false parametresi simüle edilebilir:
      bool isAvailableSimulated = isAvailable;

      setState(() {
        _isUsernameAvailable = isAvailableSimulated;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kontrol sırasında hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checkUserLoading = false);
      }
    }
  }

  // Otomatik Karmaşık Şifre Oluşturma Fonksiyonu
  void _generateRandomPassword() {
    const String chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#\$%';
    final Random random = Random();

    final String generated = List.generate(
      10,
      (index) => chars[random.nextInt(chars.length)],
    ).join();

    setState(() {
      _passwordController.text = generated;
    });
  }

  final Map<String, int> branchToId = {
    'Sayısal': 1,
    'Eşit Ağırlık': 2,
    'Sözel': 3,
    'Dil': 4,
  };

  // Öğrenci Ekleme İstek Fonksiyonu
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final int? aimTypeId = _selectedBranch != null
        ? branchToId[_selectedBranch]
        : null;
    final String rawPath = _avatars[_currentAvatarIndex];
    final String cleanPhotoPath = Uri.parse(
      rawPath,
    ).pathSegments.last; // photo.png
    final Map<String, dynamic> payload = {
      "dataObj": {
        "name": _firstNameController.text.trim(),
        "surname": _lastNameController.text.trim(),
        "userName": _usernameController.text.trim(),
        "password": _passwordController.text,
        "seasonType": int.tryParse(_selectedClass ?? '') ?? 9,
        "aimType": aimTypeId,
        "photo": cleanPhotoPath,
      },
    };

    try {
      final response = await widget.repository.addStudent(payload);
      if (response['student'] != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Öğrenci başarıyla eklendi! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(response['student']);
        }
      } else if (response['userNameUsing'] == true) {
        setState(() {
          _isUsernameAvailable = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hata: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Tasarımdaki İnce Gri Border'lı Input Dekorasyonu (Kontrol durumuna göre border rengi değişir)
  InputDecoration _buildInputDecoration({
    required String hintText,
    Widget? suffixIcon,
    bool? isUsernameField,
  }) {
    // Kullanıcı adı alanına özel dinamik border rengi belirleme
    Color enabledBorderColor = Colors.grey.shade200;
    Color focusedBorderColor = AppColors.primaryOrange;

    if (isUsernameField == true && _isUsernameAvailable != null) {
      enabledBorderColor = _isUsernameAvailable!
          ? Colors.green.shade400
          : Colors.red.shade400;
      focusedBorderColor = _isUsernameAvailable! ? Colors.green : Colors.red;
    }

    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isUsernameField == true && _isUsernameAvailable != null
              ? enabledBorderColor
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: enabledBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusedBorderColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bool showBranchField =
        _selectedClass != null && (int.tryParse(_selectedClass!) ?? 0) > 10;

    return AnimatedPadding(
      padding:
          mediaQuery.viewInsets +
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Center(
        child: Material(
          color: AppColors.white,
          elevation: 24,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          type: MaterialType.card,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: mediaQuery.size.height * 0.9,
              maxWidth: 420,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BAŞLIK ALANI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Öğrenci Ekle',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Colors.black54,
                            ),
                            onPressed: () => Navigator.pop(context),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // AVATAR SEÇİCİ
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.grey.shade400,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentAvatarIndex =
                                      (_currentAvatarIndex -
                                          1 +
                                          _avatars.length) %
                                      _avatars.length;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade50,
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Image.asset(
                                  _avatars[_currentAvatarIndex],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.shade400,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentAvatarIndex =
                                      (_currentAvatarIndex + 1) %
                                      _avatars.length;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // AD VE SOYAD INPUTLARI
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel('Öğrenci Adı'),
                                TextFormField(
                                  controller: _firstNameController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Ad',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Ad alanı boş bırakılamaz'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputLabel('Öğrenci Soyadı'),
                                TextFormField(
                                  controller: _lastNameController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Soyad',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Soyad alanı boş bırakılamaz'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // KULLANICI ADI INPUTU VE KONTROL ET BUTONU
                      _buildInputLabel('Kullanıcı Adı'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _usernameController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: _buildInputDecoration(
                                    hintText: 'Kullanıcı Adı',
                                    isUsernameField: true,
                                  ),
                                  onChanged: (val) {
                                    // Kullanıcı metni değiştirdiğinde eski kontrol durumunu sıfırla
                                    if (_isUsernameAvailable != null) {
                                      setState(
                                        () => _isUsernameAvailable = null,
                                      );
                                    }
                                  },
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Kullanıcı adı alanı boş bırakılamaz'
                                      : null,
                                ),
                                // Duruma göre alt bilgilendirme metni
                                if (_isUsernameAvailable != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      left: 4,
                                    ),
                                    child: Text(
                                      _isUsernameAvailable!
                                          ? '✓ Kullanıcı adı müsait'
                                          : '✕ Bu kullanıcı adı zaten alınmış',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: _isUsernameAvailable!
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _checkUserLoading
                                  ? null
                                  : _checkUsername,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333E50),
                                foregroundColor: AppColors.white,
                                disabledBackgroundColor: Colors.grey.shade400,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _checkUserLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Kontrol Et',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),

                      // ŞİFRE VE OTOMATİK OLUŞTUR BUTONU
                      _buildInputLabel('Şifre'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: false,
                              style: const TextStyle(fontSize: 14),
                              decoration: _buildInputDecoration(
                                hintText: 'Şifre',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    size: 18,
                                    color: Colors.black45,
                                  ),
                                  onPressed: () => setState(
                                    () => _isPasswordVisible =
                                        !_isPasswordVisible,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  (value == null || value.isEmpty)
                                  ? 'Şifre alanı boş bırakılamaz'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _generateRandomPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333E50),
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Oluştur',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // SINIF SEÇİM ALANI
                      _buildInputLabel('Sınıf'),
                      DropdownButtonFormField<String>(
                        value: _selectedClass,
                        dropdownColor: AppColors.white,
                        decoration: _buildInputDecoration(
                          hintText: 'Sınıf Seçiniz',
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black45,
                        ),
                        items: ['9', '10', '11', '12'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              '$value. Sınıf',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedClass = newValue;
                            if (newValue != null &&
                                (int.tryParse(newValue) ?? 0) <= 10) {
                              _selectedBranch = null;
                            }
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Lütfen bir sınıf seçin' : null,
                      ),

                      // DİNAMİK ALAN SEÇİMİ
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return SizeTransition(
                                sizeFactor: animation,
                                child: child,
                              );
                            },
                        child: showBranchField
                            ? Column(
                                key: const ValueKey('branchFieldKey'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel('Alan Seçimi'),
                                  DropdownButtonFormField<String>(
                                    value: _selectedBranch,
                                    dropdownColor: AppColors.white,
                                    decoration: _buildInputDecoration(
                                      hintText: 'Alan Seçiniz',
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.black45,
                                    ),
                                    items:
                                        [
                                          'Sayısal',
                                          'Eşit Ağırlık',
                                          'Sözel',
                                          'Dil',
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (newValue) {
                                      setState(
                                        () => _selectedBranch = newValue,
                                      );
                                    },
                                    validator: (value) =>
                                        (showBranchField && value == null)
                                        ? 'Lütfen bir alan seçin'
                                        : null,
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),

                      // KAYDET BUTONU
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryOrange,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Öğrenciyi Kaydet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // EN ALT BİLGİLENDİRME KUTUSU
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2EC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFFDCD0),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bilgilendirme',
                              style: TextStyle(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Yeni oluşturulan öğrenci sistemi kullanarak kendi paneline giriş yapabilir ve ödevlerini/sınavlarını takip edebilir.',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
