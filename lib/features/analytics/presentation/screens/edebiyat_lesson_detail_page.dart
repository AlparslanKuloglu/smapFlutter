import 'package:flutter/material.dart';
import 'package:smap/domain/models/general_lessons.dart';
import 'package:smap/core/constants/lesson_constants.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/repository/analysis_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:smap/features/analytics/presentation/screens/subject_detail_page.dart'
    as subjectDetailPage;

class EserTypeHelper {
  // 1. Adım: ID'den Eser Türünün Adını Bulan Harita
  static const Map<String, String> types = {
    "1": "Şiir",
    "2": "Roman",
    "3": "Öykü",
    "4": "Deneme",
    "5": "Makale",
    "6": "Tiyatro",
    "7": "Hikâye",
    "8": "Biyografi",
    "9": "Gezi Yazısı",
    "10": "Mektup",
    "11": "Anı",
    "12": "İnceleme/Araştırma",
    "13": "Ders Kitabı",
    "14": "Masal",
    "15": "Çocuk Kitabı",
    "16": "Fıkra",
    "17": "Taşlama",
    "18": "Röportaj",
    "19": "Mizah",
    "20": "Mülakat",
    "21": "Sohbet",
    "22": "Senaryo",
    "23": "Günlük",
    "24": "Eleştiri",
    "25": "Mitoloji",
    "26": "Özdeyiş",
    "27": "Monografi",
    "28": "Düzyazı",
    "29": "Marş",
    "30": "Şiir Kitabı",
    "31": "Kitap",
    "32": "Sözlük",
    "33": "Mesnevi",
  };

  // 2. Adım: Verdiğin "workTypeStyles" Yapısının Birebir Flutter Renk Karşılığı
  static const Map<String, Map<String, Color>> workTypeStyles = {
    "Şiir": {
      "bg": Color(0xFFFCE7F3),
      "text": Color(0xFFBE185D),
    }, // pink-100, pink-700
    "Roman": {
      "bg": Color(0xFFDBEAFE),
      "text": Color(0xFF1D4ED8),
    }, // blue-100, blue-700
    "Öykü": {
      "bg": Color(0xFFD1FAE5),
      "text": Color(0xFF047857),
    }, // emerald-100, emerald-700
    "Deneme": {
      "bg": Color(0xFFF3E8FF),
      "text": Color(0xFF6B21A8),
    }, // purple-100, purple-700
    "Makale": {
      "bg": Color(0xFFF1F5F9),
      "text": Color(0xFF334155),
    }, // slate-100, slate-700
    "Tiyatro": {
      "bg": Color(0xFFFFEDD5),
      "text": Color(0xFFC2410C),
    }, // orange-100, orange-700
    "Hikâye": {
      "bg": Color(0xFFCCFB14),
      "text": Color(0xFF0F766E),
    }, // teal-100, teal-700
    "Biyografi": {
      "bg": Color(0xFFE0E7FF),
      "text": Color(0xFF4338CA),
    }, // indigo-100, indigo-700
    "Gezi Yazısı": {
      "bg": Color(0xFFCFFAFE),
      "text": Color(0xFF0E7490),
    }, // cyan-100, cyan-700
    "Mektup": {
      "bg": Color(0xFFFEF08A),
      "text": Color(0xFFA16207),
    }, // yellow-100, yellow-700
    "Anı": {
      "bg": Color(0xFFFEF3C7),
      "text": Color(0xFFB45309),
    }, // amber-100, amber-700
    "İnceleme/Araştırma": {
      "bg": Color(0xFFF3F4F6),
      "text": Color(0xFF374151),
    }, // gray-100, gray-700
    "Ders Kitabı": {
      "bg": Color(0xFFF4F4F5),
      "text": Color(0xFF3F3F46),
    }, // zinc-100, zinc-700
    "Masal": {
      "bg": Color(0xFFFFE4E6),
      "text": Color(0xFFBE123C),
    }, // rose-100, rose-700
    "Çocuk Kitabı": {
      "bg": Color(0xFFECFCCB),
      "text": Color(0xFF4D7C0F),
    }, // lime-100, lime-700
    "Fıkra": {
      "bg": Color(0xFFFEE2E2),
      "text": Color(0xFFB91C1C),
    }, // red-100, red-700
    "Taşlama": {
      "bg": Color(0xFFF5F5F4),
      "text": Color(0xFF44403C),
    }, // stone-100, stone-700
    "Röportaj": {
      "bg": Color(0xFFEDE9FE),
      "text": Color(0xFF6D28D9),
    }, // violet-100, violet-700
    "Mizah": {
      "bg": Color(0xFFFEF08A),
      "text": Color(0xFF9A3412),
    }, // yellow-200, yellow-800
    "Mülakat": {
      "bg": Color(0xFFFAE8FF),
      "text": Color(0xFFA21CAF),
    }, // fuchsia-100, fuchsia-700
    "Sohbet": {
      "bg": Color(0xFFE0F2FE),
      "text": Color(0xFF0369A1),
    }, // sky-100, sky-700
    "Senaryo": {
      "bg": Color(0xFF1F2937),
      "text": Color(0xFFFFFFFF),
    }, // gray-800, white
    "Günlük": {
      "bg": Color(0xFFEEF2FF),
      "text": Color(0xFF4F46E5),
    }, // indigo-50, indigo-600
    "Eleştiri": {
      "bg": Color(0xFFFED7AA),
      "text": Color(0xFF9A3412),
    }, // orange-200, orange-800
    "Mitoloji": {
      "bg": Color(0xFFFEF3C7),
      "text": Color(0xFF78350F),
    }, // amber-200, amber-900
    "Özdeyiş": {
      "bg": Color(0xFFDCFCE7),
      "text": Color(0xFF15803D),
    }, // green-100, green-700
    "Monografi": {
      "bg": Color(0xFFEFF6FF),
      "text": Color(0xFF3B82F6),
    }, // blue-50, blue-500
    "Düzyazı": {
      "bg": Color(0xFFE2E8F0),
      "text": Color(0xFF1E293B),
    }, // slate-200, slate-800
    "Marş": {
      "bg": Color(0xFFDC2626),
      "text": Color(0xFFFFFFFF),
    }, // red-600, white
    "Şiir Kitabı": {
      "bg": Color(0xFFFBCFE8),
      "text": Color(0xFF9D174D),
    }, // pink-200, pink-800
    "Kitap": {
      "bg": Color(0xFFE5E7EB),
      "text": Color(0xFF1F2937),
    }, // gray-200, gray-800
    "Sözlük": {
      "bg": Color(0xFFF5F5F5),
      "text": Color(0xFF404040),
    }, // neutral-100, neutral-700
    "Mesnevi": {
      "bg": Color(0xFFA7F3D0),
      "text": Color(0xFF064E3B),
    }, // emerald-200, emerald-900
  };
}

class EdebiyatLessonDetailPage extends StatefulWidget {
  /// Sayfa başlığında görünmesi için dersin adını alıyoruz.
  final GeneralLesson lesson;
  final String examType;

  const EdebiyatLessonDetailPage({
    super.key,
    required this.lesson,
    required this.examType,
  });

  @override
  State<EdebiyatLessonDetailPage> createState() =>
      _EdebiyatLessonDetailPageState();
}

class _EdebiyatLessonDetailPageState extends State<EdebiyatLessonDetailPage> {
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  // API artık Liste döndürdüğü için veri tipini List<dynamic> yapıyoruz
  List<dynamic>? _topicsY;
  List<dynamic>? _topicsK;
  String _selectedMainSubjectId = "";

  // Repository instance'ını tanımlıyoruz
  late final AnalysisRepository _analysisRepository;

  @override
  void initState() {
    super.initState();
    _analysisRepository = AnalysisRepository();
    _fetchLessonDetails();
  }

  // ===========================================================================
  // API & REPOSITORY KISMI
  // ===========================================================================
  Future<void> _fetchLessonDetails() async {
    setState(() => _isLoading = true);

    try {
      // 1. Önce ID'ye göre ilgili dersi buluyoruz
      final selectedLesson = AppLessons.generalLessons.firstWhere(
        (lesson) => lesson['_id'] == widget.lesson.id,
        orElse: () => {},
      );

      // 2. Ders bulunduysa examType durumuna göre ilgili alanı çekiyoruz
      if (selectedLesson.isNotEmpty) {
        dynamic dataLessonId;

        if (widget.examType == "TYT") {
          dataLessonId = selectedLesson['lessonTyt'];
        } else if (widget.examType == "AYT") {
          dataLessonId = selectedLesson['lessonAyt'];
        } else {
          dataLessonId = selectedLesson['lessonId'];
        }

        // 3. EŞ ZAMANLI (PARALEL) REPOSITORY ÇAĞRISI
        // İki istek de aynı anda başlar, ikisi de tamamlanınca sonuçlar alınır
        final results = await Future.wait([
          _analysisRepository.getYazarEserMainSubjects(),
          _analysisRepository.getMainSubjects(
            lessonId: dataLessonId?.toString(),
          ),
        ]);

        final responseY = results[0]; // getYazarEserMainSubjects yanıtı
        final responseK = results[1]; // getMainSubjects yanıtı

        setState(() {
          _topicsY = responseY['mainSubjects'] as List<dynamic>? ?? [];
          _topicsK = responseK['subjects'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _topicsY = [];
          _topicsK = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _topicsY = null;
        _topicsK = null;
      });
      debugPrint("Repository verileri çekilirken hata oluştu: $e");
    }
  }

  int getMissingCountForTab(dynamic tabValue) {
    final list = (tabValue == 0 ? _topicsY : _topicsK) ?? [];

    return list.fold<int>(0, (sum, item) {
      if (item is Map) {
        return sum + ((item['itemDataCount'] ?? 0) as int);
      }
      return sum;
    });
  }

  void _handleStatusChanged(
    Map<String, dynamic> author,
    Map<dynamic, dynamic> updatedItemData,
  ) {
    setState(() {
      // 1. Status güncelle
      updatedItemData['status'] = 1;
      updatedItemData['statusArray'] = [1];

      // 2. Subject üzerinden _topicsY güncelle
      final String? itemSubject = updatedItemData['subject']?.toString();

      if (itemSubject != null && itemSubject.isNotEmpty) {
        for (final topic in _topicsY ?? []) {
          if (topic is Map<String, dynamic>) {
            final String? topicId = topic['_id']?.toString();

            if (topicId == itemSubject) {
              int currentCount = (topic['itemDataCount'] as int?) ?? 0;
              if (currentCount > 0) {
                topic['itemDataCount'] = currentCount - 1;
              }
              break;
            }
          }
        }
      }
    });
  }

  // ===========================================================================
  // ARAYÜZ (BUILD) KISMI
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Provider<AnalysisRepository>(
      create: (_) => AnalysisRepository(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildCustomHeader(
                    context,
                    lessonName: widget.lesson.name,
                    missingCount: getMissingCountForTab(_selectedTabIndex),
                    showOnlyMissing: false, // Geçici aktiflik durumu
                    onMissingToggle: () {
                      print("Eksikler butonuna basıldı!");
                    },
                  ),
                  Expanded(
                    child: _topicsY == null || _topicsY!.isEmpty
                        ? const Center(child: Text("Konu verisi bulunamadı."))
                        : _buildMainContent(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCustomHeader(
    BuildContext context, {
    required String lessonName,
    required int missingCount,
    required bool showOnlyMissing,
    required VoidCallback onMissingToggle,
  }) {
    const double tabHeight = 44.0;

    // Sabit Tab Seçeneklerimiz
    final List<Map<String, dynamic>> tabs = [
      {'name': 'Yazar & Eserler', 'index': 0},
      {'name': 'Konular', 'index': 1},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // =========================
        // 1. HEADER (Üst Kısım & Eksikler Butonu)
        // =========================
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 32,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Row(
            children: [
              // Geri Butonu
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              // Ders Adı
              Expanded(
                child: Center(
                  child: Text(
                    lessonName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Sağ Üst: Kırmızı Eksikler Kutusu
              GestureDetector(
                onTap: onMissingToggle,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: showOnlyMissing
                          ? const Color(0xFFEF4444)
                          : const Color(0xFFFCA5A5),
                      width: showOnlyMissing ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/information_card_with_border_red.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$missingCount',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // =========================
        // 2. TAB & BADGE ALANI
        // =========================
        Transform.translate(
          offset: const Offset(0, -22),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: tabHeight - 10,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ANA TAB KUTUSU
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: tabHeight,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: tabs.map((item) {
                        final String name = item['name'];
                        final int index = item['index'];
                        final bool isSelected = _selectedTabIndex == index;

                        return Expanded(
                          child: _buildSegmentButton(
                            label: name,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = index;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // BADGE KATMANI (Dokunmayı engellememesi için IgnorePointer ile sarılı)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Row(
                      children: tabs.map((item) {
                        final int index = item['index'];
                        // Her tab için eksik sayısını getiren metodunuz (Örn: 0: Yazar&Eser, 1: Konular)
                        final int count = getMissingCountForTab(index);

                        return Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (count > 0)
                                Positioned(
                                  right: -6,
                                  bottom: -18,
                                  child: _buildBadge(
                                    count,
                                    selected: _selectedTabIndex == index,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // YARDIMCI WIDGET'LAR
  // =========================

  Widget _buildSegmentButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
              color: selected
                  ? const Color(0xFFF97316)
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(int count, {required bool selected}) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: selected ? const Color(0xFFF97316) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final List<dynamic>? currentTopics = _selectedTabIndex == 0
        ? _topicsY
        : _topicsK;
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 2, // Burayı artırdık (İhtiyaca göre 36 veya 40 da yapabilirsin)
        bottom: 12,
      ),
      itemCount: currentTopics!.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> topic =
            currentTopics![index] as Map<String, dynamic>;

        // API'den gelen verileri okuyoruz
        final String currentTopicId = topic['_id'] as String? ?? '';
        final String currentTopicName =
            topic['name'] as String? ?? 'Bilinmeyen Konu';
        final int order = (topic['order'] as num? ?? 0).toInt();
        final int itemDataCount = (topic['itemDataCount'] as num? ?? 0).toInt();

        final String? image = topic['image'];
        final Color imageColor = AppColors.hexToColor(topic['imageColor']);
        final Color barColor = AppColors.hexToColor(topic['barColor']);

        return _LessonsTopicCard(
          topicId: currentTopicId,
          topicName: currentTopicName,
          order: order,
          itemDataCount: itemDataCount,
          image: image,
          imageColor: imageColor,
          barColor: barColor,
          onTap: () {
            if (_selectedTabIndex == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubTopicDetailPage(
                    onStatusChanged: _handleStatusChanged,
                    topicId: currentTopicId,
                    topicName: currentTopicName,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => subjectDetailPage.SubTopicDetailPage(
                    topicId: currentTopicId,
                    topicName: currentTopicName,
                    tabFilterValue: 9,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

// ===========================================================================
// KONU KARTI BİLEŞENİ
// ===========================================================================

class _LessonsTopicCard extends StatelessWidget {
  final String topicId; // Sayfa geçişi için ID ekledik
  final String topicName;
  final int order; // Konu sırası (Örn: 1, 2, 3)
  final int itemDataCount; // Gelen item veri sayısı
  final String? image;
  final Color imageColor;
  final Color barColor;
  final VoidCallback onTap; // Tıklama aksiyonunu dışarıdan alacağız

  static const int _placeholderDonem = 2;
  static const int _placeholderSanatci = 24;
  static const int _placeholderEser = 156;
  final String _imageBaseUrl = 'https://smaptr.com/subjectIcons/';
  static const double _placeholderProgress = 0.75;

  const _LessonsTopicCard({
    required this.topicId,
    required this.topicName,
    required this.order,
    required this.itemDataCount,
    required this.image,
    required this.imageColor,
    required this.barColor,
    required this.onTap, // Constructor'a ekledik
  });

  @override
  Widget build(BuildContext context) {
    const String _imageBaseUrl = 'https://smaptr.com/subjectIcons/';

    String? subjectImage = image;

    final String fullImageUrl =
        (subjectImage != null && subjectImage.isNotEmpty)
        ? '$_imageBaseUrl$subjectImage'
        : '';

    final int progressPercent = (_placeholderProgress * 100).round();

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 10, 10),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: _buildThumbnail(subjectImage, imageColor),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMainInfo(progressPercent)),
                            const SizedBox(width: 6),
                            Align(
                              alignment: Alignment.center,
                              child: _buildStatsColumn(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Align(
                      alignment: Alignment.center,
                      child: _buildArrowButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String? subjectImage, Color? imageColor) {
    final String fullImageUrl =
        (subjectImage != null && subjectImage.isNotEmpty)
        ? '$_imageBaseUrl$subjectImage'
        : '';

    return Container(
      width: 64, // <-- Dış katmanın genişliği SABİT
      height: 64, // <-- Dış katmanın yüksekliği SABİT
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: imageColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: fullImageUrl.isNotEmpty
          ? Image.network(
              fullImageUrl,
              width: 36, // <-- İçerideki resmi büyütüp/küçülteceğiniz boyut
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Resim adresi hatalıysa veya yüklenemezse varsayılan asset gösterilir
                return Image.asset(
                  'assets/icons/subjecticon.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                );
              },
            )
          : Image.asset(
              'assets/icons/subjecticon.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
    );
  }

  Widget _buildMainInfo(int progressPercent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:
          MainAxisAlignment.center, // 3 elemanı grup olarak dikeyde ortalar
      children: [
        // 1. ELEMAN: Konu başlığı
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.navSelectedBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$order',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                topicName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10284A),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 2. ELEMAN: Progress bar
        FractionallySizedBox(
          widthFactor: 0.8,
          child: Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: AppColors.unselectedGrey),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _placeholderProgress,
                            heightFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    barColor,
                                    barColor.withValues(alpha: 0.45),
                                  ],
                                  stops: const [0.1, 1.0],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '%$progressPercent',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 3. ELEMAN: Konu tamamlandı metni
        Text(
          '15/20 Konu tamamlandı',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$count Eksiğin var',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Color(0xFFEF4444),
        ),
      ),
    );
  }

  Widget _buildStatsColumn() {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (itemDataCount > 0) ...[
            _buildWarningBadge(itemDataCount),
            const SizedBox(height: 6),
          ],
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/subheading_card.svg',
              width: 12,
              height: 12,
            ),
            text: '5 Alt Başlık',
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/matter_card.svg',
              width: 12,
              height: 12,
            ),
            text: '5 Madde',
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/information_card.svg',
              width: 12,
              height: 12,
            ),
            text: '5 Bilgi Kartı',
            textColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    required String text,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child:
              iconWidget ??
              Icon(icon, size: 12, color: iconColor ?? AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.menuCardBackground,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: 13,
        color: AppColors.primaryOrange,
      ),
    );
  }
}

class SubTopicDetailPage extends StatefulWidget {
  final String topicId;
  final String topicName;
  final Function(
    Map<String, dynamic> author,
    Map<dynamic, dynamic> updatedItemData,
  )
  onStatusChanged;

  const SubTopicDetailPage({
    super.key,
    required this.topicId,
    required this.topicName,
    required this.onStatusChanged,
  });

  @override
  State<SubTopicDetailPage> createState() => _SubTopicDetailPageState();
}

class _SubTopicDetailPageState extends State<SubTopicDetailPage> {
  bool _isLoading = true;
  List<dynamic> _subTopics = [];
  late final AnalysisRepository _analysisRepository;

  @override
  void initState() {
    super.initState();
    _analysisRepository = AnalysisRepository();
    _fetchSubTopics();
  }

  Future<void> _fetchSubTopics() async {
    setState(() => _isLoading = true);

    try {
      final response = await _analysisRepository.getSubSubjectsAndItems(
        mainSubjectId: widget.topicId,
        edebiyat: "true",
        yazarEserMode: "true",
      );

      List<dynamic> mappedData = [];

      if (response != null && response['success'] == true) {
        final List<dynamic> subSubjects = response['subSubjects'] ?? [];
        final List<dynamic> itemsArray = response['itemsArray'] ?? [];

        for (int i = 0; i < subSubjects.length; i++) {
          final subSubjectItem = subSubjects[i] as Map<String, dynamic>;
          final String subSubjectId = subSubjectItem['_id']?.toString() ?? '';
          final String subSubjectName =
              subSubjectItem['name']?.toString() ?? 'Alt Başlık';

          List<dynamic> correspondingItems = [];
          if (itemsArray.length > i && itemsArray[i] is List) {
            correspondingItems = itemsArray[i];
          }

          final int itemDataCount = subSubjectItem['itemDataCount'] ?? 0;
          final List<dynamic> itemDatas = subSubjectItem['itemDatas'] ?? [];

          mappedData.add({
            "_id": subSubjectId,
            "title": subSubjectName,
            "items": correspondingItems,
            "itemDatas": itemDatas,
            "itemDataCount": itemDataCount,
          });
        }
      }
      setState(() {
        _subTopics = mappedData;
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFirstAlertCard();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Alt konular işlenirken hata oluştu: $e");
    }
  }

  void updateCategoryItems(
    int parentIndex,
    String title,
    List<dynamic> newItems,
  ) {
    setState(() {
      // Tıklanan ExpansionCard'ın index'ine ait 'items' listesini API'den gelenle güncelliyoruz
      _subTopics[parentIndex]['items'] = newItems;
      _subTopics[parentIndex]['title'] = title;
    });
  }

  void _scrollToFirstAlertCard() {
    try {
      // 1. Uyarılı olan İLK kartı buluyoruz
      final firstAlertCategory = _subTopics.firstWhere((category) {
        final List<dynamic> items = category['items'] as List<dynamic>? ?? [];
        return items.any((itemData) {
          final Map<String, dynamic> item =
              itemData as Map<String, dynamic>? ?? {};
          final Map<String, dynamic> nestedItemData =
              item['itemData'] as Map<String, dynamic>? ?? {};
          final List<dynamic> statusList =
              nestedItemData['statusArray'] as List<dynamic>? ?? [];
          return statusList.any((status) => status.toString() == "0");
        });
      }, orElse: () => null);

      if (firstAlertCategory != null) {
        // 2. ADIM: Bulunan bu kartın ana listedeki index'ini kontrol ediyoruz
        final int targetIndex = _subTopics.indexOf(firstAlertCategory);

        // Eğer uyarılı ilk kart zaten en baştaki (0. index) kart ise KAYDIRMA YAPMA!
        if (targetIndex == 0) {
          return;
        }

        // 3. ADIM: İlk sırada değilse (aşağılardaysa) güvenli bir şekilde kaydırıyoruz
        final GlobalKey? targetKey =
            firstAlertCategory['cardKey'] as GlobalKey?;
        if (targetKey != null && targetKey.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.0,
          );
        }
      }
    } catch (e) {
      debugPrint("Otomatik kaydırma sırasında hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCustomHeader(context, widget.topicName),
                Expanded(
                  child: _subTopics.isEmpty
                      ? const Center(
                          child: Text("Bu konuya ait alt başlık bulunamadı."),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: _subTopics.length,
                          itemBuilder: (context, parentIndex) {
                            final parentCategory =
                                _subTopics[parentIndex] as Map<String, dynamic>;
                            final int itemDataCount =
                                parentCategory['itemDataCount'] ?? 0;

                            final String categoryTitle =
                                parentCategory['title'] as String? ?? '';
                            final List<dynamic> items =
                                parentCategory['items'] as List<dynamic>? ?? [];
                            final GlobalKey cardKey = GlobalKey();
                            parentCategory['cardKey'] = cardKey;
                            final List<dynamic> itemDatas =
                                parentCategory['itemDatas'] as List<dynamic>? ??
                                [];

                            final Map<String, List<dynamic>> groupedItemDatas =
                                {};

                            for (final itemData in itemDatas) {
                              if (itemData is Map<String, dynamic>) {
                                final item = itemData['item'];
                                if (item is Map<String, dynamic>) {
                                  final yazar = item['yazar'];
                                  if (yazar is Map<String, dynamic>) {
                                    final String? yazarCategory =
                                        yazar['yazarCategory']?.toString();

                                    if (yazarCategory != null &&
                                        yazarCategory.isNotEmpty) {
                                      groupedItemDatas.putIfAbsent(
                                        yazarCategory,
                                        () => [],
                                      );
                                      groupedItemDatas[yazarCategory]!.add(
                                        itemData,
                                      );
                                    }
                                  }
                                }
                              }
                            }

                            // 2. Her bir item'ın _id değerine göre eşleşen gruplanmış verileri 'itemDatas' olarak atama
                            for (var i = 0; i < items.length; i++) {
                              if (items[i] is Map<String, dynamic>) {
                                final itemMap =
                                    items[i] as Map<String, dynamic>;
                                final String itemId =
                                    itemMap['_id']?.toString() ?? '';

                                // Eşleşen itemDatas dizisini alır, yoksa boş liste atar
                                itemMap['itemDatas'] =
                                    groupedItemDatas[itemId] ?? [];
                              }
                            }

                            return _MainTopicExpansionCard(
                              onStatusChanged: (author, updatedItemData) {
                                widget.onStatusChanged?.call(
                                  author,
                                  updatedItemData,
                                );
                              },
                              categoryTitle: categoryTitle,
                              items: items,
                              cardKey: cardKey,
                              itemIndex:
                                  parentIndex, // Ürettiğimiz key'i karta pasladık
                              onItemsUpdated: (title, newItems) {
                                // Alt karttan veri gelince ana sayfadaki fonksiyonu tetikliyoruz
                                updateCategoryItems(
                                  parentIndex,
                                  title,
                                  newItems,
                                );
                              },
                              itemDataCount: itemDataCount,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, String lessonName) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 24,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(1),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                lessonName,
                style: const TextStyle(
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
    );
  }
}

class _MainTopicExpansionCard extends StatefulWidget {
  final String categoryTitle;
  final List<dynamic> items;
  final GlobalKey cardKey;
  final int itemIndex;
  final Function(String title, List<dynamic> newAuthors) onItemsUpdated;
  final int itemDataCount;
  final Function(
    Map<String, dynamic> author,
    Map<dynamic, dynamic> updatedItemData,
  )
  onStatusChanged;

  const _MainTopicExpansionCard({
    super.key,
    required this.categoryTitle,
    required this.items,
    required this.cardKey,
    required this.itemIndex,
    required this.onItemsUpdated,
    required this.itemDataCount,
    required this.onStatusChanged,
  });

  @override
  State<_MainTopicExpansionCard> createState() =>
      _MainTopicExpansionCardState();
}

class _MainTopicExpansionCardState extends State<_MainTopicExpansionCard> {
  // --- HAFIZA MEKANİZMASI ---
  // Önceki başlıkları ve maddeleri sırasıyla burada saklayacağız
  final List<String> _titleHistory = [];
  final List<List<dynamic>> _itemsHistory = [];

  // O an ekranda gösterilen güncel başlık ve liste
  late String _currentTitle;
  late List<dynamic> _currentItems;
  late bool _isExpanded;
  late bool _currentTitleHasAlert = widget.itemDataCount > 0;

  bool _hasAnyAlertInCurrentItems() {
    for (final item in _currentItems) {
      if (item is Map<String, dynamic>) {
        final int missCount = _calculateSingleItemMissCount(item);
        if (missCount > 0)
          return true; // En az 1 öğrenilmemiş varsa Kırmızı yak
      }
    }
    return false; // Tümü öğrenildiyse Normal/Beyaz kal
  }

  int _calculateSingleItemMissCount(Map<String, dynamic> item) {
    int totalMissCount = 0;
    final bool itemIsYazar = item['itsYazar'] == 1;

    if (itemIsYazar) {
      final List<dynamic> works = item['works'] as List<dynamic>? ?? [];
      for (final work in works) {
        if (work is Map<String, dynamic>) {
          final itemData = work['itemData'];
          if (itemData is Map<String, dynamic>) {
            final String? status = itemData['status']?.toString();
            final statusArray = itemData['statusArray'];

            final bool isStatusZero = status == '0';
            final bool hasZeroInArray =
                statusArray is List &&
                statusArray.any((s) => s?.toString() == '0');

            if (isStatusZero || hasZeroInArray) {
              totalMissCount++;
            }
          }
        }
      }
    } else {
      final List<dynamic> itemDatas = item['itemDatas'] as List<dynamic>? ?? [];
      for (final itemData in itemDatas) {
        if (itemData is Map<String, dynamic>) {
          totalMissCount += calculateMissCountFromItemData(itemData);
        }
      }
    }
    return totalMissCount;
  }

  @override
  void initState() {
    super.initState();
    // İlk açılışta parent'tan gelen verileri içeriye eşitliyoruz
    _currentTitle = widget.categoryTitle;
    _currentItems = widget.items;
    final bool hasAnyChildAlert = widget.itemDataCount > 0;
    _isExpanded = hasAnyChildAlert || widget.itemIndex == 0;
  }

  // Eğer dışarıdaki widget (Parent) güncellenirse, hafıza boşken senkronize kalmasını sağlıyoruz
  @override
  void didUpdateWidget(covariant _MainTopicExpansionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_titleHistory.isEmpty) {
      _currentTitle = widget.categoryTitle;
      _currentItems = widget.items;
    }
  }

  // --- GERİ DÖNME FONKSİYONU ---
  void _goBack() {
    if (_titleHistory.isNotEmpty && _itemsHistory.isNotEmpty) {
      setState(() {
        // Geçmişteki son elemanları çıkartıp güncel duruma atıyoruz
        _currentTitle = _titleHistory.removeLast();
        _currentItems = _itemsHistory.removeLast();
      });

      // Ana sayfaya da (SubTopicDetailPage) eski durumumuza geri döndüğümüzü haber veriyoruz
      widget.onItemsUpdated(_currentTitle, _currentItems);
    }
  }

  int calculateMissCountFromItemData(Map<String, dynamic>? item) {
    if (item == null) return 0;

    final statusArray = item['statusArray'];
    final status = item['status'];
    final itsIndependent = item['itsIndependent'];

    // 1. Durum: statusArray geçerli ve dolu bir liste ise
    if (statusArray is List && statusArray.isNotEmpty) {
      int count = 0;
      for (var s in statusArray) {
        if (s.toString() == '0') {
          count++;
        }
      }
      return count;
    }

    // 2. Durum: Bağımsız tekli soru durumu (itsIndependent == 1 ve status == 0)
    if (itsIndependent?.toString() == '1' && status?.toString() == '0') {
      return 1;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    // Tasarım placeholder'ları — API bağlanınca güncellenecek
    const int placeholderDonem = 2;
    const int placeholderEser = 156;

    //final bool hasAnyChildAlert = _currentTitleHasAlert;

    final bool hasAlert = _hasAnyAlertInCurrentItems();
    final Color mainTitleColor = hasAlert ? Colors.red : AppColors.textPrimary;
    ;

    return Column(
      key: widget.cardKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  setState(() => _isExpanded = !_isExpanded);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Row(
                    children: [
                      if (_titleHistory.isNotEmpty) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                          ),
                          color: mainTitleColor,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(right: 8),
                          onPressed: _goBack,
                        ),
                      ],
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/icons/poetry.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, _, __) => const Icon(
                            Icons.hourglass_bottom_rounded,
                            color: AppColors.appBarBackground,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: mainTitleColor,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_currentItems.length} Sanatçı  $placeholderEser Eser  $placeholderDonem Dönem',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.menuCardBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isExpanded
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 14,
                          color: AppColors.appBarBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 10;
                final double itemWidth = (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: List.generate(_currentItems.length, (index) {
                    final Map<String, dynamic> item =
                        _currentItems[index] as Map<String, dynamic>;
                    final String itemName = item['name'] as String? ?? '';
                    final List<dynamic> descList =
                        item['desc'] as List<dynamic>? ?? [];

                    final List<dynamic> itemDatas =
                        item['itemDatas'] as List<dynamic>? ?? [];

                    int totalMissCount = 0;
                    final bool itemIsYazar = item['itsYazar'] == 1;

                    // yazarsa work'lere bak.
                    if (itemIsYazar) {
                      final List<dynamic> works =
                          item['works'] as List<dynamic>? ?? [];
                      for (final work in works) {
                        if (work is Map<String, dynamic>) {
                          final itemData = work['itemData'];

                          if (itemData is Map<String, dynamic>) {
                            // status == 0 veya '0' kontrolü
                            final bool isStatusZero =
                                itemData['status']?.toString() == '0';

                            // statusArray içinde 0 veya '0' var mı kontrolü
                            final statusArray = itemData['statusArray'];
                            final bool hasZeroInArray =
                                statusArray is List &&
                                statusArray.any((s) => s?.toString() == '0');

                            // İki durumdan biri geçerliyse +1 ekle
                            if (isStatusZero || hasZeroInArray) {
                              totalMissCount++;
                            }
                          }
                        }
                      }
                    } else {
                      for (final itemData in itemDatas) {
                        if (itemData is Map<String, dynamic>) {
                          totalMissCount += calculateMissCountFromItemData(
                            itemData,
                          );
                        }
                      }
                    }

                    final Map<String, dynamic> nestedItemData =
                        item['itemData'] as Map<String, dynamic>? ?? {};
                    final List<dynamic> promptsList =
                        nestedItemData['prompts'] as List<dynamic>? ?? [];
                    final List<dynamic> statusList =
                        nestedItemData['statusArray'] as List<dynamic>? ?? [];
                    final int itsIndependent =
                        nestedItemData['itsIndependent'] ?? 0;
                    final String image = item['image'] ?? '';

                    return SizedBox(
                      width: itemWidth,
                      child: AuthorCard(
                        author: item,
                        itemName: itemName,
                        descList: descList,
                        prompts: promptsList,
                        statusArray: statusList,
                        mainCategoryTitle: _currentTitle,
                        itsIndependent: itsIndependent,
                        image: image,
                        repository: AnalysisRepository(),
                        onSuccessData: (newTitle, mappedData) {
                          setState(() {
                            _titleHistory.add(_currentTitle);
                            _itemsHistory.add(_currentItems);
                            _currentTitle = newTitle;
                            _currentItems = mappedData;
                            _isExpanded = true;
                            _currentTitleHasAlert =
                                !itemIsYazar && totalMissCount > 0;
                          });
                          widget.onItemsUpdated(newTitle, mappedData);
                        },
                        totalMissCount: totalMissCount,
                        onStatusChanged: (author, updatedItemData) {
                          setState(() {}); // Tüm ana ekranı / renkleri yenile

                          // 1. Eserin bağlı olduğu yazar ID'sini al
                          final String? yazarCategoryId =
                              author['yazarCategory']?.toString();
                          final String? authorId = author['_id']?.toString();

                          if (yazarCategoryId != null &&
                              yazarCategoryId.isNotEmpty) {
                            Map<String, dynamic>? donem;

                            // 2. _itemsHistory (List<List<dynamic>>) içinde arama yap
                            for (final List<dynamic> itemList
                                in _itemsHistory) {
                              for (final item in itemList) {
                                if (item is Map<String, dynamic>) {
                                  final String? itemId = item['_id']
                                      ?.toString();

                                  if (itemId == yazarCategoryId) {
                                    donem = item;
                                    break; // İç döngüden çık
                                  }
                                }
                              }
                              if (donem != null) break; // Dış döngüden çık
                            }

                            // 3. Eşleşen dönem bulunduysa, altındaki itemDatas içerisinde güncellenecek olanı bul
                            if (donem != null) {
                              final List<dynamic> itemDatas =
                                  donem['itemDatas'] as List<dynamic>? ?? [];
                              final String? updatedItemId =
                                  updatedItemData['_id']?.toString();

                              if (updatedItemId != null) {
                                bool isUpdated = false;

                                for (final targetItem in itemDatas) {
                                  if (targetItem is Map<String, dynamic>) {
                                    final String? targetId = targetItem['_id']
                                        ?.toString();

                                    if (targetId == updatedItemId) {
                                      // Status ve StatusArray güncellemesi
                                      targetItem['status'] = 1;
                                      targetItem['statusArray'] = [1];
                                      isUpdated = true;
                                      break; // status 1 setlendi
                                    }
                                  }
                                }
                              }
                            }
                          }
                          widget.onStatusChanged?.call(author, updatedItemData);
                        },
                      ),
                    );
                  }),
                );
              },
            ),
          ),
      ],
    );
  }
}

void _handleDetailTap(
  BuildContext context,
  Map<String, dynamic> author,
  Function(Map<String, dynamic> author, Map<dynamic, dynamic> updatedItemData)?
  onStatusChanged,
) {
  final analysisRepository = AnalysisRepository();
  bool isCardFavorite = author['isFavorite'] as bool? ?? false;

  final List<dynamic> descList = author['desc'] as List<dynamic>? ?? [];
  final String biography = descList.join('\n\n');

  final List<dynamic> worksList = author['works'] as List<dynamic>? ?? [];
  final String authorImage = author['image'] as String? ?? '';
  final String authorName = author['name']?.toString() ?? 'Bilinmeyen Yazar';

  final Map<String, List<Map<String, dynamic>>> worksByType = {};
  for (final workData in worksList) {
    final work = Map<String, dynamic>.from(workData as Map);
    final String typeId = (work['type'] ?? '').toString();
    final String typeName = EserTypeHelper.types[typeId] ?? 'Diğer';
    worksByType.putIfAbsent(typeName, () => []).add(work);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setPopupState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: AppColors.menuCardBackground,
                              shape: BoxShape.circle,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: authorImage.isNotEmpty
                                  ? Image.asset(
                                      'assets$authorImage',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.person_rounded,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authorName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.appBarBackground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setPopupState(() {
                                isCardFavorite = !isCardFavorite;
                              });
                            },
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                size: 32,
                                color: isCardFavorite
                                    ? AppColors.primaryOrange
                                    : AppColors.navUnselected,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.unselectedGrey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hakkında',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.appBarBackground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              biography.isNotEmpty
                                  ? biography
                                  : 'Açıklama bulunamadı.',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: AppColors.textSecondary,
                              ).copyWith(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (worksByType.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Kayıtlı eser bulunamadı.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        ...worksByType.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AuthorWorkTypeCard(
                              author: author,
                              typeName: entry.key,
                              works: entry.value,
                              repository: analysisRepository,
                              onStatusChanged: (author, updatedItemData) {
                                // Parametreyi aldık
                                setPopupState(() {}); // Popup içini yenile

                                // AuthorCard'ın onStatusChanged'ına ilet
                                onStatusChanged?.call(author, updatedItemData);
                              },
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _AuthorWorkTypeCard extends StatefulWidget {
  final Map<String, dynamic> author;
  final String typeName;
  final List<Map<String, dynamic>> works;
  final AnalysisRepository repository; // <-- Ekledik
  final Function(
    Map<String, dynamic> author,
    Map<dynamic, dynamic> updatedItemData,
  )?
  onStatusChanged;
  const _AuthorWorkTypeCard({
    required this.author,
    required this.typeName,
    required this.works,
    required this.repository,
    this.onStatusChanged, // <-- 'required' kaldırıldı
  });

  @override
  State<_AuthorWorkTypeCard> createState() => _AuthorWorkTypeCardState();
}

class _AuthorWorkTypeCardState extends State<_AuthorWorkTypeCard> {
  Color get _accentColor {
    final styles = EserTypeHelper.workTypeStyles[widget.typeName];
    return styles?['text'] ?? AppColors.appBarBackground;
  }

  Color get _badgeBg {
    final styles = EserTypeHelper.workTypeStyles[widget.typeName];
    return styles?['bg'] ?? AppColors.menuCardBackground;
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllLearned =
        widget.works.isNotEmpty &&
        widget.works.every((work) {
          final itemData = work['itemData'];
          if (itemData != null && itemData is Map) {
            final raw = itemData['status']?.toString();
            return raw == '1' || raw == 'true';
          }
          return false;
        });

    final Color titleColor = isAllLearned ? AppColors.textPrimary : Colors.red;
    return Container(
      decoration: BoxDecoration(
        color: _accentColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/icons/poetry.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.menu_book_rounded,
                          color: _accentColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.typeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.appBarBackground,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${widget.works.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const double spacing = 12;
                    final double itemWidth =
                        (constraints.maxWidth - spacing) / 2;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 10,
                      children: widget.works.map((work) {
                        return SizedBox(
                          width: itemWidth,
                          child: _WorkListItem(
                            author: widget.author,
                            work: work,
                            repository: widget.repository,
                            onStatusChanged: (author, updatedItemData) {
                              // 1. Parametreyi alıyoruz
                              setState(() {}); // Kendi tür kartını yenile

                              if (widget.onStatusChanged != null) {
                                widget.onStatusChanged!(
                                  author,
                                  updatedItemData,
                                ); // 2. Aynen bir üstteki Dialog ve AuthorCard'a ilet
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkListItem extends StatefulWidget {
  final Map<String, dynamic> author;
  final Map<String, dynamic> work;
  final AnalysisRepository repository;
  final Function(
    Map<String, dynamic> author,
    Map<dynamic, dynamic> updatedItemData,
  )?
  onStatusChanged;
  const _WorkListItem({
    super.key, // <-- 'super.key' eklemek Flutter standartıdır
    required this.author,
    required this.work,
    required this.repository,
    this.onStatusChanged, // <-- 'required' kaldırıldı
  });

  @override
  State<_WorkListItem> createState() => _WorkListItemState();
}

class _WorkListItemState extends State<_WorkListItem> {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _bubbleEntry;
  bool _isLearned = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() {
    // 1. work['itemData'] var mı ve Map formatında mı kontrol et
    final itemData = widget.work['itemData'];

    if (itemData != null && itemData is Map) {
      final raw = itemData['status']?.toString();
      _isLearned = raw == '1' || raw == 'true';

      if (raw == null || raw.isEmpty) {
        itemData['status'] = '0';
      }
    } else {
      _isLearned = false;
    }
  }

  @override
  void dispose() {
    _removeBubble();
    super.dispose();
  }

  void _removeBubble() {
    _bubbleEntry?.remove();
    _bubbleEntry = null;
  }

  void _showILearnedBubble() {
    _removeBubble();
    final overlay = Overlay.maybeOf(context);
    final box = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlay == null || box == null || !box.hasSize) return;

    final offset = box.localToGlobal(Offset.zero);
    const double bubbleWidth = 110;
    final double left = (offset.dx + box.size.width / 2 - bubbleWidth / 2)
        .clamp(8.0, MediaQuery.of(context).size.width - bubbleWidth - 8);

    _bubbleEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: left,
          top: offset.dy - 42,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: bubbleWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Öğrendim',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(14, 8),
                  painter: _BubbleTailPainter(color: const Color(0xFF22C55E)),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(_bubbleEntry!);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _removeBubble();
    });
  }

  Future<void> _onStatusTap() async {
    // 1. Zaten yeşilse (öğrenildiyse) hiçbir işlem yapma
    if (_isLearned) return;

    final itemData = widget.work['itemData'];

    if (itemData != null && itemData is Map) {
      final String? itemId = itemData['_id']?.toString();

      // ID yoksa istek atma
      if (itemId == null || itemId.isEmpty) return;

      // 2. Durumu lokalde yeşil yap ve arayüzü güncelle
      setState(() {
        _isLearned = true;
        itemData['status'] = '1';
      });

      // Dışarıdaki üst widget'a (özet kartlarına) durumun değiştiğini haber ver
      widget.onStatusChanged!(widget.author, itemData);

      // "Öğrendim" baloncuğunu göster
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showILearnedBubble();
      });

      // 3. Provider üzerinden Repository'ye erişip isteği at
      try {
        await widget.repository.learnedItem(itemId);
        // --- LOKAL VERİYİ GÜNCELLE ---
        if (widget.work['itemData'] == null) {
          widget.work['itemData'] = <String, dynamic>{};
        }
        (widget.work['itemData'] as Map<String, dynamic>)['status'] = 1;
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.work['eser']?.toString() ?? '';
    final hasItemData = widget.work['itemData'] != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.appBarBackground,
            height: 1.3,
          ),
        ),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.appBarBackground,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: hasItemData ? _onStatusTap : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: hasItemData
                ? _StatusSquare(key: _iconKey, status: _isLearned ? '1' : '0')
                : Icon(
                    Icons.help_outline_rounded,
                    key: _iconKey,
                    size: 18,
                    color: Colors.grey,
                  ),
          ),
        ),
      ],
    );
  }
}

class _StatusSquare extends StatelessWidget {
  final String status;

  const _StatusSquare({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isLearned = status == '1';

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: isLearned ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        isLearned ? Icons.check_rounded : Icons.close_rounded,
        size: 12,
        color: AppColors.white,
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color color;

  _BubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// 1. Burayı StatefulWidget yaptık
class AuthorCard extends StatefulWidget {
  final Map<String, dynamic> author;
  final String itemName;
  final List<dynamic> descList;
  final List<dynamic> prompts;
  final List<dynamic> statusArray;
  final String mainCategoryTitle;
  final int itsIndependent;
  final String image;
  final AnalysisRepository repository;
  final Function(String title, List<dynamic> newData) onSuccessData;
  final int totalMissCount;
  final Function(
    Map<String, dynamic> author,
    Map<dynamic, dynamic> updatedItemData,
  )?
  onStatusChanged;

  const AuthorCard({
    super.key,
    required this.author,
    required this.itemName,
    required this.descList,
    required this.prompts,
    required this.statusArray,
    required this.mainCategoryTitle,
    required this.itsIndependent,
    required this.image,
    required this.repository,
    required this.onSuccessData, // Constructor'a ekledik
    required this.totalMissCount,
    this.onStatusChanged,
  });

  @override
  State<AuthorCard> createState() => _AuthorCardState();
}

class _AuthorCardState extends State<AuthorCard> {
  // Durum değişkenlerini durum sınıfının içine taşıdık
  List<dynamic> _subTopics = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final String fullDescription = widget.descList.join(' ');
    final bool hasAnyAlert = widget.totalMissCount > 0;

    final Color titleColor = hasAnyAlert
        ? Colors.red
        : AppColors.appBarBackground;

    final List<dynamic> worksList =
        widget.author['works'] as List<dynamic>? ?? [];
    final int metricCount = worksList.isNotEmpty
        ? worksList.length
        : (widget.prompts.isNotEmpty ? widget.prompts.length : 20);

    return InkWell(
      onTap: () async {
        if (widget.author['yazarCategory'] != null) {
          _handleDetailTap(context, widget.author, widget.onStatusChanged);
        } else {
          setState(() {
            _isLoading = true;
          });

          final response = await widget.repository.getSubjectAuthors(
            widget.author['_id'],
          );

          if (response != null && response['success'] == true) {
            final String subTitle = widget.author['name'] ?? '';
            final List<dynamic> authors = response['authors'] ?? [];
            widget.onSuccessData(subTitle, authors);
          }

          setState(() {
            _isLoading = false;
          });
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _isLoading
                    ? const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.menuCardBackground,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets${widget.image}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person_rounded,
                                size: 28,
                                color: hasAnyAlert
                                    ? Colors.red
                                    : AppColors.textSecondary,
                              );
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.layers_rounded,
                      size: 14,
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$metricCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fullDescription.isEmpty
                        ? 'Açıklama bulunamadı.'
                        : fullDescription,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
