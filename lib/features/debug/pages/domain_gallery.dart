import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/analytics/presentation/widgets/net_chart.dart';
import 'package:smap/features/cards/presentation/widgets/info_card_face.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_counter.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_glyph.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_stacked_bar.dart';
import 'package:smap/features/exams/presentation/widgets/exam_header.dart';
import 'package:smap/features/exams/presentation/widgets/exam_info_row.dart';
import 'package:smap/features/exams/presentation/widgets/exam_row.dart';
import 'package:smap/features/exams/presentation/widgets/exam_score_card.dart';
import 'package:smap/features/exams/presentation/widgets/exam_summary_card.dart';
import 'package:smap/features/exams/presentation/widgets/question_cell.dart';
import 'package:smap/features/exams/presentation/widgets/test_bar_row.dart';
import 'package:smap/features/exams/presentation/widgets/topic_result_row.dart';
import 'package:smap/features/lessons/application/topic_outline.dart';
import 'package:smap/features/lessons/presentation/widgets/author_row.dart';
import 'package:smap/features/lessons/presentation/widgets/eksik_tag.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_glyph.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_row.dart';
import 'package:smap/features/lessons/presentation/widgets/subject_tile.dart';
import 'package:smap/features/lessons/presentation/widgets/topic_row.dart';
import 'package:smap/features/lessons/presentation/widgets/work_row.dart';
import 'package:smap/features/schedule/presentation/widgets/program_item_row.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';

void _noop() {}

/// Gallery page of the domain components (task DOM), with the sample data of
/// the design brief (Ek C): D/Y/B family C40 to C43 (pano 1.14), progress and
/// rows C23 to C26 (panos 1.15, 1.16, 5.3 to 5.5), net chart C48 (pano 1.4),
/// subject components C08, C20 to C22, C58 (panos 1.16, 1.17, 7.1, 7.2),
/// program row C30 (pano 3.1) and the study card face of C52 (pano 8.1).
///
/// The light / dark switch of the gallery shows every demo in both themes.
class DomainGallery extends StatefulWidget {
  const DomainGallery({super.key});

  @override
  State<DomainGallery> createState() => _DomainGalleryState();
}

class _DomainGalleryState extends State<DomainGallery> {
  var _favorite = false;
  var _cardFavorite = false;
  var _removed = false;
  var _workLearned = false;

  static const _aytCounts = DybCounts(correct: 86, wrong: 74, blank: 0);
  static const _tytCounts = DybCounts(correct: 80, wrong: 21, blank: 19);

  static final DateTime _aytDate = DateTime(2026, 10, 5);
  static final DateTime _tytDate = DateTime(2026, 9, 28);

  static final List<NetChartPoint> _tytPoints = [
    NetChartPoint(date: DateTime(2026, 4, 22), net: 61.5),
    NetChartPoint(date: DateTime(2026, 5, 14), net: 64.25),
    NetChartPoint(date: DateTime(2026, 6, 17), net: 68),
    NetChartPoint(date: DateTime(2026, 8, 4), net: 66.75),
    NetChartPoint(date: DateTime(2026, 9, 15), net: 71.5),
    NetChartPoint(
      date: DateTime(2026, 9, 28),
      net: 74.75,
      name: 'TYT Genel Deneme 9',
    ),
  ];

  static final List<NetChartPoint> _aytPoints = [
    NetChartPoint(date: DateTime(2026, 5, 8), net: 48.5),
    NetChartPoint(date: DateTime(2026, 8, 2), net: 55),
    NetChartPoint(date: DateTime(2026, 9, 21), net: 59.25),
    NetChartPoint(
      date: DateTime(2026, 10, 5),
      net: 67.5,
      name: 'Türkiye Geneli Deneme 6',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dybSection(),
        _barSection(),
        _questionSection(),
        _topicResultSection(),
        _examRowSection(),
        _summarySection(),
        _headerSection(),
        _chartSection(),
        _subjectGlyphSection(),
        _subjectRowSection(),
        _subjectTileSection(),
        _topicRowSection(),
        _eraAuthorSection(),
        _workRowSection(),
        _programSection(),
        _cardFaceSection(),
        _rowShellSection(),
      ],
    );
  }

  Widget _dybSection() {
    return const GallerySection(
      title: 'DybGlyph · DybCounter · C40, C41 · pano 1.14',
      note:
          'Sıra hep D, Y, B; Boş sıfır da olsa görünür. Sayı metin renginde, '
          'şekil sonucu söyler. Tek okunuş: "86 doğru, 74 yanlış, 0 boş".',
      children: [
        GalleryState(
          label: 'DybGlyph · küçük 16 / normal 24',
          child: GalleryWrap(
            children: [
              DybGlyph(kind: DybKind.correct),
              DybGlyph(kind: DybKind.wrong),
              DybGlyph(kind: DybKind.blank),
              DybGlyph(kind: DybKind.correct, size: DybGlyphSize.regular),
              DybGlyph(kind: DybKind.wrong, size: DybGlyphSize.regular),
              DybGlyph(kind: DybKind.blank, size: DybGlyphSize.regular),
            ],
          ),
        ),
        GalleryState(
          label: 'Büyük sayaç (deneme detay, sonuç anı)',
          child: GalleryPanel(
            child: DybCounter(counts: _aytCounts, size: DybCounterSize.large),
          ),
        ),
        GalleryState(
          label: 'Küçük sayaç · harf (satır, akordeon başlığı)',
          child: GalleryPanel(child: DybCounter(counts: _tytCounts)),
        ),
        GalleryState(
          label: 'Küçük sayaç · kelime (anasayfa, konu satırı)',
          child: GalleryPanel(
            child: DybCounter(
              counts: _aytCounts,
              labels: DybCounterLabels.word,
            ),
          ),
        ),
      ],
    );
  }

  Widget _barSection() {
    return const GallerySection(
      title: 'DybStackedBar · TestBarRow · C42 · pano 1.14',
      note:
          'Parçalar sayı kadar geniş, aralarında 2 pt ayrım; sıfır olan parça '
          'çizilmez. Test adı kesilmez, ikinci satıra iner.',
      children: [
        GalleryState(
          label: 'DybStackedBar · AYT 86 / 74 / 0',
          child: GalleryPanel(child: DybStackedBar(counts: _aytCounts)),
        ),
        GalleryState(
          label: 'DybStackedBar · TYT 80 / 21 / 19',
          child: GalleryPanel(child: DybStackedBar(counts: _tytCounts)),
        ),
        GalleryState(
          label: 'TestBarRow · AYT testleri',
          child: GalleryPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TestBarRow(
                  name: 'Türk Dili ve Edebiyatı–Sosyal Bilimler 1',
                  net: 18.75,
                  counts: DybCounts(correct: 23, wrong: 17, blank: 0),
                ),
                SizedBox(height: AppSpacing.s16),
                TestBarRow(
                  name: 'Sosyal Bilimler 2',
                  net: 11.25,
                  counts: DybCounts(correct: 17, wrong: 23, blank: 0),
                ),
                SizedBox(height: AppSpacing.s16),
                TestBarRow(
                  name: 'Matematik',
                  net: 21.25,
                  counts: DybCounts(correct: 25, wrong: 15, blank: 0),
                ),
                SizedBox(height: AppSpacing.s16),
                TestBarRow(
                  name: 'Fen Bilimleri',
                  net: 16.25,
                  counts: DybCounts(correct: 21, wrong: 19, blank: 0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionSection() {
    final cells = <Widget>[
      const QuestionCell.result(
        number: 1,
        outcome: QuestionOutcome.correct,
        marked: 'B',
        correctAnswer: 'B',
        onTap: _noop,
      ),
      const QuestionCell.result(
        number: 2,
        outcome: QuestionOutcome.wrong,
        marked: 'C',
        correctAnswer: 'A',
        onTap: _noop,
      ),
      const QuestionCell.result(
        number: 3,
        outcome: QuestionOutcome.blank,
        correctAnswer: 'D',
        onTap: _noop,
      ),
      const QuestionCell.result(
        number: 4,
        outcome: QuestionOutcome.wrong,
        marked: 'E',
        onTap: _noop,
      ),
      const QuestionCell.result(
        number: 7,
        outcome: QuestionOutcome.wrong,
        marked: 'C',
        correctAnswer: 'A',
        onTap: _noop,
      ),
    ];
    final checks = <Widget>[
      const QuestionCell.formCheck(
        number: 9,
        status: FormCheckStatus.read,
        marked: 'D',
        onTap: _noop,
      ),
      const QuestionCell.formCheck(
        number: 10,
        status: FormCheckStatus.read,
        marked: 'A',
        onTap: _noop,
      ),
      const QuestionCell.formCheck(
        number: 11,
        status: FormCheckStatus.blankRead,
        onTap: _noop,
      ),
      const QuestionCell.formCheck(
        number: 12,
        status: FormCheckStatus.corrected,
        marked: 'C',
        onTap: _noop,
      ),
      const QuestionCell.formCheck(
        number: 13,
        status: FormCheckStatus.read,
        marked: 'E',
        onTap: _noop,
      ),
    ];
    return GallerySection(
      title: 'QuestionCell · C43 · pano 1.14, 5.4',
      note:
          '5 sütun. Sonuç: 76 pt; yanlış ve boşta "Doğru A". Form kontrolü: '
          '52 pt; boş okundu kesikli kenar, düzeltildi kalem işareti. '
          'Basılı: 0,97.',
      children: [
        GalleryState(
          label: 'Sonuç · doğru, yanlış, boş',
          child: _CellGrid(cells: cells, variant: QuestionCellVariant.result),
        ),
        GalleryState(
          label: 'Form kontrolü · okundu, boş okundu, düzeltildi',
          child: _CellGrid(
            cells: checks,
            variant: QuestionCellVariant.formCheck,
          ),
        ),
      ],
    );
  }

  Widget _topicResultSection() {
    return const GallerySection(
      title: 'TopicResultRow · C23 · pano 1.15, 5.5',
      note:
          'Tek renk halka, %42 gibi. Bir ya da iki soruda "Az soru"; soru '
          'yoksa halka yerine "Soru yok". Zayıftan güçlüye sıralı.',
      children: [
        AppRowGroup(
          children: [
            TopicResultRow(
              name: 'Söz Sanatları',
              counts: DybCounts(correct: 0, wrong: 1, blank: 0),
              onTap: _noop,
            ),
            TopicResultRow(
              name: 'Cumhuriyet Edebiyatı',
              counts: DybCounts(correct: 5, wrong: 7, blank: 0),
              onTap: _noop,
            ),
            TopicResultRow(
              name:
                  'İslamiyet Etkisindeki Türk Edebiyatı '
                  '(Divan-Halk Edebiyatı)',
              counts: DybCounts(correct: 0, wrong: 2, blank: 0),
              onTap: _noop,
            ),
            TopicResultRow(
              name: 'Batı Edebiyatı ve Akımları',
              counts: DybCounts(correct: 1, wrong: 0, blank: 0),
              onTap: _noop,
            ),
            TopicResultRow(
              name: 'Nazım Bilgisi',
              counts: DybCounts(correct: 0, wrong: 0, blank: 0),
              onTap: _noop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _examRowSection() {
    return GallerySection(
      title: 'ExamRow · C24 · pano 1.16, 5.2',
      note:
          'Kapak 40 x 54, köşe 8; kapak yoksa nötr kutu. Yayınevi yoksa '
          'çizilmez. Yıldız yalnız cihazda saklanır (Ek D-25).',
      children: [
        AppRowGroup(
          children: [
            ExamRow(
              name: 'Türkiye Geneli Deneme 6',
              publisher: 'Örnek Yayınları',
              typeLabel: 'AYT',
              date: _aytDate,
              net: 67.5,
              counts: _aytCounts,
              isFavorite: _favorite,
              onFavoriteChanged: (value) => setState(() => _favorite = value),
              onTap: _noop,
            ),
            ExamRow(
              name: 'TYT Genel Deneme 9',
              typeLabel: 'TYT',
              date: _tytDate,
              net: 74.75,
              counts: _tytCounts,
              onTap: _noop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _summarySection() {
    return GallerySection(
      title: 'ExamSummaryCard · C25 · pano 3.1',
      note:
          '"Son denemen": net, değişim (önceki aynı türe göre), D/Y/B ve en '
          'çok kaçırılan konu. Veri yoksa alan çizilmez; hiç deneme yoksa '
          'boş kart.',
      children: [
        ExamSummaryCard(
          name: 'Türkiye Geneli Deneme 6',
          publisher: 'Örnek Yayınları',
          typeLabel: 'AYT',
          date: _aytDate,
          net: 67.5,
          delta: 8.25,
          counts: _aytCounts,
          weakestTopicSentence:
              "Kurtuluş Savaşı Hazırlık Dönemi'nde 13 sorudan 9'unu "
              'kaçırdın.',
          onAnalyze: _noop,
        ),
        ExamSummaryCard(
          name: 'TYT Genel Deneme 9',
          typeLabel: 'TYT',
          date: _tytDate,
          net: 74.75,
          counts: _tytCounts,
          onAnalyze: _noop,
        ),
        const ExamSummaryCard.empty(onScan: _noop),
      ],
    );
  }

  Widget _headerSection() {
    return GallerySection(
      title: 'ExamHeader · ExamScoreCard · ExamInfoRow · C26 · pano 5.1, 5.3',
      note:
          'Detay: kapak 48 x 64. Sonuç anı: kapak 56 x 76 ve girişte 8 pt '
          'yükselen düşme. Puan ve sıralama yalnız veri varsa.',
      children: [
        GalleryState(
          label: 'detail · Genel sekmesi',
          child: AppCard(
            child: ExamHeader.detail(
              name: 'Türkiye Geneli Deneme 6',
              publisher: 'Örnek Yayınları',
              typeLabel: 'AYT',
              date: _aytDate,
              net: 67.5,
              counts: _aytCounts,
              scoreFieldName: 'Eşit Ağırlık',
              score: 412.63,
              rank: 48215,
            ),
          ),
        ),
        GalleryState(
          label: 'moment · sonuç anı',
          child: AppCard(
            child: ExamHeader.moment(
              name: 'Türkiye Geneli Deneme 6',
              publisher: 'Örnek Yayınları',
              typeLabel: 'AYT',
              date: _aytDate,
              net: 67.5,
              delta: 8.25,
              counts: _aytCounts,
              animateIn: false,
            ),
          ),
        ),
        const GalleryState(
          label: 'ExamScoreCard',
          child: ExamScoreCard(
            fieldName: 'Eşit Ağırlık',
            score: 412.63,
            rank: 48215,
          ),
        ),
        const GalleryState(
          label: 'ExamInfoRow',
          child: ExamInfoRow(
            text: 'Bu denemeden 23 bilgi kartı eklendi',
            onTap: _noop,
          ),
        ),
      ],
    );
  }

  Widget _chartSection() {
    return GallerySection(
      title: 'NetChart · C48 · pano 1.4, 6.1',
      note:
          'Eksen sınava sabit: TYT 0–120, AYT 0–160. Son nokta vurgulu, '
          'noktalara dokununca balon; dışına dokununca son noktaya döner.',
      children: [
        NetChart(points: _tytPoints, examType: NetExamType.tyt),
        NetChart(points: _aytPoints, examType: NetExamType.ayt),
        GalleryState(
          label: 'Tek deneme: yalnız nokta',
          child: NetChart(points: [_aytPoints.last], examType: NetExamType.ayt),
        ),
        GalleryState(
          label: 'Ders grafiği: eksen soru sayısı (40), "TYT Türkçe"',
          child: NetChart(
            points: [
              NetChartPoint(date: DateTime(2026, 5, 14), net: 24.5),
              NetChartPoint(date: DateTime(2026, 8, 4), net: 28),
              NetChartPoint(date: DateTime(2026, 9, 28), net: 33),
            ],
            examType: NetExamType.tyt,
            axisMax: 40,
            scopeLabel: 'TYT Türkçe',
          ),
        ),
      ],
    );
  }

  Widget _subjectGlyphSection() {
    return GallerySection(
      title: 'EksikTag · SubjectGlyph · C08, C58 · pano 1.16, 1.17',
      note:
          'Dokuz ders, dokuz renk; ders dışı ad nötr kutu. Ders adı hep '
          'yanında yazılır, renk tek başına bilgi taşımaz.',
      children: [
        GalleryWrap(
          children: [
            for (final subject in SubjectKey.values)
              SubjectGlyph(subject: subject),
            const SubjectGlyph(subject: null),
          ],
        ),
        const GalleryState(
          label: 'Boylar 48 · 40 · 36 · 32 · 28',
          child: GalleryWrap(
            children: [
              SubjectGlyph(
                subject: SubjectKey.tarih,
                size: SubjectGlyphSize.kit,
              ),
              SubjectGlyph(subject: SubjectKey.tarih),
              SubjectGlyph(
                subject: SubjectKey.tarih,
                size: SubjectGlyphSize.program,
              ),
              SubjectGlyph(
                subject: SubjectKey.tarih,
                size: SubjectGlyphSize.preview,
              ),
              SubjectGlyph(
                subject: SubjectKey.tarih,
                size: SubjectGlyphSize.card,
              ),
            ],
          ),
        ),
        const GalleryState(
          label: 'EksikTag · sayılı ve sayısız',
          child: GalleryWrap(
            children: [EksikTag(count: 31), EksikTag(count: 3), EksikTag()],
          ),
        ),
      ],
    );
  }

  Widget _subjectRowSection() {
    return const GallerySection(
      title: 'SubjectRow · C20 · pano 1.16, 7.1',
      note:
          'En az 72. Sağda tek etiket: "N eksik", "eksik yok", ders etiketi '
          'ya da "Web\'de". Kart verisi olan derste ilerleme çubuğu.',
      children: [
        AppRowGroup(
          children: [
            SubjectRow(
              name: 'Türkçe',
              subject: SubjectKey.turkce,
              missing: 31,
              cardsKnown: 41,
              cardsTotal: 64,
              onTap: _noop,
            ),
            SubjectRow(
              name: 'Tarih',
              subject: SubjectKey.tarih,
              missing: 60,
              onTap: _noop,
            ),
            SubjectRow(
              name: 'Edebiyat',
              subject: SubjectKey.edebiyat,
              missing: 3,
              onTap: _noop,
            ),
            SubjectRow(
              name: 'Kimya',
              subject: SubjectKey.kimya,
              missing: 0,
              onTap: _noop,
            ),
            SubjectRow(
              name: 'Sosyal Bilimler 2',
              subject: SubjectKey.cografya,
              testName: 'Sosyal Bilimler 2 testi',
              tag: 'SOS-2',
              onTap: _noop,
            ),
            SubjectRow(
              name: 'Matematik',
              subject: SubjectKey.matematik,
              webOnly: true,
              onTap: _noop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _subjectTileSection() {
    return const GallerySection(
      title: 'SubjectTile · C21 · pano 3.1 "Derslerin"',
      note:
          'Eksiği çok olan önde; Matematik ve Geometri sona ve "Web\'de". '
          'Eksik sayısı bilinmiyorsa etiket çizilmez.',
      children: [
        GalleryPanel(
          tone: GalleryTone.canvas,
          child: GalleryWrap(
            children: [
              SubjectTile(
                name: 'Tarih',
                subject: SubjectKey.tarih,
                missing: 60,
                onTap: _noop,
              ),
              SubjectTile(
                name: 'Coğrafya',
                subject: SubjectKey.cografya,
                missing: 44,
                onTap: _noop,
              ),
              SubjectTile(
                name: 'Türkçe',
                subject: SubjectKey.turkce,
                missing: 31,
                onTap: _noop,
              ),
              SubjectTile(
                name: 'Fizik',
                subject: SubjectKey.fizik,
                onTap: _noop,
              ),
              SubjectTile(
                name: 'Matematik',
                subject: SubjectKey.matematik,
                webOnly: true,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topicRowSection() {
    return const GallerySection(
      title: 'TopicRow · C22 · pano 1.16, 7.2',
      note:
          'Numara kesintisiz ve solda sabit; ad iki satıra iner; eksik varsa '
          'EksikTag. Süzülen listede numaralar tam listedeki gibi kalır.',
      children: [
        AppRowGroup(
          children: [
            TopicRow(number: 1, name: 'Sözcükte Anlam', onTap: _noop),
            TopicRow(
              number: 8,
              name: 'Cümlenin Öğeleri',
              missing: 2,
              onTap: _noop,
            ),
            TopicRow(number: 9, name: 'Fiilde Çatı', missing: 3, onTap: _noop),
            TopicRow(
              number: 11,
              name:
                  'Anlatım Bozuklukları ve Noktalama İşaretlerinin Doğru '
                  'Kullanımı',
              missing: 3,
              onTap: _noop,
            ),
            TopicRow(number: 12, name: 'Noktalama İşaretleri', onTap: _noop),
          ],
        ),
      ],
    );
  }

  Widget _eraAuthorSection() {
    return const GallerySection(
      title: 'TopicRow dönem hâli · AuthorRow · C22, C28 · pano 14.5',
      note:
          'Dönem satırı: sıra numarası, ad, "2 eksik eser" (yazar sayısı '
          'gelmediği için yazılmaz). Yazar satırı: 48 pt fotoğraf ya da baş '
          'harf, ad, "8 eser", eksik varsa "2 eksik"; eserleri yoksa sayı '
          'yazılmaz.',
      children: [
        GalleryState(
          label: 'dönemler',
          child: AppRowGroup(
            children: [
              TopicRow(
                number: 1,
                name: 'Tanzimat Dönemi',
                missing: 2,
                missingWorks: true,
                onTap: _noop,
              ),
              TopicRow(
                number: 2,
                name: 'Servet-i Fünun Dönemi',
                missing: 1,
                missingWorks: true,
                onTap: _noop,
              ),
              TopicRow(number: 3, name: 'Fecr-i Âti', onTap: _noop),
            ],
          ),
        ),
        GalleryState(
          label: 'yazarlar',
          child: AppRowGroup(
            children: [
              AuthorRow(name: 'Şinasi', workCount: 3, onTap: _noop),
              AuthorRow(
                name: 'Namık Kemal',
                workCount: 8,
                missing: 2,
                onTap: _noop,
              ),
              AuthorRow(name: 'Ziya Paşa', workCount: 6, onTap: _noop),
              AuthorRow(
                name: 'Sami Paşazade Sezai',
                workCount: 0,
                onTap: _noop,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _workRowSection() {
    return GallerySection(
      title: 'WorkRow · durumlu eser satırı · pano 14.6, 14.7',
      note:
          'Eksik eserde "Eksik" ve metin düğmesi "Öğrendim"; bilinen eserde '
          '✓ "Biliyorsun" (success); durumu gelmeyen eserde yalnız ad. '
          'Çevrimdışıyken düğme pasif, nedeni ilk eksik eserin altında. '
          'Durum değişince sağ taraf 250 ms\'de çapraz solar.',
      children: [
        GalleryState(
          label: 'missing · known · unknown',
          child: ColoredBox(
            color: context.appColors.bgRaised,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Column(
                children: [
                  WorkRow(
                    title: 'İntibah',
                    state: _workLearned
                        ? ItemCardState.learned
                        : ItemCardState.missing,
                    typeName: 'Roman',
                    onLearn: () => setState(() => _workLearned = true),
                  ),
                  const WorkRow(
                    title: 'Cezmi',
                    state: ItemCardState.learned,
                    typeName: 'Roman',
                  ),
                  const WorkRow(
                    title: 'Müntehabat-ı Eş\'ar',
                    state: ItemCardState.unknown,
                    typeName: 'Şiir',
                  ),
                ],
              ),
            ),
          ),
        ),
        GalleryState(
          label: 'offline',
          child: ColoredBox(
            color: context.appColors.bgRaised,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: WorkRow(
                title: 'İntibah',
                state: ItemCardState.missing,
                typeName: 'Roman',
                offlineNote: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _programSection() {
    return GallerySection(
      title: 'ProgramItemRow · C30 · pano 3.1 "Bugün", 3.6',
      note:
          'Görünüm: satır konuyu açar. Düzenleme: saat altı çizili düğme, '
          'sağda çıkar düğmesi (48 pt hedef).',
      children: [
        const GalleryState(
          label: 'view',
          child: AppRowGroup(
            children: [
              ProgramItemRow(
                hour: 10,
                minute: 0,
                subjectName: 'Türkçe',
                topic: 'Fiilde Çatı',
                subject: SubjectKey.turkce,
                onTap: _noop,
              ),
              ProgramItemRow(
                hour: 14,
                minute: 0,
                subjectName: 'Tarih',
                topic: 'Kurtuluş Savaşı Hazırlık Dönemi',
                subject: SubjectKey.tarih,
                onTap: _noop,
              ),
              ProgramItemRow(
                hour: 20,
                minute: 0,
                subjectName: 'Coğrafya',
                topic: 'İklim Bilgisi',
                subject: SubjectKey.cografya,
                onTap: _noop,
              ),
            ],
          ),
        ),
        GalleryState(
          label: 'edit',
          child: AppRowGroup(
            children: [
              if (!_removed)
                ProgramItemRow(
                  hour: 10,
                  minute: 0,
                  subjectName: 'Türkçe',
                  topic: 'Fiilde Çatı',
                  subject: SubjectKey.turkce,
                  mode: ProgramItemMode.edit,
                  onTimeTap: _noop,
                  onRemove: () => setState(() => _removed = true),
                ),
              const ProgramItemRow(
                hour: 14,
                minute: 0,
                subjectName: 'Tarih',
                topic: 'Kurtuluş Savaşı Hazırlık Dönemi',
                subject: SubjectKey.tarih,
                mode: ProgramItemMode.edit,
                onTimeTap: _noop,
                onRemove: _noop,
              ),
            ],
          ),
        ),
        if (_removed)
          const GalleryNote('Satır çıkarıldı. Sayfayı yenileyince geri gelir.'),
      ],
    );
  }

  Widget _cardFaceSection() {
    return GallerySection(
      title: 'InfoCardFace · C52 kart yüzü · pano 8.1',
      note:
          'Köşe 24, kenarsız; gölge yalnız sürüklenirken. "Eksik" etiketi '
          'yalnız eksik kartta. Arkadaki iki kart InfoCardBackEdge.',
      children: [
        GalleryState(
          label: 'Eksik kart · favori değiştirilebilir',
          child: InfoCardFace(
            subject: SubjectKey.tarih,
            subjectName: 'Tarih',
            title: 'Edirne-Segedin Antlaşması (1444)',
            body:
                "Haçlılarla Osmanlı Devleti'nin imzaladığı ilk antlaşma. "
                'Tuna sınır olur, on yıl savaş yapılmaz.',
            isMissing: true,
            isFavorite: _cardFavorite,
            onFavoriteTap: () => setState(() => _cardFavorite = !_cardFavorite),
            minHeight: 280,
          ),
        ),
        const GalleryState(
          label: 'Sürüklenirken · gölge',
          child: InfoCardFace(
            subject: SubjectKey.tarih,
            subjectName: 'Tarih',
            title: 'Otlukbeli Savaşı (1473)',
            body: 'Fatih Sultan Mehmet – Uzun Hasan (Akkoyunlu).',
            dragging: true,
            minHeight: 200,
          ),
        ),
        const GalleryState(
          label: 'Arka kenarlar · derinlik 1 ve 2',
          child: SizedBox(
            height: 64,
            child: Stack(
              children: [
                Positioned.fill(child: InfoCardBackEdge(depth: 2)),
                Positioned.fill(child: InfoCardBackEdge(depth: 1)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowShellSection() {
    final colors = context.appColors;
    final text = context.appText;
    return GallerySection(
      title: 'AppRowShell · genel parça · pano 1.15, 1.16',
      note:
          'Alan bilgisi taşımayan satır kabuğu: dolgu 12 / 16, en az 56, '
          'basılıyken bgSunken, klavye odağı halkası içeride. Satır ve '
          'konu satırları bunun üstüne kurulur.',
      children: [
        AppRowGroup(
          children: [
            AppRowShell(
              onTap: _noop,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Dokunulur kabuk',
                      style: text.bodyStrong.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(PhosphorIconsRegular.caretRight, size: 20),
                ],
              ),
            ),
            AppRowShell(
              child: Text(
                'Durağan kabuk (dokunulmaz)',
                style: text.bodyStrong.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A 5-column grid of [QuestionCell]s as the screens lay them out.
class _CellGrid extends StatelessWidget {
  const _CellGrid({required this.cells, required this.variant});

  final List<Widget> cells;
  final QuestionCellVariant variant;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: QuestionCell.gridDelegate(context, variant: variant),
      children: cells,
    );
  }
}
