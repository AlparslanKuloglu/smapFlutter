import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studentmap/domain/models/general_lessons.dart';
import 'package:studentmap/core/constants/lesson_constants.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/repository/analysis_repository.dart';
import 'package:studentmap/features/analytics/presentation/screens/subject_detail_page.dart';

class LessonDetailPage extends StatefulWidget {
  /// Sayfa başlığında görünmesi için dersin adını alıyoruz.
  final GeneralLesson lesson;
  final String examType;
  final int defaultFilterValue;
  final String lessonFullName;

  const LessonDetailPage({
    super.key,
    required this.lesson,
    required this.examType,
    required this.defaultFilterValue,
    required this.lessonFullName,
  });

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  bool _isLoading = true;
  List<dynamic> filterObjs = [];
  int? _selectedFilterValue;

  // API artık Liste döndürdüğü için veri tipini List<dynamic> yapıyoruz
  List<dynamic>? _topicsData;
  Map<String, dynamic>? _resultByType;
  // Repository instance'ını tanımlıyoruz
  late final AnalysisRepository _analysisRepository;

  @override
  void initState() {
    super.initState();
    _analysisRepository = AnalysisRepository();
    _selectedFilterValue = widget.defaultFilterValue;
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
        } else if (widget.examType == "SOS2") {
          dataLessonId = selectedLesson['lessonSos2'];
        } else {
          dataLessonId = selectedLesson['lessonId'];
        }

        // 3. GERÇEK REPOSITORY ÇAĞRISI
        final response = await _analysisRepository.getMainSubjects(
          lessonId: dataLessonId.toString(),
        );

        final lesson = response['lesson'];
        final lessonType = lesson['type'];

        if (response != null && response['filterObjs'] != null) {
          final list = response['filterObjs'] as List<dynamic>;
          // Listenin en başına Tümü seçeneğini ekliyoruz
          list.insert(0, {'name': 'Tümü', 'value': 9, 'filter': {}});
          setState(() {
            filterObjs = list;
          });
        }

        setState(() {
          _topicsData = response['subjects'] as List<dynamic>? ?? [];
          // resultByType atamasını güvenli şekilde Map<String, dynamic> olarak alıyoruz
          if (response['resultByType'] != null) {
            _resultByType = Map<String, dynamic>.from(
              response['resultByType'] as Map,
            );
          } else {
            _resultByType = {};
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _topicsData = [];
          _resultByType = {};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _topicsData = null;
      });
      debugPrint("Repository verisi çekilirken hata oluştu: $e");
    }
  }

  int getMissingCountForTab(dynamic tabValue) {
    // 1. Sınıf değişkenini yerel bir değişkene atıyoruz (Local variable promotion alır)
    final resultByType = _resultByType;

    // 2. Null kontrolünü yerel değişken üzerinden yapıyoruz
    if (resultByType == null || resultByType.isEmpty) return 0;

    int total = 0;

    // Durum 1: "Tümü" seçilmişse (value == 9)
    if (tabValue == 9 || tabValue == '9') {
      resultByType.forEach((key, subjectMap) {
        if (subjectMap is Map) {
          subjectMap.forEach((subjectId, count) {
            total += (count as num? ?? 0).toInt();
          });
        }
      });
      return total;
    }

    // Durum 2: Belirli bir tab seçilmişse (value == 1, 3, 4 vb.)
    final keyStr = tabValue.toString();
    final subjectMap = resultByType[keyStr];

    if (subjectMap is Map) {
      subjectMap.forEach((subjectId, count) {
        total += (count as num? ?? 0).toInt();
      });
    }

    return total;
  }

  // ===========================================================================
  // ARAYÜZ (BUILD) KISMI
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCustomHeader(
                  context,
                  lessonName: widget.lessonFullName,
                  missingCount: getMissingCountForTab(_selectedFilterValue),
                  showOnlyMissing: false, // Geçici aktiflik durumu
                  onMissingToggle: () {},
                ),
                Expanded(
                  child: _topicsData == null || _topicsData!.isEmpty
                      ? const Center(child: Text("Konu verisi bulunamadı."))
                      : _buildMainContent(),
                ),
              ],
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
    const double badgeSize = 24.0;
    const double badgeOverlap = 8.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // =========================
        // HEADER
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
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              // Geri
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              // Ders adı
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

              // Eksikler
              GestureDetector(
                onTap: onMissingToggle,
                behavior: HitTestBehavior.opaque,
                child: _MissingCountBadge(
                  count: missingCount,
                  active: showOnlyMissing,
                ),
              ),
            ],
          ),
        ),

        // =========================
        // TAB ALANI
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
                      children: filterObjs.map((item) {
                        final String name = item['name'] ?? '';
                        final dynamic value = item['value'] ?? 0;
                        final bool isSelected = _selectedFilterValue == value;

                        return Expanded(
                          child: _buildSegmentButton(
                            label: name,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedFilterValue = value;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // BADGE KATMANI
                Positioned.fill(
                  child: IgnorePointer(
                    child: Row(
                      children: filterObjs.map((item) {
                        final dynamic value = item['value'] ?? 0;
                        final int count = getMissingCountForTab(value);

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
                                    selected: _selectedFilterValue == value,
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
    return ListView.builder(
      // Kart rozetleri sağ üst köşeden taştığı için kenar boşlukları geniş tutuldu
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
      itemCount: _topicsData!.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> topic =
            _topicsData![index] as Map<String, dynamic>;

        // API'den gelen verileri okuyoruz
        final String currentTopicId = topic['_id'] as String? ?? '';
        final String currentTopicName =
            topic['name'] as String? ?? 'Bilinmeyen Konu';
        final int order = (topic['order'] as num? ?? 0).toInt();

        final dynamic tabData =
            _resultByType?[_selectedFilterValue] ??
            _resultByType?[_selectedFilterValue.toString()];

        final int itemDataCount =
            (tabData is Map ? tabData[currentTopicId] as num? ?? 0 : 0).toInt();

        final String subjectImage = topic['image']?.toString() ?? '';
        final Color imageColor = AppColors.hexToColor(
          topic['imageColor']?.toString() ?? '#FFFFFF',
        );
        final Color barColor = AppColors.hexToColor(
          topic['barColor']?.toString() ?? '#FFFFFF',
        );

        return _LessonsTopicCard(
          topicId: currentTopicId,
          topicName: currentTopicName,
          order: order,
          itemDataCount: itemDataCount,
          subjectImage: subjectImage,
          barColor: barColor,
          imageColor: imageColor,
          onTap: () {
            // Tıklandığında alt konu detay sayfasına yönlendiriyoruz
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubTopicDetailPage(
                  topicId: currentTopicId,
                  topicName: currentTopicName,
                  tabFilterValue: _selectedFilterValue ?? 9,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ===========================================================================
// EKSİK BİLGİ KARTI ROZETİ (Header + Konu kartları)
// ===========================================================================

class _MissingCountBadge extends StatelessWidget {
  final int count;
  final bool active;
  final bool compact;

  const _MissingCountBadge({
    required this.count,
    this.active = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 7, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 7 : 8),
        border: Border.all(
          color: active ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5),
          width: active ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/information_card_with_border_red.svg',
            width: compact ? 14 : 18,
            height: compact ? 14 : 18,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            '$count',
            style: TextStyle(
              color: const Color(0xFFEF4444),
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
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
  final VoidCallback onTap; // Tıklama aksiyonunu dışarıdan alacağız
  final String subjectImage;
  final Color barColor;
  final Color imageColor;

  static const String _imageBaseUrl = 'https://smaptr.com/subjectIcons/';

  static const double _placeholderProgress = 0.75;
  static const int _placeholderCompleted = 15;
  static const int _placeholderTotal = 20;
  static const int _placeholderSubTopics = 4;
  static const int _placeholderItems = 26;
  static const int _placeholderCards = 8;

  const _LessonsTopicCard({
    required this.topicId,
    required this.topicName,
    required this.order,
    required this.itemDataCount,
    required this.onTap, // Constructor'a ekledik
    required this.subjectImage,
    required this.barColor,
    required this.imageColor,
  });

  @override
  Widget build(BuildContext context) {
    // Rozet kartın üstünden taştığı için üst boşluk daha geniş
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildCardBody(),
          // Sağ üst köşeye merkezlenmiş, dışarı taşan eksik rozeti
          if (itemDataCount > 0)
            Positioned(
              top: 10,
              right: 20,
              child: FractionalTranslation(
                translation: const Offset(0.5, -0.5),
                child: IgnorePointer(
                  child: _MissingCountBadge(
                    count: itemDataCount,
                    compact: true,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardBody() {
    return Container(
      height: 100,
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
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. SOL: Thumbnail
                  Align(
                    alignment: Alignment.center,
                    child: _buildThumbnail(subjectImage, imageColor),
                  ),
                  const SizedBox(width: 10),

                  // 2. ORTA: Üstte Tam Genişlikte Başlık, Altta (İlerleme + İstatistikler)
                  // 2. ORTA: Üstte Başlık, Ortada İlerleme, En Altta Yan Yana İstatistikler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ÜST: Başlık (En fazla 2 satır)
                        _buildTopicHeader(),
                        // ORTA: İlerleme Çubuğu ve Tamamlanan Konu
                        _buildProgressSection(),
                        // ALT: 3 İstatistik Yan Yana
                        _buildHorizontalStatsRow(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 2),
                  Align(
                    alignment: Alignment.center,
                    child: _buildArrowButton(),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Başlık alanı (2 satıra inebilir)
  Widget _buildTopicHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
      ), // İhtiyacınıza göre 4, 6 veya istediğiniz değeri verebilirsiniz
      child: Row(
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
                color: Color(0xFF10284A),
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // En altta yan yana duran 3 istatistik öğesi
  Widget _buildHorizontalStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Sola yasla
      children: [
        _buildStatItem(
          iconWidget: SvgPicture.asset(
            'assets/icons/subheading_card.svg',
            width: 10,
            height: 10,
          ),
          text: '$_placeholderSubTopics Alt Başlık',
          textColor: AppColors.textSecondary,
        ),
        const SizedBox(width: 12), // Öğeler arası kontrollü boşluk
        _buildStatItem(
          iconWidget: SvgPicture.asset(
            'assets/icons/matter_card.svg',
            width: 10,
            height: 10,
          ),
          text: '$_placeholderItems Madde',
          textColor: AppColors.textSecondary,
        ),
        const SizedBox(width: 12), // Öğeler arası kontrollü boşluk
        _buildStatItem(
          iconWidget: SvgPicture.asset(
            'assets/icons/information_card.svg',
            width: 10,
            height: 10,
          ),
          text: '$_placeholderCards Bilgi Kartı',
          textColor: AppColors.textPrimary,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required Widget iconWidget,
    required String text,
    required Color textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final int progressPercent = (_placeholderProgress * 100).round();

    return Row(
      children: [
        // Progress bar'ın kaplayacağı alanı SizedBox veya FractionallySizedBox ile daraltıyoruz
        SizedBox(
          width:
              140, // Dilediğiniz gibi küçültebilir veya büyütebilirsiniz (Örn: 120, 140 vb.)
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 7,
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
        const SizedBox(width: 6),
        Text(
          '%$progressPercent',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($_placeholderCompleted/$_placeholderTotal)',
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // İlerleme çubuğu ve tamamlanan konu metni alt alta yer alır
  Widget _buildProgressAndStatsInfo() {
    final int progressPercent = (_placeholderProgress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 6,
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
        const SizedBox(height: 3),
        // Konu tamamlandı metni
        Text(
          '$_placeholderCompleted/$_placeholderTotal Konu tamamlandı',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  topicName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10284A),
                    height: 1.2,
                  ),
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
          '$_placeholderCompleted/$_placeholderTotal Konu tamamlandı',
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
            text: '$_placeholderSubTopics Alt Başlık',
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/matter_card.svg',
              width: 12,
              height: 12,
            ),
            text: '$_placeholderItems Madde',
            textColor: AppColors.textSecondary,
          ),
          const SizedBox(height: 3),
          _buildStatRow(
            iconWidget: SvgPicture.asset(
              'assets/icons/information_card.svg',
              width: 12,
              height: 12,
            ),
            text: '$_placeholderCards Bilgi Kartı',
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
