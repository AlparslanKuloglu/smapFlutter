import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/turkish_text.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/inputs/app_code_input.dart';
import 'package:smap/shared/ui/inputs/app_search_field.dart';
import 'package:smap/shared/ui/inputs/app_text_area.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/inputs/input_masks.dart';
import 'package:smap/shared/ui/text/highlight_text.dart';

/// Gallery page of the inputs: `AppTextField` (C09), `AppSearchField` (C10),
/// `AppCodeInput` (C11), `AppTextArea` (C13), pano 1.12 "Girdiler · 6 tür ·
/// 5 durum".
class InputsGallery extends StatefulWidget {
  const InputsGallery({super.key});

  @override
  State<InputsGallery> createState() => _InputsGalleryState();
}

class _InputsGalleryState extends State<InputsGallery> {
  static const _people = [
    'Alparslan Kuloğlu',
    'Mehmet Özkan',
    'Elif Şahin',
    'Kerem Aydın',
    'Zeynep Kaya',
    'Işıl Yıldız',
    'İlker Çelik',
  ];

  final _name = TextEditingController(text: 'Alparslan Kuloğlu');
  final _user = TextEditingController(text: 'alparslan.k');
  final _search = TextEditingController();
  final _searchFilled = TextEditingController(text: 'Elif');
  final _note = TextEditingController(
    text: 'Tarih eksikleri için haftada 3 saat ayrıldı.',
  );
  final _code = TextEditingController(text: '52');
  var _query = '';
  var _codeError = false;
  var _shake = 0;

  @override
  void dispose() {
    _name.dispose();
    _user.dispose();
    _search.dispose();
    _searchFilled.dispose();
    _note.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final matches = [
      for (final person in _people)
        if (TurkishText.matchesTokens(person, _query)) person,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppTextField · C09 · pano 1.12',
          note:
              'Etiket her zaman üstte; placeholder yalnız "Örn: …". Odak ve '
              'hata kenarı 2 pt, alan sarsılmaz. Dolu değer önceden gelmez '
              '(buradaki örnekler yalnız galeri içindir). Odak için alana '
              'dokun.',
          children: [
            AppTextField(label: 'Ad Soyad', controller: _name),
            const AppTextField(
              label: 'Yayınevi',
              hintText: 'Örn: Bilgi Sarmal',
            ),
            const AppTextField(
              label: 'E-posta',
              errorText: 'E-posta adresi eksik görünüyor. Örn: ad@alan.com',
            ),
            const AppTextField(
              label: 'Şifre',
              password: true,
              helperText: 'En az 8 karakter.',
            ),
            AppTextField(
              label: 'Kullanıcı adı',
              controller: _user,
              successText: 'Bu kullanıcı adı boşta.',
            ),
            const AppTextField(label: 'Kullanıcı adı', checking: true),
            AppTextField(
              label: 'Kullanıcı adı',
              controller: _user,
              readOnly: true,
              helperText: 'Metin tam kontrastta kalır; pasiften farkı bu.',
            ),
            const AppTextField(
              label: 'Alan',
              hintText: 'Seçilmez',
              enabled: false,
              helperText: '9. ve 10. sınıfta alan seçilmez.',
            ),
            const AppTextField(label: 'Not', optional: true),
            AppTextField(
              label: 'Telefon',
              prefixText: '+90',
              hintText: 'Örn: 5XX XXX XX XX',
              keyboardType: TextInputType.number,
              inputFormatters: [AppInputMasks.phone],
            ),
            AppTextField(
              label: 'Koçluk kodu',
              hintText: 'Örn: MOZK-4821',
              inputFormatters: [AppInputMasks.coachCode],
            ),
          ],
        ),
        GallerySection(
          title: 'AppSearchField · C10 · pano 1.12',
          note:
              'Türkçe katlama: "isil" Işıl\'ı, "ilker" İlker\'i bulur. Eşleşme '
              'vurgulanır; 150 ms sonra sorgu bildirilir.',
          children: [
            AppSearchField(
              semanticLabel: 'Öğrenci ara',
              hintText: 'Öğrenci ara',
              controller: _search,
              onQueryChanged: (value) => setState(() => _query = value),
            ),
            GalleryPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final person in matches)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s4,
                      ),
                      child: HighlightText(text: person, query: _query),
                    ),
                  if (matches.isEmpty)
                    Text(
                      'Eşleşen öğrenci yok',
                      style: text.titleSm.copyWith(color: colors.textPrimary),
                    ),
                ],
              ),
            ),
            AppSearchField(
              semanticLabel: 'Program ara',
              hintText: 'Program ara',
              controller: _searchFilled,
            ),
          ],
        ),
        GallerySection(
          title: 'AppTextArea · C13 · pano 1.12',
          note: 'En az 104 yükseklik, sayaç sağda.',
          children: [
            AppTextArea(
              label: 'Görüşme notu',
              controller: _note,
              maxLength: 500,
            ),
            const AppTextArea(
              label: 'Not',
              optional: true,
              hintText: 'Örn: Veli ile konuşuldu',
              errorText:
                  'Not kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
            ),
          ],
        ),
        GallerySection(
          title: 'AppCodeInput · C11 · pano 1.12',
          note:
              'Altı kutu; yapıştırma ya da tek kullanımlık kod altısını birden '
              'doldurur (kutulara uzun bas: panodan yapıştır). Hatada 150 ms '
              'sallanır ve hata titreşimi verir; hareketi azaltta sallanma '
              'yok.',
          children: [
            AppCodeInput(
              label: 'Doğrulama kodu',
              controller: _code,
              helperText: 'Kodu alparslan@ornek.com adresine gönderdik.',
              errorText: _codeError
                  ? 'Kod doğru değil. Son gelen kodu yazdığından emin ol.'
                  : null,
              errorShake: _shake,
              onChanged: (_) {
                if (_codeError) setState(() => _codeError = false);
              },
            ),
            AppButton(
              label: 'Hatayı Göster',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.md40,
              onPressed: () => setState(() {
                _codeError = true;
                _shake++;
              }),
            ),
            const AppCodeInput(label: 'Doğrulama kodu', enabled: false),
          ],
        ),
      ],
    );
  }
}
