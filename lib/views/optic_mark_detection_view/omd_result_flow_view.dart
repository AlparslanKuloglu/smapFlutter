import 'package:appinio_swiper/appinio_swiper.dart'; // Lütfen pubspec.yaml'a ekleyin
import 'package:flutter/material.dart';
import 'dart:convert'; // 1. Mutlaka bu kütüphaneyi ekle
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentmap/core/theme/app_colors.dart';

final Map<String, Map<String, String>> lessonNameAndPhoto = {
  "66214a6982ff212039ea3294": {
    "name": "TYT Tarih",
    "image": "assets/tarih.png",
  },
  "663e37a24fb443839593141b": {
    "name": "TYT Türkçe",
    "image": "assets/turkce.png",
  },
  "663e387c4fb443839593141c": {
    "name": "TYT Matematik",
    "image": "assets/mat.png",
  },
  "6654977e17046de7432ed446": {
    "name": "TYT Biyoloji",
    "image": "assets/biological.png",
  },
  "665c5e80dad9088c202c6c16": {
    "name": "TYT Fizik",
    "image": "assets/physics.png",
  },
  "66604f1b2676809673eb4736": {"name": "TYT Kimya", "image": "assets/fen.png"},
  "6660eec58cf59b23d04006b4": {
    "name": "TYT Coğrafya",
    "image": "assets/cografya.png",
  },
  "66bfb7a749ecda29c59f556b": {
    "name": "TYT Geometri",
    "image": "assets/geometry1.png",
  },
  "66b0e776c99f8fc189ff35fd": {
    "name": "AYT Türk Dili ve Edebiyatı",
    "image": "assets/edebiyat.png",
  },
  "66952a89986199d2903227b5": {
    "name": "AYT Coğrafya",
    "image": "assets/ayt_cografya.png",
  },
  "665ca77316c299c4d7bd2534": {
    "name": "AYT Matematik",
    "image": "assets/ayt_matematik.png",
  },
  "665cb46416c299c4d7bd2539": {
    "name": "AYT Geometri",
    "image": "assets/ayt_geometri.png",
  },
  "665c5eacdad9088c202c6c17": {
    "name": "AYT Fizik",
    "image": "assets/ayt_fizik.png",
  },
  "66604f252676809673eb4737": {
    "name": "AYT Kimya",
    "image": "assets/ayt_kimya.png",
  },
  "6654978d17046de7432ed448": {
    "name": "AYT Biyoloji",
    "image": "assets/ayt_biyoloji.png",
  },
};

class OmdResultFlowView extends StatefulWidget {
  const OmdResultFlowView({required this.data, super.key});
  final dynamic data;

  @override
  State<OmdResultFlowView> createState() => _OmdResultFlowViewState();
}

class _OmdResultFlowViewState extends State<OmdResultFlowView> {
  final PageController _pageController = PageController();
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  int _currentStep = 0;
  int _currentType = 0;
  int _currentTypeRanks = 0;
  int totalInfoCard = 0;
  bool cardsInfoIsReady = false;
  Map<String, int> lessonCounts = {};
  Map<String, String> ranksAndPoints = {};

  // ---------------------------------------------------------------------------
  // 2. GETTER'LAR (widget.data üzerindeki verilere anlık, güvenli erişim)
  // ---------------------------------------------------------------------------
  Map<String, dynamic>? get _mexamFound =>
      widget.data?['mexamFound'] as Map<String, dynamic>?;

  Map<String, dynamic>? get _itemMexam =>
      _mexamFound?['mexam'] as Map<String, dynamic>?;

  bool get _isTypeOne => _itemMexam?['type'] == 1;

  String get _fullUrl {
    final rawImage = _itemMexam?['image']?.toString() ?? "";
    return rawImage.isNotEmpty
        ? "https://www.smaptr.com.tr/uploads/$rawImage"
        : "";
  }

  String get _mexamId => _mexamFound?['_id']?.toString() ?? "";
  String get _publisherName => _mexamFound?['publisherName']?.toString() ?? "";
  String get _itemName => _mexamFound?['itemName']?.toString() ?? "";

  String _totalTrue = "0";
  String _totalPass = "0";
  String _totalWrong = "0";
  String _totalNet = "0";
  dynamic get _aytNets => _mexamFound?['aytNets'];

  List<dynamic> get _arrayPointsHam =>
      (_mexamFound?['pointsHam'] is List) ? _mexamFound!['pointsHam'] : [];

  List<dynamic> get _arrayRanksHam =>
      (_mexamFound?['ranksHam'] is List) ? _mexamFound!['ranksHam'] : [];

  List<dynamic> get _arrayPoints =>
      (_mexamFound?['points'] is List) ? _mexamFound!['points'] : [];

  List<dynamic> get _arrayRanks =>
      (_mexamFound?['ranks'] is List) ? _mexamFound!['ranks'] : [];

  void _initializeData() {
    final int userAimType = userData?['aimType'] ?? 3;

    _currentType = _isTypeOne ? 0 : userAimType;
    _currentTypeRanks = _isTypeOne ? 0 : userAimType;
    _onTabChanged(_currentType, 1);
    _calculateRanksAndPoints();
  }

  void _calculateRanksAndPoints() {
    final pointsHamList = _arrayPointsHam;
    final ranksHamList = _arrayRanksHam;
    final pointsList = _arrayPoints;
    final ranksList = _arrayRanks;

    ranksAndPoints = {
      'pointHam': _currentTypeRanks < pointsHamList.length
          ? pointsHamList[_currentTypeRanks].toString()
          : '-',
      'rankHam': _currentTypeRanks < ranksHamList.length
          ? ranksHamList[_currentTypeRanks].toString()
          : '-',
      'point': _currentTypeRanks < pointsList.length
          ? pointsList[_currentTypeRanks].toString()
          : '-',
      'rank': _currentTypeRanks < ranksList.length
          ? ranksList[_currentTypeRanks].toString()
          : '-',
    };
  }

  /// Sekme değişiminde çağıracağınız metod
  void _onTabChanged(int newTypeIndex, int tabType) {
    setState(() {
      if (tabType == 1) {
        if (newTypeIndex == 0) {
          // tyt ise
          _totalNet = _mexamFound?['net']?.toString() ?? "0";
          _totalTrue = _mexamFound?['true']?.toString() ?? "0";
          _totalWrong = _mexamFound?['wrong']?.toString() ?? "0";
          _totalPass = _mexamFound?['pass']?.toString() ?? "0";
        } else {
          _currentType = newTypeIndex;
          // Sekme indeksi (0, 1, 2) -> aytNets Key (2, 3, 4)
          final int netKey = newTypeIndex;
          final selectedNetObj =
              _aytNets?[netKey] ?? _aytNets?[netKey.toString()];
          if (selectedNetObj != null) {
            _totalNet = selectedNetObj['net']?.toString() ?? "0";
            _totalTrue = selectedNetObj['true']?.toString() ?? "0";
            _totalWrong = selectedNetObj['wrong']?.toString() ?? "0";
            _totalPass = selectedNetObj['pass']?.toString() ?? "0";
          }
        }
      } else if (tabType == 2) {
        _currentTypeRanks = newTypeIndex;
        _calculateRanksAndPoints();
      }
    });
  }

  // --- Renk Paleti (Görsellerdeki Mor Temaya Uygun) ---
  final Color kDarkPurpleBg = const Color(0xFF512DA8); // Arka plan moru
  final Color kCardPurple = const Color(0xFF673AB7); // Kartlar için açık mor
  final Color kOrange = const Color(0xFFFF6F00); // Vurgu rengi
  final Color kWhite = Colors.white;
  final Color kDarkBlue = const Color(0xFF1F2937);
  final Color kGreen = const Color(0xFF4CAF50);
  final Color kRed = const Color(0xFFF44336);
  final Color kGrayText = const Color(0xFF9CA3AF);
  final Color kLightBg = const Color(0xFFF9FAFB);
  final Color kGreyStat = Color(0xFF9CA3AF);
  final Color kBgColor = Color(0xFFF3F4F6);
  final Color kBannerBg = Color(0xFFFDE8D7); // Açık turuncu bilgi bandı

  bool _isRanking = false;

  @override
  void initState() {
    super.initState();
    _initPage(); // Sayfa yükleme zincirini başlatır
  }

  Future<void> _initPage() async {
    // 1. Önce kullanıcı verilerini bekle ve yükle
    await _getUserData();

    // 2. userData yüklendi, artık güvenle ilklendirme yapılabilir
    _initializeData();

    // 3. İsteğe bağlı: API çağrısını da sıralı veya bağımsız çalıştırın
    _getExamCardDetails();
  }

  Future<void> _getExamCardDetails() async {
    final mexam = widget.data?['mexamFound'];
    if (mexam == null) return;

    final mexamId = mexam['_id'].toString();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionCookie = prefs.getString('connect_sid');

      final response = await http.get(
        Uri.parse(
          'https://www.smaptr.com/student/getTotalInfoCard?mexamId=$mexamId',
        ),
        headers: {
          'Cookie': 'connect.sid=$sessionCookie',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> items = data['data'] as List<dynamic>;

        // Hesaplamaları yapıp state'i güncelliyoruz
        setState(() {
          lessonCounts.clear(); // Her ihtimale karşı temizle
          totalInfoCard = 0;

          for (var item in items) {
            String lessonId = item['lesson'].toString();
            lessonCounts[lessonId] = (lessonCounts[lessonId] ?? 0) + 1;
            totalInfoCard += 1;
          }
          cardsInfoIsReady = true;
        });
      }
    } catch (e) {
      debugPrint("Kart verisi yükleme hatası: $e");
    }
  }

  Map<String, dynamic>? userData;
  bool isLoadingUser = true;

  Future<void> _getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user_data');

      if (userJson != null) {
        setState(() {
          userData = json.decode(userJson) as Map<String, dynamic>;
          isLoadingUser = false;
        });
      } else {
        setState(() => isLoadingUser = false);
      }
    } catch (e) {
      debugPrint("Kullanıcı verisi yükleme hatası: $e");
      setState(() => isLoadingUser = false);
    }
  }

  // --- MOCK DATA: Adım 2 (Ders Seçimi) ---
  List<Map<String, dynamic>> mockLessons = [];

  void _nextPage() {
    _showSuccessSnackBar(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Denemeniz Başarıyla Kaydedildi!'),
        backgroundColor: AppColors.appBarBlueGrey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Görseldeki koyu lacivert tonu
    const Color kDarkNavy = Color(0xFF0F172A);
    const Color kBgLight = Color(0xFFF3F4F6);
    final mexam = widget.data?['mexamFound'];
    final mexamId = mexam['_id'].toString();
    void printFullText(String text) {
      final pattern = RegExp('.{1,800}'); // 800 karakterlik parçalara böl
      pattern.allMatches(text).forEach((match) => print(match.group(0)));
    }

    // Kullanımı:
    //printFullText("gelen mexam ------------------- ${widget.data}");
    //print("mexam: $mexam");
    final List<dynamic> lessonMockExams =
        mexam['lessonMockExams'] as List<dynamic>;

    final List<Map<String, dynamic>> organizedList = lessonMockExams.map((
      item,
    ) {
      final lessonId = item['lesson'];

      final lessonInfo = lessonNameAndPhoto[lessonId];

      return {
        "lessonId": lessonId,
        "name": lessonInfo?["name"] ?? "",
        "image": lessonInfo?["image"] ?? "",
        "net": item["net"],
        "pass": item["pass"],
        "true": item["true"],
        "wrong": item["wrong"],
      };
    }).toList();

    mockLessons = organizedList;

    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          // Özel Header Alanı (Kavisli ve Koyu Lacivert)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 8,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: kDarkNavy,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Üst Bar: Geri - Başlık - Profil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Geri Butonu
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        if (_currentStep == 0) {
                          Navigator.pop(context);
                        } else {
                          _prevPage();
                        }
                      },
                    ),

                    // Logo ve Başlık Yan Yana
                    Row(
                      children: [
                        Image.asset(
                          'assets/smaplogo.png',
                          width: 28, // Logonun genişliği
                          height: 28, // Logonun yüksekliği
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          width: 8,
                        ), // Logo ile yazı arasındaki boşluk
                        const Text(
                          'Deneme Analizi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Koşullu Avatar Yapısı
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.transparent,
                      backgroundImage:
                          (userData != null && userData!['photo'] != null)
                          ? AssetImage('assets/avatars/${userData!['photo']}')
                          : null,
                      child: (userData == null || userData!['photo'] == null)
                          ? const Icon(
                              Icons.account_circle,
                              color: Colors.white70,
                              size: 32,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // İçerik Alanı (PageView)
          Expanded(child: _buildStepOne(context)),
        ],
      ),
    );
  }

  // --- ADIM 1: MEVCUT GÖRSEL GÖSTERİMİ ---
  // Sayfa içinde bu değişkeni tanımlamalısınız: bool _isRanking = false;

  Widget _buildStepOne(BuildContext context) {
    return Container(
      color: kBgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Deneme Görseli
            Container(
              height: 200,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _fullUrl.isNotEmpty
                      ? Image.network(
                          _fullUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return ColoredBox(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 50,
                              ),
                            );
                          },
                        )
                      : const Icon(Icons.book, color: Colors.grey, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 15),

            Text(
              _publisherName,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _itemName,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            _buildNets(
              totalNet: _totalNet,
              totalTrue: _totalTrue,
              totalWrong: _totalWrong,
            ),
            const SizedBox(height: 16),

            // Bilgi Bandı (Sadece Sıralama aktifken veya genel bilgi olarak)
            if (!_isTypeOne)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kBannerBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "*TYT puanınız son çözdüğünüz denemeye göre hesaplanmıştır. OBP notunuz 85 olarak alınmıştır.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Deneme Sonucu / Sıralama Tab Switcher
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isRanking = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isRanking ? kDarkBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Puan ve Sıralama',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isRanking
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isRanking = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isRanking ? kDarkBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Deneme Sonucu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isRanking
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Koşullu İçerik: Sıralama Görünümü vs. Ders İstatistikleri
            _isRanking
                ? _buildRankingContent(kOrange, kGreen, _isTypeOne)
                : _buildExamResultContent(),

            const SizedBox(height: 24),
            // Turuncu Buton
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _nextPage,
                child: const Text(
                  'Ana Sayfaya Dön',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNets({
    required dynamic totalNet,
    required dynamic totalTrue,
    required dynamic totalWrong,
  }) {
    return Column(
      children: [
        // Puan Türü Sekmeleri (Eşit Ağırlık, Sayısal, Sözel)
        if (!_isTypeOne)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubTab(
                  title: "Eşit Ağırlık",
                  isActive: _currentType == 2, // Seçili sekme kontrolü
                  onTap: () => _onTabChanged(2, 1), // Indeks: 0
                ),
                _buildSubTab(
                  title: "Sayısal",
                  isActive: _currentType == 3,
                  onTap: () => _onTabChanged(3, 1), // Indeks: 1
                ),
                _buildSubTab(
                  title: "Sözel",
                  isActive: _currentType == 4,
                  onTap: () => _onTabChanged(4, 1), // Indeks: 2
                ),
              ],
            ),
          ),
        const SizedBox(
          height: 12,
        ), // Sekmeler ile istatistik kutuları arasına boşluk
        // İstatistik Kutuları (Net, Doğru, Yanlış)
        Row(
          children: [
            Expanded(
              child: _buildMainStatBox(
                'Net Sayısı',
                totalNet.toString(),
                kOrange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMainStatBox(
                'Doğru Sayısı',
                totalTrue.toString(),
                Color(0xFF3D526D),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMainStatBox(
                'Yanlış Sayısı',
                totalWrong.toString(),
                kRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // SIRALAMA İÇERİĞİ (Görseldeki alt kısım)
  Widget _buildRankingContent(Color kOrange, Color kGreen, bool isTypeOne) {
    return Column(
      children: [
        // Puan Türü Sekmeleri (Eşit Ağırlık, Sayısal, Sözel)
        if (!isTypeOne)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSubTab(
                  title: "Eşit Ağırlık",
                  isActive: _currentTypeRanks == 2,
                  onTap: () => _onTabChanged(2, 2), // Indeks: 0
                ),
                _buildSubTab(
                  title: "Sayısal",
                  isActive: _currentTypeRanks == 3,
                  onTap: () => _onTabChanged(3, 2), // Indeks: 0
                ),
                _buildSubTab(
                  title: "Sözel",
                  isActive: _currentTypeRanks == 4,
                  onTap: () => _onTabChanged(4, 2), // Indeks: 0
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Puan Kartları
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                "Yerleştirme Puanı",
                ranksAndPoints['point'].toString(),
                ranksAndPoints['rank'].toString(),
                "Yerleştirme Puanı Sıralaması",
                kGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                "Ham Puan",
                ranksAndPoints['pointHam'].toString(),
                ranksAndPoints['rankHam'].toString(),
                "Ham Puan Sıralaması",
                kGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap, // Tıklama olayını alacak parametre
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Tüm alana tıklanabilirlik sağlar
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? kOrange : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? kOrange : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(
    String title,
    String score,
    String rank,
    String rankTitle,
    Color green,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Ana Değer",
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          Text(
            score,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            rankTitle,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          Text(
            rank,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamResultContent() {
    // Veri yapılarını (List<Map>) kesin tiplerle tanımlayalım
    final lessonInfoStr = widget.data?['mexamFound']['lessonInfo'];
    final lessonInfo = jsonDecode(lessonInfoStr as String);

    final List<Map<String, dynamic>> tytSubjects = [
      {
        'name': 'Türkçe',
        'image': 'assets/turkce.png',
        'd': lessonInfo[0]['true'],
        'y': lessonInfo[0]['wrong'],
        'b': lessonInfo[0]['pass'],
      },
      {
        'name': 'Sosyal Bilimler',
        'image': 'assets/tarih.png',
        'd': lessonInfo[1]['true'],
        'y': lessonInfo[1]['wrong'],
        'b': lessonInfo[1]['pass'],
      },
      {
        'name': 'Matematik',
        'image': 'assets/mat.png',
        'd': lessonInfo[2]['true'],
        'y': lessonInfo[2]['wrong'],
        'b': lessonInfo[2]['pass'],
      },
      {
        'name': 'Fen Bilimleri',
        'image': 'assets/fen.png',
        'd': lessonInfo[3]['true'],
        'y': lessonInfo[3]['wrong'],
        'b': lessonInfo[3]['pass'],
      },
    ];

    final List<Map<String, dynamic>> otherSubjects = [
      {
        'name': 'Sosyal Bilimler - 1',
        'image': 'assets/turkce.png',
        'd': lessonInfo[0]['true'],
        'y': lessonInfo[0]['wrong'],
        'b': lessonInfo[0]['pass'],
      },
      {
        'name': 'Sosyal Bilimler - 2',
        'image': 'assets/tarih.png',
        'd': lessonInfo[1]['true'],
        'y': lessonInfo[1]['wrong'],
        'b': lessonInfo[1]['pass'],
      },
      {
        'name': 'Matematik',
        'image': 'assets/mat.png',
        'd': lessonInfo[2]['true'],
        'y': lessonInfo[2]['wrong'],
        'b': lessonInfo[2]['pass'],
      },
      {
        'name': 'Fen Bilimleri',
        'image': 'assets/fen.png',
        'd': lessonInfo[3]['true'],
        'y': lessonInfo[3]['wrong'],
        'b': lessonInfo[3]['pass'],
      },
    ];

    // Eğer data bir Map ise ve güvenli erişim (null-safety) istiyorsan:
    final bool isTypeOne = widget.data?['mexamFound']?['mexam']?['type'] == 1;
    final List<Map<String, dynamic>> selectedList = isTypeOne
        ? tytSubjects
        : otherSubjects;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSubjectCard(
                selectedList[0]['image']
                    as String, // 'as String' ile tipi netleştiriyoruz
                selectedList[0]['name'] as String,
                selectedList[0]['d'] as int, // Sayılar için 'as int'
                selectedList[0]['y'] as int,
                selectedList[0]['b'] as int,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSubjectCard(
                selectedList[1]['image'] as String,
                selectedList[1]['name'] as String,
                selectedList[1]['d'] as int,
                selectedList[1]['y'] as int,
                selectedList[1]['b'] as int,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSubjectCard(
                selectedList[2]['image'] as String,
                selectedList[2]['name'] as String,
                selectedList[2]['d'] as int,
                selectedList[2]['y'] as int,
                selectedList[2]['b'] as int,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSubjectCard(
                selectedList[3]['image'] as String,
                selectedList[3]['name'] as String,
                selectedList[3]['d'] as int,
                selectedList[3]['y'] as int,
                selectedList[3]['b'] as int,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectCard(String img, String title, int d, int y, int b) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kLightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(img, width: 26, height: 26, fit: BoxFit.contain),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown, // Sadece sığmadığı durumda küçültür
                  alignment:
                      Alignment.centerLeft, // Sola dayalı kalmasını sağlar
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // İdeal boyut (sığmazsa otomatik küçülür)
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _subStat('Doğru', d.toString(), Color(0xFF3D526D)),
              _subStat('Yanlış', y.toString(), kRed),
              _subStat('Boş', b.toString(), Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          val,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatBox(String title, String count, Color countColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: kLightBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: countColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
