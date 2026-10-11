import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/controls/app_checkbox.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/controls/app_chip_group.dart';
import 'package:smap/shared/ui/controls/app_radio.dart';
import 'package:smap/shared/ui/controls/app_switch.dart';
import 'package:smap/shared/ui/controls/app_tag.dart';

void _noop() {}

void _noopBool(bool value) {}

/// Gallery page of the choices: `AppChip` / `AppChipGroup` / `AppFilterPill`
/// (C06, pano 1.11), `AppTag` (C07), `AppCheckbox` (C14), `AppRadio` (C15)
/// and `AppSwitch` (C16, pano 1.13).
class ChoicesGallery extends StatefulWidget {
  const ChoicesGallery({super.key});

  @override
  State<ChoicesGallery> createState() => _ChoicesGalleryState();
}

class _ChoicesGalleryState extends State<ChoicesGallery> {
  final Set<String> _filters = {'ogrenci'};
  var _single = 'tumu';
  var _grade = '12';
  var _subject = 'turkce';
  var _square = 'C';
  var _toggleOn = true;
  var _checkA = false;
  var _checkB = true;
  var _radio = '12';
  var _switchA = false;
  var _switchB = true;

  @override
  Widget build(BuildContext context) {
    final text = context.appText;
    final colors = context.appColors;
    SubjectTone tone(SubjectKey key) => context.appSubject(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppChip · C06 · pano 1.11',
          note:
              'Seçim lacivert, çip içinde onay işareti yok. Süzgeç çoklu, '
              'seçim tekli seçimdir. Pasif çipin nedeni yanına yazılır.',
          children: [
            GalleryState(
              label: 'Filtre çipi · çoklu seçim',
              child: AppChipGroup<String>(
                exclusive: false,
                selected: _filters,
                onChanged: (v) => setState(() {
                  _filters.contains(v) ? _filters.remove(v) : _filters.add(v);
                }),
                items: const [
                  AppChipItem(value: 'ogrenci', label: 'Öğrenci görüşmesi'),
                  AppChipItem(value: 'veli', label: 'Veli görüşmesi'),
                  AppChipItem(value: 'hafta', label: 'Bu hafta'),
                ],
              ),
            ),
            GalleryState(
              label: 'Seçim çipi · tekli',
              child: AppChipGroup<String>(
                selected: {_single},
                onChanged: (v) => setState(() => _single = v),
                items: const [
                  AppChipItem(value: 'tumu', label: 'Tümü'),
                  AppChipItem(value: 'yanlis', label: 'Yanlışlar'),
                  AppChipItem(value: 'bos', label: 'Boşlar'),
                ],
              ),
            ),
            GalleryState(
              label: 'Sınıf (48 boy)',
              child: AppChipGroup<String>(
                size: AppChipSize.lg48,
                selected: {_grade},
                onChanged: (v) => setState(() => _grade = v),
                items: const [
                  AppChipItem(value: '9', label: '9. Sınıf'),
                  AppChipItem(value: '10', label: '10. Sınıf'),
                  AppChipItem(value: '11', label: '11. Sınıf'),
                  AppChipItem(value: '12', label: '12. Sınıf'),
                  AppChipItem(value: 'mezun', label: 'Mezun'),
                ],
              ),
            ),
            GalleryState(
              label: 'Ders çipi (40 boy) · renk yalnız noktada',
              child: AppChipGroup<String>(
                size: AppChipSize.md40,
                selected: {_subject},
                onChanged: (v) => setState(() => _subject = v),
                items: [
                  const AppChipItem(value: 'genel', label: 'Genel'),
                  AppChipItem(
                    value: 'turkce',
                    label: 'Türkçe',
                    dotColor: tone(SubjectKey.turkce).fg,
                  ),
                  AppChipItem(
                    value: 'tarih',
                    label: 'Tarih',
                    dotColor: tone(SubjectKey.tarih).fg,
                  ),
                  AppChipItem(
                    value: 'cografya',
                    label: 'Coğrafya',
                    dotColor: tone(SubjectKey.cografya).fg,
                  ),
                  AppChipItem(
                    value: 'matematik',
                    label: 'Matematik',
                    dotColor: tone(SubjectKey.matematik).fg,
                  ),
                  AppChipItem(
                    value: 'geometri',
                    label: 'Geometri',
                    dotColor: tone(SubjectKey.geometri).fg,
                  ),
                ],
              ),
            ),
            const GalleryState(
              label: 'Pasif · odak',
              child: GalleryWrap(
                children: [
                  AppChip(label: 'Dil', onTap: null),
                  AppFocusRing(
                    focused: true,
                    borderRadius: AppRadius.borderFull,
                    child: AppChip(label: 'Bu hafta', onTap: _noop),
                  ),
                  AppChip(label: 'Seçili', selected: true, onTap: _noop),
                ],
              ),
            ),
            GalleryState(
              label: 'Kare seçim çipi (şık)',
              child: Wrap(
                spacing: AppSpacing.s8,
                children: [
                  for (final option in const ['A', 'B', 'C', 'D', 'E'])
                    AppChip.square(
                      label: option,
                      selected: _square == option,
                      onTap: () => setState(() => _square = option),
                    ),
                  AppChip.square(
                    label: 'Boş',
                    width: 64,
                    selected: _square == 'Boş',
                    onTap: () => setState(() => _square = 'Boş'),
                  ),
                ],
              ),
            ),
            const GalleryState(
              label: 'Boylar: 36 · 40 · 48',
              child: GalleryWrap(
                children: [
                  AppChip(label: 'Küçük', onTap: _noop),
                  AppChip(label: 'Orta', size: AppChipSize.md40, onTap: _noop),
                  AppChip(label: 'Büyük', size: AppChipSize.lg48, onTap: _noop),
                ],
              ),
            ),
            GalleryState(
              label: 'AppFilterPill',
              child: GalleryWrap(
                children: [
                  const AppFilterPill(
                    label: 'TYT · Genel',
                    opensSheet: true,
                    onTap: _noop,
                  ),
                  AppFilterPill(
                    label: 'Eksiklerim (31)',
                    icon: PhosphorIconsRegular.flag,
                    selected: _toggleOn,
                    onTap: () => setState(() => _toggleOn = !_toggleOn),
                  ),
                ],
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'AppTag · C07 · pano 1.11',
          note:
              'Yalnız bilgi verir, dokunulmaz, nötr. Sayı taşıyan etiket '
              'ne saydığını söyler.',
          children: [
            GalleryWrap(
              children: [
                AppTag(label: 'AYT'),
                AppTag(label: 'TYT'),
                AppTag(label: 'SOS-2'),
                AppTag(label: '31 eksik'),
                AppTag(label: 'Az soru'),
                AppTag(
                  label: 'Web\'de',
                  icon: PhosphorIconsRegular.arrowSquareOut,
                ),
                AppTag(label: 'Bu hafta', dot: true),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'AppCheckbox · C14 · pano 1.13',
          note: 'Kutu 24, bütün satır dokunulabilir; etiket kutudan 12 uzakta.',
          children: [
            AppCheckbox(
              value: _checkA,
              label: 'Bir daha gösterme',
              onChanged: (v) => setState(() => _checkA = v),
            ),
            AppCheckbox(
              value: _checkB,
              labelChild: Text.rich(
                TextSpan(
                  style: text.body.copyWith(color: colors.textPrimary),
                  children: [
                    TextSpan(
                      text: 'Kullanım Koşulları\'nı',
                      style: text.bodyStrong.copyWith(
                        color: colors.textAction,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' ve '),
                    TextSpan(
                      text: 'KVKK Aydınlatma Metni\'ni',
                      style: text.bodyStrong.copyWith(
                        color: colors.textAction,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' okudum'),
                  ],
                ),
              ),
              onChanged: (v) => setState(() => _checkB = v),
            ),
            const AppCheckbox(
              value: false,
              label: 'Pasif seçenek',
              onChanged: null,
            ),
            const AppCheckbox(
              value: true,
              label: 'Pasif, işaretli',
              onChanged: null,
            ),
          ],
        ),
        GallerySection(
          title: 'AppRadio · C15 · pano 1.13',
          note:
              'Seçili: içe 7 pt halka (pano 2.2). Sheet içi satır en az 56; '
              'seçim anında olur, ayrı onay yok.',
          children: [
            AppRadioGroup<String>(
              semanticLabel: 'Sınıf',
              groupValue: _radio,
              onChanged: (v) => setState(() => _radio = v),
              options: const [
                (value: '11', title: '11. Sınıf'),
                (value: '12', title: '12. Sınıf'),
                (value: 'mezun', title: 'Mezun'),
              ],
            ),
            GalleryWrap(
              children: [
                AppRadio<String>(
                  value: 'a',
                  groupValue: _radio,
                  semanticLabel: 'Seçenek A',
                  onChanged: (v) => setState(() => _radio = v),
                ),
                AppRadio<String>(
                  value: '12',
                  groupValue: _radio,
                  semanticLabel: 'Seçenek B',
                  onChanged: (v) => setState(() => _radio = v),
                ),
                const AppRadio<String>(
                  value: 'c',
                  groupValue: 'c',
                  semanticLabel: 'Pasif seçili',
                  onChanged: null,
                ),
                const AppRadio<String>(
                  value: 'd',
                  groupValue: 'c',
                  semanticLabel: 'Pasif',
                  onChanged: null,
                ),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'AppSwitch · C16 · pano 1.13',
          note:
              '52 x 32; açıkken onaylı baş. Değişiklik anında kaydedilir. '
              'Sırayla: kapalı, açık, odak, pasif kapalı, pasif açık.',
          children: [
            GalleryWrap(
              children: [
                AppSwitch(
                  value: _switchA,
                  semanticLabel: 'Hatırlatıcı',
                  onChanged: (v) => setState(() => _switchA = v),
                ),
                AppSwitch(
                  value: _switchB,
                  semanticLabel: 'Deneme sonucun hazır',
                  onChanged: (v) => setState(() => _switchB = v),
                ),
                const AppFocusRing(
                  focused: true,
                  borderRadius: AppRadius.borderFull,
                  child: AppSwitch(
                    value: true,
                    semanticLabel: 'Odak',
                    onChanged: _noopBool,
                  ),
                ),
                const AppSwitch(
                  value: false,
                  semanticLabel: 'Pasif',
                  onChanged: null,
                ),
                const AppSwitch(
                  value: true,
                  semanticLabel: 'Pasif açık',
                  onChanged: null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
