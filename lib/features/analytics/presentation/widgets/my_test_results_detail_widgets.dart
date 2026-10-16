import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentmap/features/analytics/presentation/screens/question_detail_page.dart';
import 'package:studentmap/repository/analysis_repository.dart';

/// `OmdResultFlowView._buildStepOne` içindeki kapak (200x150 + shadow + Image.network).
class MyTestResultsDetailOmdExamCover extends StatelessWidget {
  final String fullUrl;

  const MyTestResultsDetailOmdExamCover({super.key, required this.fullUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child:
            (fullUrl.isNotEmpty &&
                (fullUrl.startsWith('http://') ||
                    fullUrl.startsWith('https://')))
            ? Image.network(
                fullUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
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
    );
  }
}

/// `OmdResultFlowView._buildMainStatBox`.
class MyTestResultsDetailOmdMainStatBox extends StatelessWidget {
  final String title;
  final String count;
  final Color countColor;

  const MyTestResultsDetailOmdMainStatBox({
    super.key,
    required this.title,
    required this.count,
    required this.countColor,
  });

  @override
  Widget build(BuildContext context) {
    const Color kLightBg = Color(0xFFF9FAFB);

    return Container(
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
    );
  }
}

/// `OmdResultFlowView._buildStepOne` içindeki TYT bilgi bandı.
class MyTestResultsDetailOmdTytInfoBanner extends StatelessWidget {
  const MyTestResultsDetailOmdTytInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kBannerBg = Color(0xFFFDE8D7);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBannerBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '*TYT puanınız son çözdüğünüz denemeye göre hesaplanmıştır. OBP notunuz 85 olarak alınmıştır.',
        style: TextStyle(fontSize: 12, color: Color(0xFF374151), height: 1.4),
      ),
    );
  }
}

/// `OmdResultFlowView._buildStepOne` içindeki Deneme Sonucu / Sıralama anahtarı.
class MyTestResultsDetailOmdRankingModeToggle extends StatelessWidget {
  final bool isRanking;
  final Color selectedColor;
  final ValueChanged<bool> onChanged;

  const MyTestResultsDetailOmdRankingModeToggle({
    super.key,
    required this.isRanking,
    required this.selectedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isRanking ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Deneme Sonucu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !isRanking ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isRanking ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Sıralama',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isRanking ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `OmdResultFlowView._buildRankingContent` üstündeki "Eşit Ağırlık / Sayısal / Sözel" satırı.
class MyTestResultsDetailOmdScoreTypeTabsRow extends StatelessWidget {
  final Color activeColor;

  const MyTestResultsDetailOmdScoreTypeTabsRow({
    super.key,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _OmdScoreTypeSubTab(
            title: 'Eşit Ağırlık',
            isActive: true,
            activeColor: activeColor,
          ),
          _OmdScoreTypeSubTab(
            title: 'Sayısal',
            isActive: false,
            activeColor: activeColor,
          ),
          _OmdScoreTypeSubTab(
            title: 'Sözel',
            isActive: false,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }
}

/// `OmdResultFlowView._buildSubTab`.
class _OmdScoreTypeSubTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final Color activeColor;

  const _OmdScoreTypeSubTab({
    required this.title,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? activeColor : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? activeColor : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// `OmdResultFlowView._buildScoreCard`.
class MyTestResultsDetailOmdScoreCard extends StatelessWidget {
  final String title;
  final String score;
  final String rank;
  final String rankTitle;
  final Color valueColor;

  const MyTestResultsDetailOmdScoreCard({
    super.key,
    required this.title,
    required this.score,
    required this.rank,
    required this.rankTitle,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
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
            'Ana Değer',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
          Text(
            score,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
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
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// `OmdResultFlowView._buildSubjectCard`.
class MyTestResultsDetailOmdSubjectCard extends StatelessWidget {
  final String img;
  final String title;
  final int d;
  final int y;
  final int b;

  const MyTestResultsDetailOmdSubjectCard({
    super.key,
    required this.img,
    required this.title,
    required this.d,
    required this.y,
    required this.b,
  });

  @override
  Widget build(BuildContext context) {
    const Color kLightBg = Color(0xFFF9FAFB);
    const Color kGreen = Color(0xFF4CAF50);
    const Color kRed = Color(0xFFF44336);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kLightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(img, width: 26, height: 26, fit: BoxFit.contain),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OmdSubStat(label: 'Doğru', val: d.toString(), color: kGreen),
              _OmdSubStat(label: 'Yanlış', val: y.toString(), color: kRed),
              _OmdSubStat(label: 'Boş', val: b.toString(), color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}

/// Header altındaki Genel / Sorular / Konu Analizi sekme butonu.
class MyTestResultsDetailTopTabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? tabCount;

  const MyTestResultsDetailTopTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.tabCount,
  });

  @override
  Widget build(BuildContext context) {
    // Sayı var mı ve 0'dan büyük mü kontrolü
    final bool showBadge = tabCount != null;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kaplaması için
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFFF8A00)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              if (showBadge) ...[
                const SizedBox(width: 6), // Metin ile badge arası boşluk
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    // Seçiliyken turuncu temaya uygun hafif opak bir arka plan veya tam tersi
                    color: isSelected
                        ? const Color(0xFFFF8A00).withOpacity(0.15)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tabCount.toString(),
                    style: TextStyle(
                      fontSize:
                          10, // Badge içindeki sayı biraz daha küçük olmalı
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFFFF8A00)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// "Sorular" ve "Konu Analizi" sekmeleri için placeholder içerik.
class MyTestResultsDetailTabPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const MyTestResultsDetailTabPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF64748B)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

/// `OmdResultFlowView._subStat`.
class _OmdSubStat extends StatelessWidget {
  final String label;
  final String val;
  final Color color;

  const _OmdSubStat({
    required this.label,
    required this.val,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}

class MyTestResultsDetailQuestionsTabContent extends StatelessWidget {
  final dynamic mexam;
  final AnalysisRepository analysisRepository;

  const MyTestResultsDetailQuestionsTabContent({
    super.key,
    required this.mexam,
    required this.analysisRepository, // 2. Zorunlu yaptık
  });

  @override
  Widget build(BuildContext context) {
    final List<String> subjects = mexam['type'] == 1
        ? ['Türkçe', 'Sosyal Bilimler', 'Matematik', 'Fen Bilimleri']
        : [
            'Sosyal Bilimler',
            'Sosyal Bilimler - 2',
            'Matematik',
            'Fen Bilimleri',
          ];

    final List<dynamic> allQuestions = jsonDecode(
      mexam['questionsArrStr'] ?? '[]',
    );

    return ColoredBox(
      color: const Color(0xFFF3F4F6),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: subjects.length,
        itemBuilder: (context, subjectIndex) {
          final String subjectName = subjects[subjectIndex];
          final List<dynamic> subjectQuestions =
              (allQuestions.length > subjectIndex)
              ? allQuestions[subjectIndex]
              : [];

          // Doğru, Yanlış ve Boş sayılarını hesapla
          int correctCount = 0;
          int wrongCount = 0;
          int emptyCount = 0;
          int netRate = 0;

          for (var q in subjectQuestions) {
            if (q['type'] == 1)
              correctCount++;
            else if (q['type'] == 3)
              wrongCount++;
            else
              emptyCount++;
          }

          return Theme(
            // ExpansionTile'ın varsayılan divider'larını kaldırmak için
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: subjectIndex == 0, // İlk ders açık gelsin
              title: Text(
                subjectName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              // Sağ taraftaki özet göstergeleri
              trailing: Wrap(
                spacing: 8,
                children: [
                  _buildSummaryBadge(
                    correctCount,
                    const Color(0xFF10B981),
                  ), // Doğru
                  _buildSummaryBadge(
                    wrongCount,
                    const Color(0xFFEF4444),
                  ), // Yanlış
                  _buildSummaryBadge(
                    emptyCount,
                    const Color(0xFF94A3B8),
                  ), // Boş
                  const Icon(Icons.expand_more, color: Color(0xFF64748B)),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: subjectQuestions.isEmpty
                      ? const Text(
                          "Soru verisi bulunamadı.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 85,
                              ),
                          itemCount: subjectQuestions.length,
                          itemBuilder: (context, qIndex) {
                            final question = subjectQuestions[qIndex];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuestionDetailsPage(
                                      question: question,
                                      subjectIndex: subjectIndex,
                                      subjectName: subjectName,
                                      mexam: mexam,
                                      analysisRepository:
                                          analysisRepository, // 3. Alttaki sayfaya pasladık!
                                    ),
                                  ),
                                );
                              },
                              child: _QuestionAnswerMiniCard(
                                questionNumber:
                                    question['order'] ?? (qIndex + 1),
                                statusType: question['type'] ?? 2,
                              ),
                            );
                          },
                        ),
                ),
                const Divider(
                  color: Color(0xFFE2E8F0),
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Özet sayıları için küçük yuvarlak göstergeler
  Widget _buildSummaryBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _QuestionAnswerMiniCard extends StatelessWidget {
  final int questionNumber;
  final int statusType;

  const _QuestionAnswerMiniCard({
    required this.questionNumber,
    required this.statusType,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (statusType) {
      case 1:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_rounded;
        break;
      case 3:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.close_rounded;
        break;
      case 2:
      default:
        statusColor = const Color(0xFF94A3B8);
        statusIcon = Icons.question_mark_rounded;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (statusType == 1)
            Icon(statusIcon, size: 20, color: statusColor)
          else
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, size: 12, color: statusColor),
            ),
          const SizedBox(height: 4),
          Text(
            questionNumber.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'A',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

class MyTestResultsDetailTopicAnalysisTabContent extends StatelessWidget {
  /// Node.js API'sinden dönen `res.json({ success: true, data: sortedResult })`
  /// içerisindeki `data` objesini buraya parametre olarak geçmelisiniz.
  final Map<String, dynamic> backendData;
  final Map<String, dynamic> mexam;

  const MyTestResultsDetailTopicAnalysisTabContent({
    super.key,
    required this.backendData,
    required this.mexam,
  });

  @override
  Widget build(BuildContext context) {
    // Backend'den gelen sıralı ders adlarını ("Türkçe", "Tarih" vb.) listeye çeviriyoruz
    final dataJson = backendData['data'];
    final List<String> lessonNames = dataJson.keys.toList();
    final lessonMockExams = mexam['lessonmockexams'];
    // Eğer gelen veri boşsa kullanıcıya bilgi mesajı gösteriyoruz
    if (lessonNames.isEmpty) {
      return const Center(
        child: Text(
          "Analiz edilecek ders verisi bulunamadı.",
          style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
        ),
      );
    }

    return ColoredBox(
      color: const Color(0xFFF3F4F6),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: lessonNames.length,
        itemBuilder: (context, subjectIndex) {
          final String lessonName = lessonNames[subjectIndex];
          int totalCorrect = 0;
          int totalWrong = 0;
          int totalEmpty = 0;

          String? lessonId = lessonNameAndPhoto.entries
              .firstWhere(
                (e) =>
                    e.value['name']?.toString().trim().toLowerCase() ==
                    lessonName.trim().toLowerCase(), // Daha güvenli eşleşme
                orElse: () => const MapEntry('', {}),
              )
              .key;

          if (lessonId.isNotEmpty) {
            // lessonMockExams'ın tipini garantiye alıyoruz
            final List<dynamic> examsList = lessonMockExams is List
                ? lessonMockExams
                : [];

            Map<String, dynamic> result = examsList.firstWhere(
              (item) => item['lesson']?.toString() == lessonId,
              orElse: () => {},
            );

            totalCorrect = result['true'];
            totalWrong = result['wrong'];
            totalEmpty = result['pass'];
          }

          // Seçili dersin altındaki konuları Map olarak çekiyoruz
          final Map<String, dynamic> topicsMap = dataJson[lessonName] ?? {};

          final List<String> topicNames = topicsMap.keys.toList();

          // Ders başlığındaki rozetler (badge) için toplam skorları hesaplıyoruz

          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded:
                  subjectIndex == 0, // İlk ders otomatik açık gelsin
              title: Text(
                lessonName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              trailing: Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildSummaryBadge(
                    totalCorrect,
                    const Color(0xFF10B981),
                  ), // Doğru
                  _buildSummaryBadge(
                    totalWrong,
                    const Color(0xFFEF4444),
                  ), // Yanlış
                  _buildSummaryBadge(
                    totalEmpty,
                    const Color(0xFF94A3B8),
                  ), // Boş
                  const Icon(Icons.expand_more, color: Color(0xFF64748B)),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    children: topicNames.map((topicName) {
                      final topicDetail = topicsMap[topicName];

                      return _LessonsTopicCard(
                        topicName: topicName,
                        correctCount: (topicDetail['trueValue'] as num? ?? 0)
                            .toInt(),
                        wrongCount: (topicDetail['wrongValue'] as num? ?? 0)
                            .toInt(),
                        emptyCount: (topicDetail['passValue'] as num? ?? 0)
                            .toInt(),
                        netRate: (topicDetail['netRate'] as num? ?? 0.0)
                            .toDouble(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Ders başlığının sağındaki küçük Doğru/Yanlış/Boş sayaç kutuları
  Widget _buildSummaryBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _LessonsTopicCard extends StatelessWidget {
  final String topicName;
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final double netRate;

  const _LessonsTopicCard({
    required this.topicName,
    required this.correctCount,
    required this.wrongCount,
    required this.emptyCount,
    required this.netRate,
  });

  @override
  Widget build(BuildContext context) {
    final int total = correctCount + wrongCount + emptyCount;
    final double successRate = total > 0 ? (correctCount / total) : 0.0;
    final String percentageText = "${(successRate * 100).toInt()}%";

    Color progressColor;
    if (successRate < 0.20) {
      progressColor = Colors.red; // Kırmızı
    } else if (successRate < 0.50) {
      progressColor = Colors.yellow; // Sarı
    } else {
      progressColor = Colors.green; // Yeşil
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topicName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Row(
                  children: [
                    _buildStatItem(
                      "Doğru",
                      correctCount,
                      const Color(0xFF10B981),
                    ),
                    const Spacer(),
                    _buildStatItem(
                      "Yanlış",
                      wrongCount,
                      const Color(0xFFEF4444),
                    ),
                    const Spacer(),
                    _buildStatItem("Boş", emptyCount, const Color(0xFF94A3B8)),
                    const Spacer(flex: 2),
                  ],
                ),
              ],
            ),
          ),

          // Sağ Taraf: Yüzdelik Progress Indicator
          const SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: successRate,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor,
                      ), // Hesaplanan renk
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Text(
                    percentageText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
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

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Bilgi kartları kısmı
/// `OmdResultFlowView.lessonNameAndPhoto` — ders seçim kartları için ikon/ad eşlemesi.
const Map<String, Map<String, String>> lessonNameAndPhoto = {
  '66214a6982ff212039ea3294': {
    'name': 'TYT Tarih',
    'image': 'assets/tarih.png',
  },
  '663e37a24fb443839593141b': {
    'name': 'TYT Türkçe',
    'image': 'assets/turkce.png',
  },
  '663e387c4fb443839593141c': {
    'name': 'TYT Matematik',
    'image': 'assets/mat.png',
  },
  '6654977e17046de7432ed446': {
    'name': 'TYT Biyoloji',
    'image': 'assets/biological.png',
  },
  '665c5e80dad9088c202c6c16': {
    'name': 'TYT Fizik',
    'image': 'assets/physics.png',
  },
  '66604f1b2676809673eb4736': {'name': 'TYT Kimya', 'image': 'assets/fen.png'},
  '6660eec58cf59b23d04006b4': {
    'name': 'TYT Coğrafya',
    'image': 'assets/cografya.png',
  },
  '66bfb7a749ecda29c59f556b': {
    'name': 'TYT Geometri',
    'image': 'assets/geometry1.png',
  },
  '66b0e776c99f8fc189ff35fd': {
    'name': 'AYT Türk Dili ve Edebiyatı',
    'image': 'assets/edebiyat.png',
  },
  '66952a89986199d2903227b5': {
    'name': 'AYT Coğrafya',
    'image': 'assets/ayt_cografya.png',
  },
  '665ca77316c299c4d7bd2534': {
    'name': 'AYT Matematik',
    'image': 'assets/ayt_matematik.png',
  },
  '665cb46416c299c4d7bd2539': {
    'name': 'AYT Geometri',
    'image': 'assets/ayt_geometri.png',
  },
  '665c5eacdad9088c202c6c17': {
    'name': 'AYT Fizik',
    'image': 'assets/ayt_fizik.png',
  },
  '66604f252676809673eb4737': {
    'name': 'AYT Kimya',
    'image': 'assets/ayt_kimya.png',
  },
  '6654978d17046de7432ed448': {
    'name': 'AYT Biyoloji',
    'image': 'assets/ayt_biyoloji.png',
  },
};

String? getIdByLessonName(
  Map<String, Map<String, String>> data,
  String targetName,
) {
  try {
    // Map'in elemanları içinde dönerek 'name' alanı hedef isme eşit olan ilk kaydı buluyoruz
    var entry = data.entries.firstWhere(
      (element) => element.value['name'] == targetName,
    );
    return entry.key; // Bulunan kaydın ID'sini (key) döndürür
  } catch (e) {
    // Eğer eşleşen bir eleman bulunamazsa firstWhere hata fırlatır, yakalayıp null dönüyoruz
    return null;
  }
}

final List<Map<String, dynamic>> kMyTestResultsDetailStaticInfoCardsLessons =
    lessonNameAndPhoto.entries
        .map(
          (entry) => {
            'lessonId': entry.key,
            'name': entry.value['name'] ?? '',
            'image': entry.value['image'] ?? '',
            'net': 0,
            'pass': 0,
            'true': 0,
            'wrong': 0,
          },
        )
        .toList();

/// `OmdResultFlowView._buildStepTwoSelection` — Bilgi Kartları sekmesi (Statik dersler, dinamik veriler).
class MyTestResultsDetailInfoCardsTabContent extends StatelessWidget {
  final Map<String, dynamic> backendData;
  final Map<String, dynamic> mexam;

  const MyTestResultsDetailInfoCardsTabContent({
    super.key,
    required this.backendData, // Parametreyi constructor'da zorunlu kıldık
    required this.mexam,
  });

  @override
  Widget build(BuildContext context) {
    final cardData = backendData['data'];
    final lessonMockExams = mexam['lessonmockexams'];
    // --- HESAPLAMALARI VE VERI EKLEMELERINI BURADA YAPIYORUZ ---
    int totalInfoCard = 0;

    if (cardData != null && cardData is Map) {
      // .entries kullanarak hem lessonId'ye (entry.key) hem de ders detaylarına (entry.value) ulaşıyoruz
      for (var entry in cardData.entries) {
        final String lessonId = entry.key.toString();
        final Map lessonDetail = entry.value as Map;

        // 1. lessonId ile yerel haritadan isim ve görsel bilgisini çekiyoruz
        final localLessonInfo = lessonNameAndPhoto[lessonId];

        if (localLessonInfo != null) {
          // backendData'dan gelen ilgili ders nesnesinin içine name ve image alanlarını ekliyoruz
          lessonDetail['name'] = localLessonInfo['name'] ?? 'Bilinmeyen Ders';
          lessonDetail['image'] =
              localLessonInfo['image'] ?? 'assets/default.png';

          final List<dynamic> examsList = lessonMockExams is List
              ? lessonMockExams
              : [];

          Map<String, dynamic> result = examsList.firstWhere(
            (item) => item['lesson']?.toString() == lessonId,
            orElse: () => {},
          );

          lessonDetail['net'] = result['net'];
          lessonDetail['true'] = result['wrong'];
          lessonDetail['wrong'] = result['wrong'];
        } else {
          // Eğer lokal listede bu ID yoksa çökmemesi için varsayılan değerler atıyoruz
          lessonDetail['name'] = 'Bilinmeyen Ders';
          lessonDetail['image'] = 'assets/default.png';
        }

        final int cards = lessonDetail['totalCards'] ?? 0;
        final int items = lessonDetail['totalItems'] ?? 0;
        final int mapItems = lessonDetail['totalMapItems'] ?? 0;

        totalInfoCard += (cards + items + mapItems);
      }
    }

    // cardData'nın null olmadığını ve Map olduğunu garanti ediyoruz
    final Map<String, dynamic> currentData =
        (cardData as Map<String, dynamic>? ?? {});

    // Map'in anahtarlarını (ID'lerini) bir Iterable (döngü nesnesi) olarak alıyoruz
    final keys = currentData.keys;

    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSummaryCard(totalInfoCard),

          Expanded(
            child: currentData.isEmpty
                ? const Center(child: Text("Henüz veri bulunamadı."))
                : GridView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount:
                        currentData.length, // Doğrudan haritanın eleman sayısı
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      // 1. .elementAt(index) kullanarak o sıradaki lessonId'yi (anahtarı) çekiyoruz
                      final String lessonId = keys.elementAt(index);

                      // 2. Bu ID'yi kullanarak ana haritadan ders detayını alıyoruz
                      final Map<String, dynamic> lesson =
                          Map<String, dynamic>.from(currentData[lessonId]);

                      // 3. Ders kart sayılarını topluyoruz
                      final int cards = lesson['totalCards'] ?? 0;
                      final int items = lesson['totalItems'] ?? 0;
                      final int mapItems = lesson['totalMapItems'] ?? 0;
                      final int currentLessonCardCount =
                          cards + items + mapItems;

                      return _buildLessonGridItem(
                        lesson,
                        currentLessonCardCount,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- Yardımcı Widgetlar ---

  Widget _buildTopSummaryCard(int totalCardCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.layers, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 15),
              children: [
                const TextSpan(text: 'Toplam '),
                TextSpan(
                  text: '$totalCardCount ',
                  style: const TextStyle(
                    color: Color(0xFFFF6D00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' bilgi kartı kazandın'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonGridItem(Map<String, dynamic> lesson, int cardCount) {
    return GestureDetector(
      onTap: () {
        // Kart detayına gitme mantığı buraya yazılabilir
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Ders Logosu ve İsmi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  lesson['image'].toString(),
                  height: 40,
                  width: 40,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.book, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    lesson['name'].toString().length > 4
                        ? lesson['name'].toString().substring(4)
                        : lesson['name'].toString(),
                    style: const TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            // İstatistikler (Net, Doğru, Yanlış)
            _buildStatRow(lesson),

            // DİNAMİK BİLGİ KARTI SAYISI
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.layers, size: 14, color: Color(0xFF1A237E)),
                  const SizedBox(width: 4),
                  Text(
                    '$cardCount', // Dinamik olarak hesaplanan değer
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const Text(
                    ' Bilgi Kartı',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
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

  Widget _buildStatRow(Map<String, dynamic> lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _OmdStepTwoStatColumn(
            label: 'Net',
            value: lesson['net'].toString(),
            color: Colors.green,
          ),
          _OmdStepTwoStatColumn(
            label: 'D',
            value: lesson['true'].toString(),
            color: Colors.grey,
          ),
          _OmdStepTwoStatColumn(
            label: 'Y',
            value: lesson['wrong'].toString(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

/// `OmdResultFlowView._buildStatColumn`.
class _OmdStepTwoStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _OmdStepTwoStatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
