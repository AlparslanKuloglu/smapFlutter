import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/profile/presentation/screens/account_settings/widgets/account_settings_navy_header.dart';
import 'package:studentmap/features/profile/presentation/screens/account_settings/widgets/account_settings_password_field.dart';
import 'package:studentmap/features/profile/presentation/screens/account_settings/widgets/account_settings_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:studentmap/repository/profile_repository.dart';
import 'package:studentmap/features/auth/data/datasources/auth_remote_data_source.dart';

class AccountSettingsScreen extends StatefulWidget {
  final ProfileRepository profileRepository;

  const AccountSettingsScreen({super.key, required this.profileRepository});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // --- HESAP BİLGİLERİ ---
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _coachingCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _cityController;
  late final TextEditingController _descController;

  bool _isEditingProfile = false;
  final Map<String, String> _profileBackup = {};

  String?
  _userAssetImage; // Header'a yollayacağımız asset yolu burada tutulacak

  // --- KOÇLUK KODU EKSTRA MANTIKLAR ---
  bool _isLoadingCoach = false; // API isteği başladı mı/bitti mi takibi için
  bool _hasCoach = false; // Profilde koç var mı yok mu kontrolü
  bool _isChangingCoach = false; // Koç değiştirme (kod yazma) modunda mı?
  String _coachName = ""; // Mock koç ismi
  String _coachImageUrl = ""; // Mock koç resmi
  String coachCode = "-";
  String studentDesc =
      'Koçluk kodu, kurumunuzdaki danışmanınız veya koçunuz tarafından size verilen özel bir koddur. '
      'Bu kodu buraya girerek koçunuzla profilinizi eşleştirebilir, program takibinizi ve '
      'gelişiminizi koçunuzun doğrudan görmesini sağlayabilirsiniz.';
  String coachDesc =
      'Koçluk kodunuz, öğrencilerinizin profillerini sizin hesabınızla eşleştirmek için kullandıkları koddur.'
      'Öğrencilerinizin bu kodu Hesap Ayarları kısmında ilgili yere girmeleri gerekmektedir.';

  // --- ŞİFRE VE GÜVENLİK ---
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _newPasswordRepeatController;

  bool _isEditingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureNewRepeat = true;

  @override
  void initState() {
    super.initState();
    // Hesap Bilgileri İlk Değerleri
    _nameController = TextEditingController(text: '');
    _emailController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
    _coachingCodeController = TextEditingController(text: coachCode);
    _countryController = TextEditingController(text: '');
    _cityController = TextEditingController(text: '');
    _descController = TextEditingController(text: '');

    // Şifre Controller'ları
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _newPasswordRepeatController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user_data');

    if (userJson != null) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userJson);
        final String userRole = userData['role'];

        bool isStudent = userRole == "student";

        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _countryController.text = userData['country'] ?? '';
          _cityController.text = userData['city'] ?? '';
          _descController.text = studentDesc;
          _userAssetImage = userData['photo'];
        });

        // --- API İSTEĞİ BAŞLIYOR ---
        setState(() {
          _isLoadingCoach = true;
        });

        if (isStudent) {
          final resultStudentCoach = await widget.profileRepository
              .getStudentsCoach();

          if (resultStudentCoach['success'] == true &&
              resultStudentCoach['coach'] != null) {
            final Map<String, dynamic> coachData = resultStudentCoach['coach'];

            setState(() {
              _coachName =
                  coachData['name'] ??
                  "${coachData['firstName']} ${coachData['surname']}";
              coachCode = coachData['refCode'] ?? "Kod Yok";
              _coachingCodeController.text = coachCode;
              _coachImageUrl = coachData['photo'] ?? "";
              _hasCoach = true;
            });
          } else {
            setState(() {
              _hasCoach = false;
              _coachingCodeController.text = "Bir Koça Bağlı Değilsiniz";
              _coachName = "";
            });
          }
        } else {
          coachCode = userData['refCode'] ?? "Kod Yok";

          setState(() {
            _coachingCodeController.text = coachCode;
            _descController.text = coachDesc;
          });
        }
      } catch (e) {
        debugPrint("User JSON decode veya Koç veri çekme hatası: $e");
        setState(() {
          _hasCoach = false;
        });
      } finally {
        // --- İSTEK BAŞARILI VEYA HATALI BİTSE DE LOADING'İ KAPAT ---
        setState(() {
          _isLoadingCoach = false;
        });
      }
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        title: const Text(
          'Hesabınızı Silmek İstediğinize Emin Misiniz?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        content: const Text(
          'Bu işlem geri alınamaz. Hesabınız ve tüm kişisel verileriniz kalıcı olarak silinecektir.',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Onay penceresini kapat
              Navigator.of(dialogContext).pop();

              // 2. Silme işlemini başlat
              await _handleDeleteAccount(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    // 1. Ekran üzerinde yükleniyor indikatorü göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    try {
      // 2. Remote Data Source çağrısı
      final authRemoteDataSource = AuthRemoteDataSource();
      final response = await authRemoteDataSource.deleteAccount();

      // Yükleniyor dialogunu kapat
      if (context.mounted) Navigator.of(context).pop();

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (!context.mounted) return;

        // 3. Başarılı Mesajı Göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesabınız başarıyla silindi.'),
            backgroundColor: Colors.green,
          ),
        );

        // 4. Kullanıcıyı Giriş (Login) Ekranına Yönlendir ve Tüm Sayfa Geçmişini Temizle
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login', // Kendi Login rota/path adınız
          (route) => false,
        );
      } else {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['msg'] ?? 'Hesap silinemedi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Yükleniyor dialogunu kapat
      if (context.mounted) Navigator.of(context).pop();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bağlantı hatası oluştu, lütfen tekrar deneyin.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _coachingCodeController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _newPasswordRepeatController.dispose();
    super.dispose();
  }

  // --- HESAP BİLGİLERİ AKSİYONLARI ---
  void _startEditingProfile() {
    setState(() {
      _isEditingProfile = true;
      _profileBackup['name'] = _nameController.text;
      _profileBackup['email'] = _emailController.text;
      _profileBackup['phone'] = _phoneController.text;
      _profileBackup['country'] = _countryController.text;
      _profileBackup['city'] = _cityController.text;
      if (!_hasCoach) {
        _coachingCodeController.text = "";
      }
    });
  }

  void _cancelEditingProfile() {
    setState(() {
      _isEditingProfile = false;
      _isChangingCoach = false;
      _nameController.text = _profileBackup['name'] ?? '';
      _emailController.text = _profileBackup['email'] ?? '';
      _phoneController.text = _profileBackup['phone'] ?? '';
      _countryController.text = _profileBackup['country'] ?? '';
      _cityController.text = _profileBackup['city'] ?? '';
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveProfileChanges() async {
    // Klavye ve odağı kapat
    FocusScope.of(context).unfocus();

    // Değişiklik kontrolü (Backup haritası ile controller'ların mevcut değerlerini kıyaslıyoruz)
    final bool isNameChanged =
        _nameController.text != (_profileBackup['name'] ?? '');
    final bool isEmailChanged =
        _emailController.text != (_profileBackup['email'] ?? '');
    final bool isPhoneChanged =
        _phoneController.text != (_profileBackup['phone'] ?? '');
    final bool isCountryChanged =
        _countryController.text != (_profileBackup['country'] ?? '');
    final bool isCityChanged =
        _cityController.text != (_profileBackup['city'] ?? '');

    final bool hasProfileChanges =
        isNameChanged ||
        isEmailChanged ||
        isPhoneChanged ||
        isCountryChanged ||
        isCityChanged;

    // Koç kodu girilmiş mi kontrolü (Eğer koçu yoksa veya değiştir modundaysa inputa bakarız)
    final String enteredCoachCode = _coachingCodeController.text.trim();
    final bool hasNewCoachCodeSubmitted =
        (!_hasCoach || _isChangingCoach) &&
        enteredCoachCode.isNotEmpty &&
        enteredCoachCode != "Bir Koça Bağlı Değilsiniz";

    // Eğer hiçbir şey değiştirilmediyse boşuna API'ye istek atmayalım
    if (!hasProfileChanges && !hasNewCoachCodeSubmitted) {
      setState(() {
        _isEditingProfile = false;
        _isChangingCoach = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Herhangi bir değişiklik yapılmadı.'),
          backgroundColor: Colors.blueGrey,
        ),
      );
      return;
    }

    // Ekranı kilitlemek veya loading göstermek istersen bir state açabilirsin.
    // Şimdilik düzenleme modunu kapatıyoruz.
    setState(() {
      _isEditingProfile = false;
      _isChangingCoach = false;
    });

    bool? profileSuccess;
    bool? coachSuccess;
    String coachMessage = "";

    // --- 1. ADIM: PROFİL GÜNCELLEME İSTEĞİ ---
    if (hasProfileChanges) {
      try {
        final profileBody = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'country': _countryController.text,
          'city': _cityController.text,
        };

        // TODO: Repository'ndeki updateProfile fonksiyon adını ve parametre yapısını kontrol et
        final profileResult = await widget.profileRepository.updateProfile(
          profileBody,
        );
        profileSuccess = profileResult['success'] == true;

        if (profileSuccess) {
          if (profileResult['student'] != null) {
            final Map<String, dynamic> updatedStudentData =
                profileResult['student'];

            // 2. Yol: SharedPreferences'a yeni datayı JSON string olarak gömüyoruz
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_data', jsonEncode(updatedStudentData));
          }

          // Başarılıysa backup'ı güncelle ki iptal edilirse yeni değerlere dönebilsin
          _profileBackup['name'] = _nameController.text;
          _profileBackup['email'] = _emailController.text;
          _profileBackup['phone'] = _phoneController.text;
          _profileBackup['country'] = _countryController.text;
          _profileBackup['city'] = _cityController.text;
        }
      } catch (e) {
        debugPrint("Profil güncelleme API hatası: $e");
        profileSuccess = false;
      }
    }

    // --- 2. ADIM: KOÇ EKLEME İSTEĞİ ---
    if (hasNewCoachCodeSubmitted) {
      try {
        // TODO: Repository'ndeki addCoach fonksiyon adını kontrol et
        final coachResult = await widget.profileRepository.addCoach(
          refCode: enteredCoachCode,
        );
        coachSuccess = coachResult['coach'] != null;

        if (coachSuccess) {
          // Koç başarıyla eklendiyse local state'i güncel tutalım
          // Eğer API'den koç ismi dönüyorsa onu basabilirsin, şimdilik kodu veya mock ismi veriyoruz
          if (coachResult['coach'] != null) {
            final coachData = coachResult['coach'];
            _coachName =
                coachData['name'] ??
                "${coachData['firstName']} ${coachData['surname']}";
            coachCode = coachData['refCode'] ?? enteredCoachCode;
          } else {
            _coachName = "Öğrenci Koçu";
            coachCode = enteredCoachCode;
          }
          _coachingCodeController.text = coachCode;
          _hasCoach = true;
        } else {
          coachMessage = coachResult['message'] ?? "Koçluk kodu bulunamadı.";
        }
      } catch (e) {
        debugPrint("Koç ekleme API hatası: $e");
        coachSuccess = false;
        coachMessage = "Sistemsel bir hata nedeniyle koç eklenemedi.";
      }
    }

    // --- 3. ADIM: SONUÇ KOMBİNASYONLARINA GÖRE MESAJ YÖNETİMİ ---
    if (!mounted) return;

    // Senaryo A: Hem Profil Hem Koç Değişti
    if (hasProfileChanges && hasNewCoachCodeSubmitted) {
      if (profileSuccess == true && coachSuccess == true) {
        _showFeedbackSnackBar(
          context,
          'Profil bilgileriniz güncellendi ve koçunuz eklendi.',
          Colors.green,
        );
      } else if (profileSuccess == true && coachSuccess == false) {
        _showFeedbackSnackBar(
          context,
          'Profil bilgileriniz güncellendi fakat koç eklenemedi: $coachMessage',
          Colors.orange,
        );
      } else if (profileSuccess == false && coachSuccess == true) {
        _showFeedbackSnackBar(
          context,
          'Koçunuz başarıyla eklendi ancak profil bilgileri güncellenemedi.',
          Colors.orange,
        );
      } else {
        _showFeedbackSnackBar(
          context,
          'İşlem başarısız. Güncellemeler kaydedilemedi.',
          Colors.red,
        );
      }
    }
    // Senaryo B: Sadece Profil Değişti
    else if (hasProfileChanges) {
      if (profileSuccess == true) {
        _showFeedbackSnackBar(
          context,
          'Profil bilgileriniz başarıyla güncellendi.',
          Colors.green,
        );
      } else {
        _showFeedbackSnackBar(
          context,
          'Profil bilgileri güncellenirken bir hata oluştu.',
          Colors.red,
        );
      }
    }
    // Senaryo C: Sadece Koç Kodu Girildi
    else if (hasNewCoachCodeSubmitted) {
      if (coachSuccess == true) {
        _showFeedbackSnackBar(
          context,
          'Öğrenci koçunuz başarıyla tanımlandı.',
          Colors.green,
        );
      } else {
        _showFeedbackSnackBar(context, coachMessage, Colors.redAccent);
        // Başarısız olduysa eski haline (boş veya yazıya) geri çekebilirsin
        setState(() {
          _coachingCodeController.text = _hasCoach
              ? coachCode
              : "Bir Koça Bağlı Değilsiniz";
        });
      }
    }

    // Sayfayı tamamen yenilemek için init'teki yükleme fonksiyonunu tekrar tetikleyebilirsin
    _loadUserData();
  }

  // Kod tekrarını önlemek için yardımcı SnackBar metodu
  void _showFeedbackSnackBar(
    BuildContext context,
    String message,
    Color bgColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- KOÇLUK ÖZEL AKSİYONLARI ---
  void _showCoachingInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.textPrimary),
            SizedBox(width: 8),
            Text(
              'Koçluk Kodu Nedir?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          _descController.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Kapat',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveCoachingCode() {
    if (_coachingCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir koçluk kodu giriniz.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _hasCoach = true;
      _isChangingCoach = false;
      _coachName = "Yeni Koç Başarıyla Bağlandı"; // API'den gelen isim olmalı
    });
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koçluk kodu başarıyla güncellendi.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteCoach() async {
    showDialog(
      context: context,
      barrierDismissible:
          false, // İşlem esnasında dışarı tıklayarak kapatılmasın
      builder: (BuildContext dialogContext) {
        // Dialog içinde loading state'ini yönetmek için StatefulBuilder kullanıyoruz
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isDeleting = false;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Bağlantıyı Kopar?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              content: isDeleting
                  ? const Row(
                      children: [
                        CircularProgressIndicator(color: Colors.redAccent),
                        SizedBox(width: 16),
                        Text('Bağlantı kesiliyor...'),
                      ],
                    )
                  : const Text(
                      'Mevcut öğrenci koçunuzla olan bağınızı koparmak istediğinize emin misiniz? '
                      'Bu işlem sonucunda koçunuz gelişim takibinizi göremeyecektir.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
              actions: isDeleting
                  ? null // İstek atılırken butonları gizleyerek çift tıklamayı önlüyoruz
                  : [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Vazgeç',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Dialog içindeki loading durumunu aktif et
                          setDialogState(() {
                            isDeleting = true;
                          });

                          try {
                            // API Çağrısı
                            final resultStudentCoach = await widget
                                .profileRepository
                                .deleteCoach();
                            // Dialog'ı kapat
                            if (mounted) Navigator.pop(dialogContext);

                            if (resultStudentCoach['success'] == true) {
                              // API başarılı döndüyse ana ekranın state'ini güncelle
                              setState(() {
                                _hasCoach = false;
                                _isChangingCoach = false;
                                _coachingCodeController.text =
                                    "Bir Koça Bağlı Değilsiniz";
                                _coachName = "";
                                _coachImageUrl = "";
                              });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Koç bağlantısı başarıyla kaldırıldı.',
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            } else {
                              // API success: false döndüyse hata mesajı göster
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      resultStudentCoach['message'] ??
                                          'Bir hata oluştu, bağlantı kesilemedi.',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // HTTP veya decode hatası durumunda dialog'ı kapat ve logla
                            if (mounted) Navigator.pop(dialogContext);
                            debugPrint("Koç silme hatası: $e");

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Sistemsel bir hata oluştu. Lütfen tekrar deneyin.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Bağlantıyı Kopar',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }

  // --- ŞİFRE AKSİYONLARI ---
  void _startEditingPassword() {
    setState(() {
      _isEditingPassword = true;
    });
  }

  void _cancelEditingPassword() {
    setState(() {
      _isEditingPassword = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _newPasswordRepeatController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _savePasswordChanges() {
    if (_newPasswordController.text != _newPasswordRepeatController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni şifreler birbiriyle uyuşmuyor!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isEditingPassword = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _newPasswordRepeatController.clear();
    });
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şifreniz başarıyla değiştirildi.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _changeCoachMode({String coachCode = ""}) {
    setState(() {
      _isChangingCoach = true;
      _coachingCodeController.text = coachCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccountSettingsNavyHeader(
            userImage:
                'assets/avatars/${_userAssetImage}', // Senin tanımlı olan lokal asset yolun
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==========================================
                  // 1. BÖLÜM: HESAP BİLGİLERİ FORMU
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hesap Bilgileri',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: _isEditingProfile
                            ? _cancelEditingProfile
                            : _startEditingProfile,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isEditingProfile
                                ? Icons.close
                                : Icons.edit_outlined,
                            key: ValueKey<bool>(_isEditingProfile),
                            color: _isEditingProfile
                                ? Colors.grey
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  AccountSettingsTextField(
                    label: 'Ad Soyad',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    readOnly: !_isEditingProfile,
                  ),
                  const SizedBox(height: 10),
                  AccountSettingsTextField(
                    label: 'E-Mail Adresi',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    readOnly: !_isEditingProfile,
                  ),
                  const SizedBox(height: 10),
                  AccountSettingsTextField(
                    label: 'Telefon Numarası',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    readOnly: !_isEditingProfile,
                  ),
                  const SizedBox(height: 10),

                  // --- DİNAMİK KOÇLUK KODU ALANI ---
                  // --- DİNAMİK KOÇLUK KODU ALANI ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isLoadingCoach) ...[
                        // Başlığı loading durumunda da görmek için buraya ekliyoruz
                        const Text(
                          'Öğrenci Koçluğu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 62,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE8ECF0)),
                          ),
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.appBarBackground,
                              ),
                            ),
                          ),
                        ),
                      ] else if (_hasCoach && !_isChangingCoach) ...[
                        // Koç varken başlık ve kart yan yana/alt alta temiz dursun diye buraya alıyoruz
                        const Text(
                          'Öğrenci Koçluğu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE8ECF0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                  _coachImageUrl.isNotEmpty
                                      ? 'assets/avatars/$_coachImageUrl'
                                      : 'assets/avatars/user.png',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _coachName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_isEditingProfile) ...[
                                TextButton(
                                  onPressed: () =>
                                      _changeCoachMode(coachCode: ""),
                                  child: const Text(
                                    'Değiştir',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _deleteCoach,
                                  child: const Text(
                                    'Sil',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        // Koç yoksa veya DEĞİŞTİR modundaysa:
                        // Dışarıdaki Text ve SizedBox'ı kaldırıp direkt widget'ın kendi label'ını kullanıyoruz.
                        AccountSettingsTextField(
                          label:
                              'Öğrenci Koçluğu', // Başlığı buraya verdik, widget içindeki ideal boşluğu kullanacak
                          controller: _coachingCodeController,
                          hint: 'Kod Giriniz',
                          readOnly: !_isEditingProfile,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.help_outline,
                              color: Colors.grey,
                            ),
                            onPressed: _showCoachingInfoDialog,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  /*
                  Row(
                    children: [
                      Expanded(
                        child: AccountSettingsTextField(
                          label: 'Ülke',
                          controller: _countryController,
                          textInputAction: TextInputAction.next,
                          readOnly: !_isEditingProfile,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AccountSettingsTextField(
                          label: 'Şehir',
                          controller: _cityController,
                          textInputAction: TextInputAction.next,
                          readOnly: !_isEditingProfile,
                        ),
                      ),
                    ],
                  ),
                  */
                  // Hesap Bilgilerini Kaydet Butonu
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _saveProfileChanges,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.appBarBackground,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _isEditingProfile
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFE8ECF0), height: 1),
                  const SizedBox(height: 24),

                  // ==========================================
                  // 2. BÖLÜM: ŞİFRE DEĞİŞTİRME FORMU
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Şifre ve Güvenlik',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: _isEditingPassword
                            ? _cancelEditingPassword
                            : _startEditingPassword,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isEditingPassword
                                ? Icons.close
                                : Icons.edit_outlined,
                            key: ValueKey<bool>(_isEditingPassword),
                            color: _isEditingPassword
                                ? Colors.grey
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  AccountSettingsPasswordField(
                    label: 'Mevcut Şifre',
                    hint: 'Mevcut Şifre giriniz',
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    readOnly: !_isEditingPassword,
                    onToggleVisibility: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  const SizedBox(height: 12),
                  AccountSettingsPasswordField(
                    label: 'Yeni Şifre',
                    hint: 'Yeni Şifre giriniz',
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    readOnly: !_isEditingPassword,
                    onToggleVisibility: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                  const SizedBox(height: 12),
                  AccountSettingsPasswordField(
                    label: 'Yeni Şifre Tekrar',
                    hint: 'Yeni Şifre tekrar giriniz',
                    controller: _newPasswordRepeatController,
                    obscureText: _obscureNewRepeat,
                    readOnly: !_isEditingPassword,
                    onToggleVisibility: () =>
                        setState(() => _obscureNewRepeat = !_obscureNewRepeat),
                  ),

                  // Şifreyi Kaydet Butonu
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _savePasswordChanges,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.appBarBackground,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Şifreyi Güncelle',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _isEditingPassword
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                  ),

                  // ==========================================
                  // 3. BÖLÜM: HESABIMI SİL ALANI
                  // ==========================================
                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFE8ECF0), height: 1),
                  const SizedBox(height: 20),

                  InkWell(
                    onTap: () => _showDeleteAccountDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Hesabımı Sil',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
