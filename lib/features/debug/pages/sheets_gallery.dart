import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/subject_tone.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_chip_group.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/inputs/app_select_field.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/pickers/app_time_wheel.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';
import 'package:smap/shared/ui/sheets/app_sheet.dart';
import 'package:smap/shared/ui/sheets/coming_soon_sheet.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

/// Gallery page of the layers: `AppSheet` and its frame (C71, pano 1.20),
/// `AppConfirmSheet` (C72, pano 1.21), `ComingSoonSheet` (C73),
/// `AppSelectField` (C12, pano 1.12) and `AppTimeWheel` (C66, pano 9.6).
/// Every button opens a real sheet; the last result is written under the
/// buttons so the typed results can be seen.
class SheetsGallery extends StatefulWidget {
  const SheetsGallery({super.key});

  @override
  State<SheetsGallery> createState() => _SheetsGalleryState();
}

class _SheetsGalleryState extends State<SheetsGallery> {
  String _result = 'Henüz bir sheet açılmadı.';
  String? _grade = '10';
  TimeOfDay _quiet = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wheel = const TimeOfDay(hour: 7, minute: 5);

  static const _grades = [
    AppSelectOption(value: '9', label: '9. Sınıf'),
    AppSelectOption(value: '10', label: '10. Sınıf'),
    AppSelectOption(value: '11', label: '11. Sınıf'),
    AppSelectOption(value: '12', label: '12. Sınıf'),
    AppSelectOption(value: 'mezun', label: 'Mezun'),
  ];

  void _say(String text) {
    if (mounted) setState(() => _result = text);
  }

  Future<void> _small() async {
    final result = await AppSheet.show<String>(
      context: context,
      builder: (_) => const _WebSheet(),
    );
    _say('Küçük sheet: ${result ?? 'kapatıldı (null)'}');
  }

  Future<void> _medium() async {
    final result = await AppSheet.show<String>(
      context: context,
      size: AppSheetSize.medium,
      builder: (_) => const _FilterSheet(),
    );
    _say('Orta sheet: ${result ?? 'kapatıldı (null)'}');
  }

  Future<void> _full({required bool failFirst}) async {
    final result = await AppSheet.show<String>(
      context: context,
      size: AppSheetSize.full,
      builder: (_) => _StudentSheet(failFirst: failFirst),
    );
    _say('Tam boy sheet: ${result ?? 'kapatıldı (null)'}');
  }

  Future<void> _confirm({required bool danger}) async {
    final ConfirmResult result;
    if (danger) {
      result = await AppConfirmSheet.show(
        context: context,
        title: 'Koç bağlantısı kaldırılsın mı?',
        message:
            'Mehmet Özkan gelişimini artık göremeyecek. Yeniden '
            'bağlanmak için koçluk kodunu tekrar girmen gerekir.',
        confirmLabel: 'Bağlantıyı Kaldır',
        danger: true,
      );
    } else {
      result = await AppConfirmSheet.show(
        context: context,
        title: "Kartı Bildiklerim'e taşıyalım mı?",
        message:
            '"Edirne-Segedin Antlaşması (1444)" eksiklerinden çıkıp '
            "Bildiklerim'e geçecek.",
        confirmLabel: 'Öğrendim',
        dontAskAgainLabel: 'Bir daha sorma',
      );
    }
    _say('Onay: $result');
  }

  Future<void> _quietHours() async {
    final picked = await AppTimeWheelSheet.show(
      context: context,
      title: 'Sessiz saat başlangıcı',
      saveLabel: 'Kaydet',
      initial: _quiet,
    );
    if (!mounted) return;
    if (picked != null) setState(() => _quiet = picked);
    _say('Saat sheet: ${picked?.format(context) ?? 'kapatıldı (null)'}');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppSheet · C71 · pano 1.20',
          note:
              'Tutamaç, başlık + Kapat, kaydırılan içerik, sabit eylem alanı. '
              'Aşağı %25 sürükle ya da hızlı fırlat: kapanır. Perde %48 '
              '(koyu %64) + 8 pt bulanıklık. 350 / 250 ms; hareketi azaltta '
              '150 ms opaklık.',
          children: [
            GalleryState(
              label: 'Küçük · içeriğe göre (kare 1)',
              child: AppButton(
                label: 'Küçük sheet',
                variant: AppButtonVariant.outline,
                onPressed: _small,
              ),
            ),
            GalleryState(
              label: 'Orta · seçim (kare 2)',
              child: AppButton(
                label: 'Orta sheet',
                variant: AppButtonVariant.outline,
                onPressed: _medium,
              ),
            ),
            GalleryState(
              label: 'Tam boy · form, klavye ve ayraç (kare 3, 4)',
              child: AppButton(
                label: 'Tam boy sheet',
                variant: AppButtonVariant.outline,
                onPressed: () => _full(failFirst: false),
              ),
            ),
            GalleryState(
              label:
                  'Meşgul (kare 5): Kaydet 4 sn meşgul eder; kapat, sürükle, '
                  'perde ve geri çalışmaz. İlk deneme hata ile döner ve '
                  'girilenler korunur.',
              child: AppButton(
                label: 'Meşgul sheet (ilk kayıt hata verir)',
                variant: AppButtonVariant.outline,
                onPressed: () => _full(failFirst: true),
              ),
            ),
            GalleryPanel(tone: GalleryTone.canvas, child: GalleryNote(_result)),
          ],
        ),
        GallerySection(
          title: 'AppConfirmSheet · C72 · pano 1.21',
          note:
              'Soru başlığı cümle düzeninde, birincil eylemin adı fiil, altta '
              '"Vazgeç". Tehlikeli ton: kırmızı düğme, odak Vazgeç\'te. '
              'Perdeye dokunmak Vazgeç sayılır.',
          children: [
            AppButton(
              label: 'Normal onay',
              variant: AppButtonVariant.outline,
              onPressed: () => _confirm(danger: false),
            ),
            AppButton(
              label: 'Tehlikeli onay',
              variant: AppButtonVariant.outline,
              onPressed: () => _confirm(danger: true),
            ),
          ],
        ),
        GallerySection(
          title: 'ComingSoonSheet · C73 · pano 1.21 kare 3',
          note: 'Yalnız kitte durur; hiçbir ekranda ya da menüde kullanılmaz.',
          children: [
            AppButton(
              label: 'Yakında sheet',
              variant: AppButtonVariant.outline,
              onPressed: () => ComingSoonSheet.show(context: context),
            ),
          ],
        ),
        GallerySection(
          title: 'AppSelectField · C12 · pano 1.12',
          note:
              'Dokununca AppSheet içinde AppRadioListTile satırları açar; '
              'seçince kapanır. Pasif alan nedeni söyler.',
          children: [
            AppSelectField<String>(
              label: 'Sınıf',
              options: _grades,
              value: _grade,
              onChanged: (value) => setState(() => _grade = value),
            ),
            const AppSelectField<String>(
              label: 'Alan',
              options: [],
              value: null,
              enabled: false,
              disabledValueText: 'Seçilmez',
              helperText: '9. ve 10. sınıfta alan seçilmez.',
              onChanged: null,
            ),
            AppSelectField<String>(
              label: 'Ders',
              options: _grades,
              value: null,
              errorText: 'Bir ders seç.',
              onChanged: (_) {},
            ),
          ],
        ),
        GallerySection(
          title: 'AppTimeWheel · C66 · pano 9.6',
          note:
              'Saat 0–23 ve dakika 5\'er adım, ikisi de döner. Seçili satır '
              '24/40 · 700, bant 44 pt. Ekran okuyucuda ayarlanabilir: '
              'yukarı / aşağı 5 dk.',
          children: [
            GalleryPanel(
              tone: GalleryTone.raised,
              child: AppTimeWheel(
                value: _wheel,
                onChanged: (value) => _wheel = value,
              ),
            ),
            AppButton(
              label: 'Sessiz saat başlangıcı · ${_quiet.format(context)}',
              variant: AppButtonVariant.outline,
              onPressed: _quietHours,
            ),
          ],
        ),
      ],
    );
  }
}

/// Board 1.20 kare 1: "Matematik ve Geometri", small, two actions.
class _WebSheet extends StatelessWidget {
  const _WebSheet();

  @override
  Widget build(BuildContext context) {
    return AppSheetFrame(
      title: 'Matematik ve Geometri',
      subtitle: "Matematik ve Geometri kavram haritan şimdilik smaptr.com'da.",
      body: const SizedBox(height: AppSpacing.s16),
      primary: AppSheetAction(
        label: "Web'de Aç",
        trailingIcon: PhosphorIconsRegular.arrowSquareOut,
        onPressed: () => Navigator.of(context).pop('Web\'de Aç'),
      ),
      secondary: AppSheetAction(
        label: 'Tamam',
        variant: AppButtonVariant.quiet,
        onPressed: () => Navigator.of(context).pop('Tamam'),
      ),
    );
  }
}

/// Board 1.20 kare 2: the filter sheet, medium.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String _exam = 'tyt';
  String _lesson = 'genel';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    Widget title(String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Text(
        value,
        style: text.labelMd.copyWith(color: colors.textPrimary),
      ),
    );
    final lessons = <(String, String, SubjectKey?)>[
      ('genel', 'Genel', null),
      ('turkce', 'Türkçe', SubjectKey.turkce),
      ('tarih', 'Tarih', SubjectKey.tarih),
      ('cografya', 'Coğrafya', SubjectKey.cografya),
      ('matematik', 'Matematik', SubjectKey.matematik),
    ];
    return AppSheetFrame(
      title: 'Filtre',
      subtitle: 'Grafik ve istatistikler bu seçime göre.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title('Sınav türü'),
          AppSegmented<String>(
            segments: const [
              AppSegment(value: 'tyt', label: 'TYT'),
              AppSegment(value: 'ayt', label: 'AYT'),
            ],
            value: _exam,
            onChanged: (value) => setState(() => _exam = value),
          ),
          const SizedBox(height: _gap20),
          title('Ders'),
          AppChipGroup<String>(
            focusGapColor: colors.bgRaised,
            selected: {_lesson},
            onChanged: (value) => setState(() => _lesson = value),
            items: [
              for (final (value, label, subject) in lessons)
                AppChipItem(
                  value: value,
                  label: label,
                  dotColor: subject == null
                      ? null
                      : context.appSubject(subject).fg,
                ),
            ],
          ),
        ],
      ),
      primary: AppSheetAction(
        label: 'Uygula',
        onPressed: () => Navigator.of(context).pop('$_exam · $_lesson'),
      ),
    );
  }
}

/// Board 1.20 kare 3, 4 and 5: the full-height form with the busy state.
class _StudentSheet extends StatefulWidget {
  const _StudentSheet({required this.failFirst});

  final bool failFirst;

  @override
  State<_StudentSheet> createState() => _StudentSheetState();
}

class _StudentSheetState extends State<_StudentSheet> {
  final _name = TextEditingController(text: 'Mert');
  final _surname = TextEditingController(text: 'Yıldız');
  final _user = TextEditingController();
  String? _grade = '10';
  bool _busy = false;
  bool _failed = false;
  late bool _willFail = widget.failFirst;

  @override
  void dispose() {
    _name.dispose();
    _surname.dispose();
    _user.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    await Future<void>.delayed(SmapDurations.toast);
    if (!mounted) return;
    if (_willFail) {
      // The sheet stays open and the input is kept.
      setState(() {
        _busy = false;
        _failed = true;
        _willFail = false;
      });
      return;
    }
    Navigator.of(context).pop('${_name.text} ${_surname.text}');
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetFrame(
      title: 'Öğrenci Ekle',
      subtitle: _busy
          ? 'Kaydediliyor. Birkaç saniye sürebilir.'
          : 'Hesabı sen açarsın; öğrenci bu bilgilerle giriş yapar.',
      busy: _busy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_failed) ...[
            const AppNoticeBox(
              tone: AppNoticeTone.error,
              message: 'Kaydedilemedi. Bağlantını kontrol edip tekrar dene.',
            ),
            const SizedBox(height: _gap20),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(label: 'Ad', controller: _name),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: AppTextField(label: 'Soyad', controller: _surname),
              ),
            ],
          ),
          const SizedBox(height: _gap20),
          AppTextField(
            label: 'Kullanıcı adı',
            controller: _user,
            hintText: 'Örn: mert.yildiz',
          ),
          const SizedBox(height: _gap20),
          const AppTextField(
            label: 'Şifre',
            password: true,
            hintText: 'En az 8 karakter',
          ),
          const SizedBox(height: _gap20),
          AppSelectField<String>(
            label: 'Sınıf',
            options: _SheetsGalleryState._grades,
            value: _grade,
            onChanged: (value) => setState(() => _grade = value),
          ),
          const SizedBox(height: _gap20),
          const AppSelectField<String>(
            label: 'Alan',
            options: [],
            value: null,
            enabled: false,
            disabledValueText: 'Seçilmez',
            helperText: '9. ve 10. sınıfta alan seçilmez.',
            onChanged: null,
          ),
          const SizedBox(height: AppSpacing.s24),
          Text(
            'İçerik kaydırılınca eylem alanının üstünde ayraç belirir.',
            style: context.appText.caption.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: _scrollFiller),
        ],
      ),
      primary: AppSheetAction(label: 'Öğrenciyi Kaydet', onPressed: _save),
    );
  }
}

/// The 20 pt gap between the items of a sheet body (C71 "öğeler arası 20").
const double _gap20 = 20;

/// Extra height that makes the demo body scroll under the button band.
const double _scrollFiller = 240;
