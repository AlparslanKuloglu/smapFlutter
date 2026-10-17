import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/features/debug/launch_env.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/controls/app_chip.dart';
import 'package:smap/shared/ui/feedback/app_empty_state.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_offline_strip.dart';
import 'package:smap/shared/ui/feedback/app_skeleton.dart';
import 'package:smap/shared/ui/feedback/app_status_view.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/illustrations/app_clay.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

void _noop() {}

/// Gallery page of the status patterns: `ToastService` + `AppToast` (C74,
/// pano 1.22 kare 1), `AppSkeleton` with the 15 s limit (C76, kare 2),
/// `AppEmptyState` (C77, kare 3, 4), `AppErrorState` (C78, kare 4, 5),
/// `AppStatusView` (C79, panos 2.7, 4.10, 9.4) and `AppOfflineStrip` (C75,
/// kare 6; pano 1.24 kare 5 in dark).
class FeedbackGallery extends StatefulWidget {
  const FeedbackGallery({super.key});

  @override
  State<FeedbackGallery> createState() => _FeedbackGalleryState();
}

class _FeedbackGalleryState extends State<FeedbackGallery> {
  late final ToastService _toast = ToastService(
    presenter: OverlayToastPresenter.context(context),
  );
  final ValueNotifier<bool> _online = ValueNotifier<bool>(true);
  Timer? _tick;
  var _barVisible = false;
  var _undone = 0;
  var _retries = 0;
  AsyncSection<String> _section = const AsyncSection.ready('Hazır');
  int _waited = 0;

  @override
  void initState() {
    super.initState();
    // `GALLERY_ACTION` shows one toast (or the offline strip) at start, for
    // a screenshot run.
    final action = debugLaunchEnv('GALLERY_ACTION');
    if (action == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case 'toastInfo':
          _toast.info((_) => 'Sonucun hazır olunca bildirim gelecek.');
        case 'toastSuccess':
          _toast.success((_) => 'Program kaydedildi.');
        case 'toastError':
          _toast.error(
            (_) => 'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
          );
        case 'toastUndo':
          _toast.undo((_) => "Kart Bildiklerim'e taşındı.", onUndo: () {});
        case 'offline':
          _online.value = false;
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _toast.dismiss();
    _online.dispose();
    super.dispose();
  }

  void _setBar(bool value) {
    setState(() => _barVisible = value);
    _toast.bottomBarHeight.value = value ? AppSize.bottomBar : null;
  }

  Future<void> _load({required bool arrives}) async {
    _tick?.cancel();
    setState(() {
      _section = const AsyncSection.loading();
      _waited = 0;
    });
    _tick = Timer.periodic(AppMotion.loop * 0.8334, (_) {
      if (mounted) setState(() => _waited++);
    });
    final result = await AsyncSection.load<String>(
      () => arrives
          ? Future.delayed(SmapDurations.connectedNotice, () => 'Veri geldi')
          : Completer<String>().future,
    );
    _tick?.cancel();
    if (mounted) setState(() => _section = result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'ToastService + AppToast · C74 · pano 1.22',
          note:
              'Tek toast; 4 sn, Geri Al ile 6 sn. Alt çubuğun 8 pt üstünde '
              '(çubuk yoksa güvenli alan + 16). Yukarı kaydırınca kapanır. '
              'Ekran okuyucu açıkken kapanmaz ve Kapat düğmesi çıkar. Koyu '
              'temada ters yüzey.',
          children: [
            GalleryState(
              label: 'Çubuk yüksekliği parametresi',
              child: AppChip(
                label: 'Alt çubuk var (68 pt)',
                selected: _barVisible,
                onTap: () => _setBar(!_barVisible),
              ),
            ),
            GalleryWrap(
              children: [
                AppButton(
                  label: 'Bilgi',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.md40,
                  onPressed: () => _toast.info(
                    (_) => 'Sonucun hazır olunca bildirim gelecek.',
                  ),
                ),
                AppButton(
                  label: 'Başarı',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.md40,
                  onPressed: () => _toast.success((_) => 'Program kaydedildi.'),
                ),
                AppButton(
                  label: 'Hata',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.md40,
                  onPressed: () => _toast.error(
                    (_) =>
                        'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
                  ),
                ),
                AppButton(
                  label: 'Geri Al',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.md40,
                  onPressed: () => _toast.undo(
                    (_) => "Kart Bildiklerim'e taşındı.",
                    onUndo: () => setState(() => _undone++),
                  ),
                ),
              ],
            ),
            GalleryNote('Geri Al kaç kez çalıştı: $_undone'),
          ],
        ),
        GallerySection(
          title: 'AppSkeleton · C76 · pano 1.22 kare 2',
          note:
              '1200 ms parıltı; hareketi azaltta düz bgSunken. 15 sn içinde '
              'veri gelmezse hata durumu; sonsuz iskelet yok.',
          children: [
            const GalleryState(label: 'İskelet', child: _SkeletonDemo()),
            GalleryState(
              label:
                  '15 sn kuralı · durum: ${_section.state.name}'
                  '${_section.isLoading ? ' · $_waited sn' : ''}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GalleryWrap(
                    children: [
                      AppButton(
                        label: 'Veri 2 sn sonra gelir',
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.md40,
                        onPressed: () => _load(arrives: true),
                      ),
                      AppButton(
                        label: 'Veri hiç gelmez',
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.md40,
                        onPressed: () => _load(arrives: false),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  switch (_section.state) {
                    SectionState.loading => const _SkeletonDemo(),
                    SectionState.ready => AppCard(
                      child: Text(
                        _section.data ?? '',
                        style: context.appText.body.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    SectionState.empty => const AppEmptyState.section(
                      message: 'Burada gösterilecek bir şey yok.',
                    ),
                    SectionState.offline => AppErrorState.section(
                      message: 'Bağlantı yok. Bağlanınca tekrar dene.',
                      onRetry: () => _load(arrives: true),
                    ),
                    SectionState.error => AppErrorState.section(
                      message: 'Dersler yüklenemedi.',
                      onRetry: () => _load(arrives: true),
                    ),
                  },
                ],
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'AppEmptyState · C77 · pano 1.22 kare 3, 4',
          note:
              'Ekran düzeyinde en çok bir kil görsel (128 pt, ekran okuyucu '
              'atlar); görsel yoksa yer tutucu çizilmez. Bölüm düzeyinde '
              'görsel yok.',
          children: [
            GalleryState(
              label: 'Ekran · görselsiz',
              child: GalleryPanel(
                tone: GalleryTone.canvas,
                child: AppEmptyState.screen(
                  topPadding: AppSpacing.s16,
                  title: 'Henüz deneme yok',
                  message:
                      'İlk denemeni okuttuğunda sonuçların, netin ve eksik '
                      'konuların burada görünür.',
                  actionLabel: 'İlk Denemeni Okut',
                  actionIcon: PhosphorIconsRegular.camera,
                  onAction: _noop,
                ),
              ),
            ),
            GalleryState(
              label: 'Ekran · kil görselli (Ampul, M 128) · pano 1.25',
              child: GalleryPanel(
                tone: GalleryTone.canvas,
                child: AppEmptyState.screen(
                  topPadding: AppSpacing.s16,
                  title: 'Henüz programın yok',
                  message:
                      'Haftalık programını kurduğunda günün konuları burada '
                      've Anasayfa\'da görünür.',
                  actionLabel: 'Haftalık Programını Kur',
                  onAction: _noop,
                  illustration: AppClay.medium(ClayPicture.ampul),
                ),
              ),
            ),
            GalleryState(
              label: 'Bölüm',
              child: AppEmptyState.section(
                message: 'Bugün için programında konu yok.',
                actionLabel: 'Haftalık Programını Kur',
                onAction: _noop,
              ),
            ),
            GalleryState(
              label: 'Bölüm · başlıklı, birincil eylem · pano 14.1 kare 4',
              child: AppEmptyState.section(
                title: "Alparslan'ın programı yok",
                message:
                    "Onun için bir hafta kurabilirsin; Alparslan programı "
                    "kendi Anasayfa'sında görür.",
                actionLabel: 'Program Kur',
                actionIcon: PhosphorIconsRegular.plus,
                primaryAction: true,
                onAction: _noop,
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppClay · C61 · pano 1.25 · 11.18',
          note:
              'Kil seti, 11 görsel, L 160 (onboarding) ve M 128 (ekran düzeyi '
              'boş durum). Yalnız onboarding, ekran düzeyi boş durum ve '
              'mağaza; ekranda en çok bir; süs (ekran okuyucu atlar); karo '
              'koyu temada aynı, kenar ve gölge yok. Şimdilik yalnız 1x '
              '(140 px); 2x/3x asıllar gelince aynı adla 2.0x/ ve 3.0x/ '
              'klasörlerine konur.',
          children: [
            for (final size in ClaySize.values)
              GalleryState(
                label: size == ClaySize.large ? 'L 160' : 'M 128',
                child: GalleryPanel(
                  tone: GalleryTone.canvas,
                  child: GalleryWrap(
                    children: [
                      for (final picture in ClayPicture.values)
                        GalleryState(
                          label: picture.name,
                          child: AppClay(picture, size: size),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        GallerySection(
          title: 'AppErrorState · C78 · pano 1.22 kare 4, 5',
          note:
              'Ham hata ve iç kod yok; Tekrar Dene iskelete döner. Ekran '
              'düzeyi alert olarak okunur. Haptik yok.',
          children: [
            GalleryState(
              label: 'Ekran · Tekrar Dene sayısı: $_retries',
              child: GalleryPanel(
                tone: GalleryTone.canvas,
                child: AppErrorState.screen(
                  topPadding: AppSpacing.s16,
                  title: 'Analizin yüklenemedi',
                  message:
                      'Bağlantını kontrol edip tekrar dene. Sorun sürerse '
                      'biraz sonra yeniden açabilirsin.',
                  onRetry: () => setState(() => _retries++),
                ),
              ),
            ),
            GalleryState(
              label: 'Bölüm',
              child: AppErrorState.section(
                message: 'Dersler yüklenemedi.',
                onRetry: () => setState(() => _retries++),
              ),
            ),
            GalleryState(
              label: 'Bölüm · başlıklı · pano 14.3 kare 2',
              child: AppErrorState.section(
                title: 'Programlar yüklenemedi',
                message: 'Bağlantını kontrol edip tekrar dene.',
                onRetry: () => setState(() => _retries++),
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppOfflineStrip · C75 · pano 1.22 kare 6',
          note:
              'Barın hemen altında, içeriği iter; 250 ms iner. Bağlanınca 2 sn '
              '"Bağlandın", sonra kalkar. Koyu temada ters yüzey.',
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: _online,
              builder: (context, online, _) => AppChip(
                label: online ? 'Çevrimiçi' : 'Çevrimdışı',
                selected: !online,
                onTap: () => _online.value = !online,
              ),
            ),
            _FakeBar(online: _online),
          ],
        ),
        const GallerySection(
          title: 'AppStatusView · C79 · panos 2.7, 4.10, 9.4',
          note:
              '96 pt ikon dairesi + display başlık + tek cümle + en çok iki '
              'düğme. Üç kademe; blocking geri hareketini kapatır. Aşağıda '
              'çerçeve içinde.',
          children: [
            _StatusFrame(
              label: '2.7 kare 1 · blocking · 96 + display',
              child: AppStatusView(
                tone: AppStatusTone.info,
                icon: PhosphorIconsRegular.arrowCircleUp,
                title: 'Yeni sürüm gerekli',
                message:
                    "Bu sürüm artık desteklenmiyor. Devam etmek için SMAP'i "
                    'güncelle; verilerin hesabında duruyor.',
                blocking: true,
                topPadding: AppSpacing.s48,
                primary: AppStatusAction(label: 'Güncelle', onPressed: _noop),
              ),
            ),
            _StatusFrame(
              label: '2.7 kare 4 · iki düğme',
              child: AppStatusView(
                tone: AppStatusTone.error,
                icon: PhosphorIconsRegular.warningCircle,
                title: 'Hesabın açılamadı',
                message:
                    'Hesap türün tanınmadı. Çıkış yapıp yeniden giriş yapmayı '
                    'dene; sorun sürerse bize yaz.',
                blocking: true,
                topPadding: AppSpacing.s48,
                primary: AppStatusAction(
                  label: 'Yeniden Giriş Yap',
                  onPressed: _noop,
                ),
                secondary: AppStatusAction(
                  label: "Destek'e Yaz",
                  variant: AppButtonVariant.text,
                  onPressed: _noop,
                ),
              ),
            ),
            _StatusFrame(
              label: '4.9 · flow · 80 + 24/32',
              child: AppStatusView(
                tone: AppStatusTone.success,
                icon: PhosphorIconsRegular.checkCircle,
                size: AppStatusSize.flow,
                title: 'Talebin alındı',
                message:
                    'Analizin hazır olunca Analizlerim › Denemelerim\'de '
                    'görünür.',
                topPadding: AppSpacing.s48,
                primary: AppStatusAction(label: 'Anasayfa', onPressed: _noop),
              ),
            ),
            _StatusFrame(
              label: '9.4 kare 4 · meşgul · geri kapalı',
              child: AppStatusView.busy(
                title: 'Hesabın siliniyor',
                message: 'Uygulamayı kapatma.',
                topPadding: AppSpacing.s48,
              ),
            ),
            _StatusFrame(
              label: '9.4 kare 5 · blocking · 96 + 24/32',
              child: AppStatusView(
                tone: AppStatusTone.success,
                icon: PhosphorIconsRegular.checkCircle,
                title: 'Hesabın silindi',
                message:
                    'Verilerin silindi. İstersen yeni bir hesapla yeniden '
                    'başlayabilirsin.',
                smallTitle: true,
                blocking: true,
                topPadding: AppSpacing.s48,
                primary: AppStatusAction(label: 'Tamam', onPressed: _noop),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The skeleton of board 1.22 kare 2: a title, a chart block, four boxes.
class _SkeletonDemo extends StatelessWidget {
  const _SkeletonDemo();

  @override
  Widget build(BuildContext context) {
    return const AppSkeleton(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonBox(width: 120, height: 20),
          SizedBox(height: AppSpacing.s12),
          SkeletonBox.chart(height: 160),
          SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 64)),
              SizedBox(width: AppSpacing.s12),
              Expanded(child: SkeletonBox(height: 64)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A navy band, the offline strip under it and a content card.
class _FakeBar extends StatelessWidget {
  const _FakeBar({required this.online});

  final ValueListenable<bool> online;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return ClipRRect(
      borderRadius: AppRadius.borderLg,
      child: ColoredBox(
        color: colors.bgCanvas,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(
              color: colors.bgNavy,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Text(
                  'Analizlerim',
                  style: text.titleLg.copyWith(color: colors.textOnNavy),
                ),
              ),
            ),
            AppOfflineStrip(online: online),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: AppCard(
                child: Text(
                  'Son kaydedilen veriler burada görünür.',
                  style: text.body.copyWith(color: colors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A fixed-height frame that stands in for a phone screen.
class _StatusFrame extends StatelessWidget {
  const _StatusFrame({required this.label, required this.child});

  final String label;
  final Widget child;

  /// Frame height: about a phone's visible area.
  static const double _height = 560;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GalleryState(
      label: label,
      child: ClipRRect(
        borderRadius: AppRadius.borderLg,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colors.borderSubtle),
            borderRadius: AppRadius.borderLg,
          ),
          child: SizedBox(height: _height, child: child),
        ),
      ),
    );
  }
}
