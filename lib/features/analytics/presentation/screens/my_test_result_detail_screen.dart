import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/analytics/presentation/widgets/my_test_results_detail_widgets.dart';
import 'package:smap/repository/analysis_repository.dart';

String formatNumber(String value) {
  final number = int.tryParse(value);
  if (number == null) return value;
  final str = number.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < str.length; i++) {
    final reverseIndex = str.length - i;
    buffer.write(str[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

class MyTestResultDetailScreen extends StatefulWidget {
  const MyTestResultDetailScreen({required this.data, super.key});
  final dynamic data;

  @override
  State<MyTestResultDetailScreen> createState() =>
      _MyTestResultDetailScreenState();
}

class _MyTestResultDetailScreenState extends State<MyTestResultDetailScreen> {
  int _currentType = 0;
  bool _isRanking = false;
  int _selectedTabIndex = 0;
  final AnalysisRepository _analysisRepository = AnalysisRepository();
  Map<String, String> ranksAndPoints = {
    'pointHam': '',
    'rankHam': '',
    'point': '',
    'rank': '',
  };

  Map<String, dynamic>? userData;
  bool isLoadingUser = true;

  // --- YENİ EKLENEN ALANLAR ---
  // API'den gelecek olan ham Map verisini tutacak Future nesnesi
  late Future<Map<String, dynamic>> _topicAnalysisFuture;
  late Future<Map<String, dynamic>>? _infoCardsFuture;

  @override
  void initState() {
    super.initState();

    // 1. Adım: widget.data içinden mockexam ID'sini güvenli bir şekilde çekiyoruz
    final String mexamId =
        (widget.data?['_id'] ??
                widget.data?['mexamFound']?['_id'] ??
                widget.data?['mexam']?['_id'] ??
                '')
            .toString();

    // 2. Adım: Sayfa açılır açılmaz API isteğini SADECE BİR KERE tetikliyoruz
    // NOT: Repository veya ApiService sınıfınızın adını projenize göre güncelleyin.
    _topicAnalysisFuture = _analysisRepository.getMexamSubjectDetail(
      mexamId: mexamId,
    );
    _infoCardsFuture = _analysisRepository.getMexamItemDetail(mexamId: mexamId);
  }

  @override
  Widget build(BuildContext context) {
    const Color kBgLight = Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Deneme Detay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: null,
                        icon: Icon(Icons.arrow_back_ios),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 42,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B3D54),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      MyTestResultsDetailTopTabButton(
                        label: 'Genel',
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                      MyTestResultsDetailTopTabButton(
                        label: 'Sorular',
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                      MyTestResultsDetailTopTabButton(
                        label: 'Konu Analizi',
                        isSelected: _selectedTabIndex == 2,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                      MyTestResultsDetailTopTabButton(
                        label: 'Bilgi Kartları',
                        isSelected: _selectedTabIndex == 3,
                        onTap: () => setState(() => _selectedTabIndex = 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildBody(context),
                MyTestResultsDetailQuestionsTabContent(
                  mexam: widget.data,
                  analysisRepository: _analysisRepository,
                ),

                // --- 3. ADIM: 3. SEKMEYİ FUTUREBUILDER ILE SARIYORUZ ---
                FutureBuilder<Map<String, dynamic>>(
                  future: _topicAnalysisFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Hata oluştu: ${snapshot.error}"),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Konu analiz verisi bulunamadı."),
                      );
                    }

                    // Veri başarıyla yüklendiğinde daha önce hazırladığımız widget'a gönderiyoruz
                    return MyTestResultsDetailTopicAnalysisTabContent(
                      backendData: snapshot.data!,
                      mexam: widget.data,
                    );
                  },
                ),

                FutureBuilder<Map<String, dynamic>>(
                  future:
                      _infoCardsFuture, // 1. Adımda tanımladığımız Future değişkeni
                  builder: (context, snapshot) {
                    // A Durumu: Veri yüklenirken loader göster
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // B Durumu: Hata oluşursa hata mesajı göster
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Bilgi kartları yüklenirken hata oluştu: ${snapshot.error}",
                        ),
                      );
                    }

                    // C Durumu: Veri boş veya gelmediyse uyarı göster
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Bilgi kartı verisi bulunamadı."),
                      );
                    }

                    // D Durumu: Başarılı! Gelen veriyi (snapshot.data) widget'ına aktar
                    return MyTestResultsDetailInfoCardsTabContent(
                      backendData: snapshot
                          .data!, // Gelen veriyi parametre olarak alt widget'a gönderiyoruz
                      mexam: widget.data,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final String rawImage =
        (widget.data?['mexamFound']?['mexam']?['image'] ??
                widget.data?['mexam']?['image'] ??
                '')
            .toString()
            .trim();
    final String fullUrl = rawImage.isEmpty
        ? ''
        : (rawImage.startsWith('http://') || rawImage.startsWith('https://'))
        ? rawImage
        : 'https://www.smaptr.com.tr/uploads/$rawImage';

    final bool isTypeOne = widget.data?['mexam']?['type'] == 1;
    final totalTrue = (widget.data?['true'] ?? '0').toString();
    final totalWrong = (widget.data?['wrong'] ?? '0').toString();
    final totalNet = (widget.data?['net'] ?? '0').toString();

    final List arrayPointsHam = (widget.data?['pointsHam'] ?? []) as List;
    final List arrayRanksHam = (widget.data?['ranksHam'] ?? []) as List;
    final List arrayPoints = (widget.data?['points'] ?? []) as List;
    final List arrayRanks = (widget.data?['ranks'] ?? []) as List;

    _currentType = isTypeOne ? 0 : 0;

    if (arrayPointsHam.length > _currentType) {
      ranksAndPoints['pointHam'] = arrayPointsHam[_currentType].toString();
    }
    if (arrayRanksHam.length > _currentType) {
      ranksAndPoints['rankHam'] = arrayRanksHam[_currentType].toString();
    }
    if (arrayPoints.length > _currentType) {
      ranksAndPoints['point'] = arrayPoints[_currentType].toString();
    }
    if (arrayRanks.length > _currentType) {
      ranksAndPoints['rank'] = arrayRanks[_currentType].toString();
    }

    const Color kDarkBlue = Color(0xFF3D526D);
    const Color kOrange = Color(0xFFFF6600);
    const Color kGreen = Color(0xFF22C55E);
    const Color kRed = Color(0xFFEF4444);
    const Color kBgColor = Color(0xFFF3F4F6);

    return Container(
      color: kBgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            MyTestResultsDetailOmdExamCover(fullUrl: fullUrl),
            const SizedBox(height: 20),
            Text(
              'Deneme: ${widget.data?['mexam']?['order'] ?? '-'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.data?['itemName']?.toString() ?? 'Smap Deneme Sınavı',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: MyTestResultsDetailOmdMainStatBox(
                    title: 'Net Sayısı',
                    count: totalNet,
                    countColor: kOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MyTestResultsDetailOmdMainStatBox(
                    title: 'Doğru Sayısı',
                    count: totalTrue,
                    countColor: kDarkBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MyTestResultsDetailOmdMainStatBox(
                    title: 'Yanlış Sayısı',
                    count: totalWrong,
                    countColor: kRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isTypeOne) const MyTestResultsDetailOmdTytInfoBanner(),
            const SizedBox(height: 16),
            MyTestResultsDetailOmdRankingModeToggle(
              isRanking: _isRanking,
              selectedColor: kDarkBlue,
              onChanged: (value) => setState(() => _isRanking = value),
            ),
            const SizedBox(height: 20),
            _isRanking
                ? _buildRankingContent(kOrange, kGreen, isTypeOne)
                : _buildExamResultContent(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingContent(Color kOrange, Color kGreen, bool isTypeOne) {
    return Column(
      children: [
        if (!isTypeOne)
          MyTestResultsDetailOmdScoreTypeTabsRow(activeColor: kOrange),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MyTestResultsDetailOmdScoreCard(
                title: 'Yerleştirme Puanı',
                score: ranksAndPoints['point'].toString(),
                rank: formatNumber(ranksAndPoints['rank'].toString()),
                rankTitle: 'Yerleştirme Puanı Sıralaması',
                valueColor: kGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MyTestResultsDetailOmdScoreCard(
                title: 'Ham Puan',
                score: ranksAndPoints['pointHam'].toString(),
                rank: ranksAndPoints['rankHam'].toString(),
                rankTitle: 'Ham Puan Sıralaması',
                valueColor: kGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExamResultContent() {
    final lessonInfoStr = widget.data?['lessonInfo'];
    if (lessonInfoStr is! String || lessonInfoStr.isEmpty) {
      return const SizedBox.shrink();
    }
    final lessonInfo = jsonDecode(lessonInfoStr);
    if (lessonInfo is! List || lessonInfo.length < 4) {
      return const SizedBox.shrink();
    }

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

    final bool isTypeOne = widget.data?['mexam']?['type'] == 1;
    final List<Map<String, dynamic>> selectedList = isTypeOne
        ? tytSubjects
        : otherSubjects;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MyTestResultsDetailOmdSubjectCard(
                img: selectedList[0]['image'] as String,
                title: selectedList[0]['name'] as String,
                d: selectedList[0]['d'] as int,
                y: selectedList[0]['y'] as int,
                b: selectedList[0]['b'] as int,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MyTestResultsDetailOmdSubjectCard(
                img: selectedList[1]['image'] as String,
                title: selectedList[1]['name'] as String,
                d: selectedList[1]['d'] as int,
                y: selectedList[1]['y'] as int,
                b: selectedList[1]['b'] as int,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MyTestResultsDetailOmdSubjectCard(
                img: selectedList[2]['image'] as String,
                title: selectedList[2]['name'] as String,
                d: selectedList[2]['d'] as int,
                y: selectedList[2]['y'] as int,
                b: selectedList[2]['b'] as int,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MyTestResultsDetailOmdSubjectCard(
                img: selectedList[3]['image'] as String,
                title: selectedList[3]['name'] as String,
                d: selectedList[3]['d'] as int,
                y: selectedList[3]['y'] as int,
                b: selectedList[3]['b'] as int,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
