import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/controls/app_switch.dart';
import 'package:smap/shared/ui/surfaces/app_accordion.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';
import 'package:smap/shared/ui/text/section_header.dart';

void _noop() {}

/// Gallery page of the surfaces and rows: `AppCard`, `AppRow` and
/// `AppRowGroup` (C17, C18, pano 1.13), `SectionHeader` (C19),
/// `AppAccordion` (C50) and `AppNoticeBox` (C39).
class SurfacesGallery extends StatefulWidget {
  const SurfacesGallery({super.key});

  @override
  State<SurfacesGallery> createState() => _SurfacesGalleryState();
}

class _SurfacesGalleryState extends State<SurfacesGallery> {
  var _ready = true;
  var _reminder = false;
  var _open = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final turkce = context.appSubject(SubjectKey.turkce);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppCard · pano 1.16',
          note:
              'Kenarsız, gölgesiz, bgSurface, köşe 16. Dokunulur kartta bas ve '
              'tut: bir ton koyulaşır, 0,98 ölçek.',
          children: [
            AppCard(
              child: Text(
                'Düz kart',
                style: text.titleSm.copyWith(color: colors.textPrimary),
              ),
            ),
            AppCard(
              onTap: _noop,
              semanticLabel: 'Dokunulur kart',
              child: Text(
                'Dokunulur kart',
                style: text.titleSm.copyWith(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppRow · AppRowGroup · C17, C18 · pano 1.13',
          note:
              'En az 56 (alt metinde 72). Ayraç metnin başladığı yerden. '
              'Tehlikeli satır ayrı grupta, oksuz.',
          children: [
            AppRowGroup(
              title: 'Hesap',
              children: [
                const AppRow(
                  title: 'Profil',
                  icon: PhosphorIconsRegular.user,
                  onTap: _noop,
                ),
                const AppRow(
                  title: 'Bildirimler',
                  subtitle: 'Deneme sonucu, koç, görüşme, hatırlatıcı',
                  icon: PhosphorIconsRegular.bell,
                  onTap: _noop,
                ),
                const AppRow(
                  title: 'Sessiz saatler',
                  icon: PhosphorIconsRegular.clock,
                  value: '22:00–08:00',
                  onTap: _noop,
                ),
                AppRow(
                  title: 'Deneme sonucun hazır',
                  subtitle: 'Okuttuğun denemenin analizi bitince',
                  icon: PhosphorIconsRegular.cards,
                  trailing: AppSwitch(
                    value: _ready,
                    onChanged: (v) => setState(() => _ready = v),
                  ),
                  onTap: () => setState(() => _ready = !_ready),
                ),
                AppRow(
                  title: 'Çalışma hatırlatıcısı',
                  icon: PhosphorIconsRegular.clock,
                  trailing: AppSwitch(
                    value: _reminder,
                    onChanged: (v) => setState(() => _reminder = v),
                  ),
                  onTap: () => setState(() => _reminder = !_reminder),
                ),
              ],
            ),
            AppRowGroup(
              title: 'Derslerin',
              children: [
                AppRow(
                  title: 'Türkçe',
                  tag: '31 eksik',
                  leading: DecoratedBox(
                    decoration: BoxDecoration(
                      color: turkce.bg,
                      borderRadius: AppRadius.borderMd,
                    ),
                    child: SizedBox.square(
                      dimension: 40,
                      child: Center(
                        child: PhosphorIcon(
                          PhosphorIconsRegular.textAa,
                          size: 22,
                          color: turkce.fg,
                        ),
                      ),
                    ),
                  ),
                  onTap: _noop,
                ),
                const AppRow(
                  title: 'Kullanım Koşulları',
                  icon: PhosphorIconsRegular.question,
                  external: true,
                  onTap: _noop,
                ),
                const AppRow(
                  title: 'Salt okunur satır',
                  icon: PhosphorIconsRegular.lock,
                  value: 'alparslan.k',
                ),
              ],
            ),
            const AppRowGroup(
              footer: 'Çıkınca oturumun kapanır. Tekrar giriş yapman gerekir.',
              children: [
                AppRow(
                  title: 'Çıkış Yap',
                  icon: PhosphorIconsRegular.signOut,
                  danger: true,
                  onTap: _noop,
                ),
              ],
            ),
          ],
        ),
        const GallerySection(
          title: 'SectionHeader · C19',
          note: 'Başlık 20/28; en çok bir metin düğmesi; "Tümü ›" kalıbı yok.',
          children: [
            SectionHeader(title: 'Son denemelerin', meta: '3 sınav'),
            SectionHeader(
              title: 'Programım',
              actionLabel: 'Programım',
              onAction: _noop,
            ),
            SectionHeader(
              title: 'Öğrencilerim',
              actionLabel: 'Öğrenci Ekle',
              actionIcon: PhosphorIconsRegular.plus,
              onAction: _noop,
            ),
          ],
        ),
        GallerySection(
          title: 'AppAccordion · C50 · pano 1.13',
          note:
              '250 ms açılır, ok 180° döner; açılan bölüm görünür alana '
              'gelir. Hareketi azaltta anında.',
          children: [
            GalleryPanel(
              tone: GalleryTone.canvas,
              child: Column(
                children: [
                  AppAccordion(
                    title: 'Türk Dili ve Edebiyatı-Sosyal Bilimler 1',
                    expanded: _open,
                    onChanged: (v) => setState(() => _open = v),
                    summary: Text(
                      '23 doğru · 17 yanlış · 0 boş',
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                    child: Text(
                      'Açık: ok yukarı, ok zemini dolu. İçerik burada başlar.',
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  AppAccordion(
                    title: 'Sosyal Bilimler 2',
                    summary: Text(
                      '17 doğru · 23 yanlış · 0 boş',
                      style: text.caption.copyWith(color: colors.textSecondary),
                    ),
                    child: Text(
                      'İkinci bölümün gövdesi.',
                      style: text.body.copyWith(color: colors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  AppAccordion(
                    title: 'Cümlenin Öğeleri',
                    indicator: AppAccordionIndicator.plain,
                    child: Text(
                      'Dairesiz ok: konu ve test başlıkları.',
                      style: text.body.copyWith(color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppAccordion · büyük metin ve ekran okuyucu',
          note:
              'Başlık tek okunur: "Konu başlığı, 4 madde, 1 eksik, '
              'daraltılmış" (summaryLabel); gövde ayrı düğüm. Metin 1,35.',
          children: [
            GalleryLargeText(
              child: GalleryPanel(
                tone: GalleryTone.canvas,
                child: AppAccordion(
                  title: 'Türk Dili ve Edebiyatı-Sosyal Bilimler 1',
                  summaryLabel: '4 madde, 1 eksik',
                  summary: Text(
                    '4 madde · 1 eksik',
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                  child: Text(
                    'Gövde burada başlar.',
                    style: text.body.copyWith(color: colors.textPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'AppNoticeBox · C39 · pano 1.4',
          note:
              'Sol şerit yok; metin birincil renkte, ikon tonda. Hata ve '
              'uyarı kutuları duyurulur.',
          children: [
            AppNoticeBox(
              message: 'Deneme sonuçların hazır olunca bildirim göndereceğiz.',
            ),
            AppNoticeBox(
              tone: AppNoticeTone.success,
              message: 'Şifren güncellendi.',
            ),
            AppNoticeBox(
              tone: AppNoticeTone.warning,
              message:
                  'Bildirimler sistem ayarlarında kapalı. Açmak için '
                  'ayarlara git.',
              actionLabel: 'Ayarları Aç',
              onAction: _noop,
            ),
            AppNoticeBox(
              tone: AppNoticeTone.error,
              message: 'Kod doğru değil. Son gelen kodu yazdığından emin ol.',
            ),
          ],
        ),
      ],
    );
  }
}
