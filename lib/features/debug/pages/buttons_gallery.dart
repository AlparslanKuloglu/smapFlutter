import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/buttons/press_scale.dart';

void _noop() {}

/// Gallery page of the buttons: `AppButton` (C01, pano 1.9), `AppIconButton`
/// (C02), `AppBarAction` (C03, pano 1.18) and `PressScale` (pano 1.8).
class ButtonsGallery extends StatelessWidget {
  const ButtonsGallery({super.key});

  static const _variants = <(AppButtonVariant, String)>[
    (AppButtonVariant.primary, 'Detaylı Analiz'),
    (AppButtonVariant.outline, 'Tekrar Çek'),
    (AppButtonVariant.quiet, 'Vazgeç'),
    (AppButtonVariant.danger, 'Hesabı Sil'),
    (AppButtonVariant.text, 'Şifremi Unuttum'),
    (AppButtonVariant.textDanger, 'Hesabı Kapat'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppButton 48 · C01 · pano 1.9',
          note:
              'Bir ekranda bir birincil düğme. Basılı hâl için düğmeye bas ve '
              'tut: bir ton koyulaşır, 0,98 ölçeğe iner. Odak halkası klavyede '
              'Tab ile de görülür.',
          children: [
            for (final (variant, label) in _variants)
              GalleryState(
                label: variant.name,
                child: GalleryWrap(
                  children: [
                    AppButton(label: label, variant: variant, onPressed: _noop),
                    AppFocusRing(
                      focused: true,
                      style:
                          variant == AppButtonVariant.text ||
                              variant == AppButtonVariant.textDanger
                          ? AppFocusRingStyle.flush
                          : AppFocusRingStyle.gapped,
                      child: AppButton(
                        label: label,
                        variant: variant,
                        onPressed: _noop,
                      ),
                    ),
                    AppButton(
                      label: label,
                      variant: variant,
                      loading: true,
                      onPressed: _noop,
                    ),
                    AppButton(label: label, variant: variant, onPressed: null),
                  ],
                ),
              ),
            const GalleryNote(
              'Sırayla: varsayılan, odak, yükleniyor (metin düğmeleri '
              'yüklenmez), pasif.',
            ),
          ],
        ),
        GallerySection(
          title: 'AppButton 40 · C01',
          note:
              'Yalnız satır ve kart içinde. Görünür yükseklik 40, dokunma 48.',
          children: [
            GalleryWrap(
              children: [
                for (final (variant, label) in const [
                  (AppButtonVariant.primary, 'Analizi Gör'),
                  (AppButtonVariant.outline, 'Düzenle'),
                  (AppButtonVariant.quiet, 'Yeni Fotoğraf'),
                  (AppButtonVariant.danger, 'Notu Sil'),
                  (AppButtonVariant.text, 'Tümünü Gör'),
                ])
                  AppButton(
                    label: label,
                    variant: variant,
                    size: AppButtonSize.md40,
                    onPressed: _noop,
                  ),
              ],
            ),
            const GalleryWrap(
              children: [
                AppButton(
                  label: 'Yükleniyor',
                  size: AppButtonSize.md40,
                  loading: true,
                  onPressed: _noop,
                ),
                AppButton(
                  label: 'Pasif',
                  size: AppButtonSize.md40,
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
        const GallerySection(
          title: 'Simgeli, tam genişlik, pasif nedeni',
          note:
              'İkon 20 pt, etiketten 8 pt uzakta. Baş ikonlu: sol 16 / sağ 20; '
              'son ikonlu: sol 20 / sağ 16.',
          children: [
            GalleryWrap(
              children: [
                AppButton(
                  label: 'İlk Denemeni Okut',
                  icon: PhosphorIconsRegular.camera,
                  onPressed: _noop,
                ),
                AppButton(
                  label: 'Web\'de Aç',
                  variant: AppButtonVariant.outline,
                  trailingIcon: PhosphorIconsRegular.arrowSquareOut,
                  onPressed: _noop,
                ),
              ],
            ),
            AppButton(label: 'Devam Et', expand: true, onPressed: _noop),
            AppButton(
              label: 'Kodu Tekrar Gönder (0:24)',
              variant: AppButtonVariant.text,
              onPressed: null,
              disabledReason: 'Kod 30 saniye sonra yeniden gönderilebilir.',
            ),
          ],
        ),
        const GallerySection(
          title: 'AppIconButton · C02 · pano 1.9',
          note:
              '48 x 48 hedef; ad ve ipucu zorunlu (uzun bas: ipucu). Favori '
              'düğmesi Star ile Star Fill arasında döner.',
          children: [
            GalleryWrap(
              children: [
                GalleryState(
                  label: 'plain',
                  child: AppIconButton(
                    icon: PhosphorIconsRegular.caretLeft,
                    semanticLabel: 'Geri',
                    onPressed: _noop,
                  ),
                ),
                GalleryState(
                  label: 'close',
                  child: AppIconButton(
                    icon: PhosphorIconsRegular.x,
                    semanticLabel: 'Kapat',
                    variant: AppIconButtonVariant.close,
                    onPressed: _noop,
                  ),
                ),
                GalleryState(
                  label: 'favori',
                  child: AppIconButton(
                    icon: PhosphorIconsRegular.star,
                    selectedIcon: PhosphorIconsFill.star,
                    selected: true,
                    semanticLabel: 'Favorilerden çıkar',
                    onPressed: _noop,
                  ),
                ),
                GalleryState(
                  label: 'odak',
                  child: AppFocusRing(
                    focused: true,
                    child: AppIconButton(
                      icon: PhosphorIconsRegular.slidersHorizontal,
                      semanticLabel: 'Filtrele',
                      onPressed: _noop,
                    ),
                  ),
                ),
                GalleryState(
                  label: 'pasif',
                  child: AppIconButton(
                    icon: PhosphorIconsRegular.slidersHorizontal,
                    semanticLabel: 'Filtrele',
                    onPressed: null,
                  ),
                ),
              ],
            ),
            GalleryPanel(
              tone: GalleryTone.navy,
              child: GalleryWrap(
                children: [
                  AppIconButton(
                    icon: PhosphorIconsRegular.bell,
                    semanticLabel: 'Bildirimler',
                    variant: AppIconButtonVariant.onNavy,
                    onPressed: _noop,
                  ),
                  AppIconButton(
                    icon: PhosphorIconsRegular.plus,
                    semanticLabel: 'Yeni görüşme',
                    variant: AppIconButtonVariant.onNavy,
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'AppBarAction · C03 · pano 1.18',
          note:
              'Detay barının sağındaki tek eylem: 40 yüksek, 14 yan dolgu. '
              'Alan yanında 48 yüksek.',
          children: [
            GalleryWrap(
              children: [
                AppBarAction(label: 'Düzenle', onPressed: _noop),
                AppBarAction(
                  label: 'Yeni Program',
                  icon: PhosphorIconsRegular.plus,
                  onPressed: _noop,
                ),
                AppBarAction(
                  label: 'Kaydet',
                  style: AppBarActionStyle.filled,
                  onPressed: _noop,
                ),
                AppBarAction(
                  label: 'Kaydet',
                  style: AppBarActionStyle.filled,
                  onPressed: null,
                ),
                AppBarAction(
                  label: 'Kontrol Et',
                  field: true,
                  onPressed: _noop,
                ),
                AppFocusRing(
                  focused: true,
                  child: AppBarAction(label: 'Bitti', onPressed: _noop),
                ),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'PressScale · pano 1.8',
          note:
              'Bas ve tut: 0,98 (düğme, satır), 0,97 (hücre), 0,92 '
              '(deklanşör). Hareketi azaltta ölçek yok.',
          children: [
            GalleryWrap(
              children: [
                for (final (scale, label) in const [
                  (AppMotion.pressedScale, '0,98'),
                  (PressScale.cellScale, '0,97'),
                  (AppMotion.shutterScale, '0,92'),
                ])
                  PressScale(
                    scale: scale,
                    child: GalleryPanel(
                      tone: GalleryTone.navy,
                      child: SizedBox(
                        width: AppSpacing.s64,
                        child: GalleryOnNavyLabel(label),
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
