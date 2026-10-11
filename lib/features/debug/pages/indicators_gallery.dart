import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/indicators/app_linear_progress.dart';
import 'package:smap/shared/ui/indicators/app_page_dots.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/indicators/app_stat_box.dart';
import 'package:smap/shared/ui/indicators/app_success_ring.dart';
import 'package:smap/shared/ui/text/delta_text.dart';
import 'package:smap/shared/ui/text/metric_text.dart';

/// Gallery page of the indicators: `AppLinearProgress` (C44),
/// `AppSessionProgress` (C45), `AppSuccessRing` (C46), `AppSpinner` (C47)
/// (pano 1.15), `AppStatBox` (C27, pano 1.16), `MetricText` and `DeltaText`
/// (C49) and `AppPageDots` (C60).
class IndicatorsGallery extends StatefulWidget {
  const IndicatorsGallery({super.key});

  @override
  State<IndicatorsGallery> createState() => _IndicatorsGalleryState();
}

class _IndicatorsGalleryState extends State<IndicatorsGallery> {
  var _page = 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tarih = context.appSubject(SubjectKey.tarih);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppLinearProgress · C44 · pano 1.15',
          note:
              'Çubuk yalnız gerçek bir oranı gösterir; toplam yoksa hiçbir şey '
              'çizilmez. Yüzde ayrıca yazılmaz.',
          children: [
            GalleryState(
              label: 'subject · ders rengi',
              child: GalleryPanel(
                tone: GalleryTone.canvas,
                child: AppLinearProgress(
                  style: AppProgressStyle.subject,
                  color: tarih.fg,
                  value: 41,
                  total: 64,
                  label: '41 / 64 kart biliniyor',
                  semanticLabel: '64 karttan 41\'i biliniyor',
                ),
              ),
            ),
            const GalleryState(
              label: 'accent · genel ilerleme (4 pt) ve gönderim (8 pt)',
              child: GalleryPanel(
                tone: GalleryTone.canvas,
                child: Column(
                  children: [
                    AppLinearProgress(
                      value: 12,
                      total: 40,
                      semanticLabel: '40 karttan 12\'si',
                    ),
                    SizedBox(height: AppSpacing.s16),
                    AppLinearProgress(
                      value: 62,
                      total: 100,
                      height: AppLinearProgress.subjectHeight,
                      semanticLabel: 'Gönderim yüzde 62',
                    ),
                  ],
                ),
              ),
            ),
            const GalleryState(
              label: 'toplam yok · çizilmez (altındaki boşluk)',
              child: AppLinearProgress(value: 3, total: null),
            ),
            const GalleryState(
              label: 'AppSessionProgress · C45',
              child: GalleryPanel(
                tone: GalleryTone.canvas,
                child: AppSessionProgress(
                  value: 12,
                  total: 23,
                  counter: '12/23',
                  semanticLabel: '23 karttan 12\'si',
                ),
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'AppSuccessRing · C46 · pano 1.15',
          note:
              'Tek renk; yüzde en yakın tam sayıya yuvarlanır (5/12 = %42). '
              'Soru yoksa halka çizilmez: "Soru yok".',
          children: [
            GalleryWrap(
              children: [
                GalleryState(
                  label: '5 / 12',
                  child: AppSuccessRing(correct: 5, total: 12),
                ),
                GalleryState(
                  label: '1 / 1',
                  child: AppSuccessRing(correct: 1, total: 1),
                ),
                GalleryState(
                  label: '0 / 1',
                  child: AppSuccessRing(correct: 0, total: 1),
                ),
                GalleryState(
                  label: 'soru yok',
                  child: AppSuccessRing(correct: 0, total: 0),
                ),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'AppSpinner · C47 · pano 1.15',
          note:
              'Yalnız süresi bilinmeyen adımda, yanında ne beklendiğini '
              'söyleyen metinle. Hareketi azaltta yay durur.',
          children: [
            GalleryWrap(
              children: [
                const GalleryState(
                  label: '24',
                  child: AppSpinner(semanticLabel: 'Cevaplar okunuyor'),
                ),
                const GalleryState(
                  label: '48',
                  child: AppSpinner(size: 48, semanticLabel: 'Yükleniyor'),
                ),
                GalleryState(
                  label: '20 · laciverte',
                  child: GalleryPanel(
                    tone: GalleryTone.navy,
                    child: AppSpinner(
                      size: 20,
                      color: colors.textOnNavy,
                      trackColor: colors.textOnNavy.withValues(alpha: 0.24),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const GallerySection(
          title: 'AppStatBox · C27 · pano 1.16',
          note:
              'Değer, etiket, delta satırı. Delta yoksa satır, değer yoksa '
              'kutu çizilmez. İki sütun, 8 aralık.',
          children: [
            GalleryPanel(
              tone: GalleryTone.canvas,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppStatBox(label: 'Çözülen deneme', value: '6'),
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: AppStatBox(
                          label: 'Ortalama net',
                          value: '67,79',
                          delta: 3.25,
                          deltaSuffix: 'son denemede',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppStatBox(
                          label: 'Ortalama puan',
                          value: '381,40',
                        ),
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: AppStatBox(
                          label: 'Ortalama sıralama',
                          value: '182.430',
                          delta: -4120,
                          deltaSuffix: 'son denemede',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'MetricText · DeltaText · C49',
          note:
              'İşaret her zaman yazılır; renk anlam taşımaz, yön oktan '
              'okunur. Sıfır değişimde ok yok.',
          children: [
            GalleryWrap(
              children: [
                MetricText(value: '67,5', size: MetricSize.xl),
                MetricText(value: '67,5', size: MetricSize.lg),
                MetricText(value: '412,63', unit: 'puan'),
                MetricText(value: '48.215', size: MetricSize.sm),
              ],
            ),
            GalleryWrap(
              children: [
                DeltaText(
                  value: 8.25,
                  size: DeltaTextSize.badge,
                  suffix: 'geçen denemeye göre',
                ),
                DeltaText(value: 3.25, suffix: 'son denemede'),
                DeltaText(value: -1.5, size: DeltaTextSize.result),
                DeltaText(value: 0),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'AppPageDots · C60',
          note: 'Sayfa noktaları: geçerli 24 x 8 turuncu, diğerleri 8 x 8.',
          children: [
            Row(
              children: [
                AppPageDots(count: 3, index: _page),
                const SizedBox(width: AppSpacing.s16),
                for (var i = 0; i < 3; i++)
                  GestureDetector(
                    onTap: () => setState(() => _page = i),
                    child: SizedBox.square(
                      dimension: AppSize.touch,
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: context.appText.labelMd.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
