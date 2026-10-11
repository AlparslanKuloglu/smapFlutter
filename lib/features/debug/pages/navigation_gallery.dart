import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/controls/app_tab_bar.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_context_strip.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/app_home_band.dart';
import 'package:smap/shared/ui/navigation/app_root_band.dart';
import 'package:smap/shared/ui/navigation/bottom_bar_tabs.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/navigation/student_scope.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

void _noop() {}

/// Gallery page of the shell parts (KIT3): `AppRootBand` (C80),
/// `AppHomeBand` (C81), `AppDetailBar` + `LargeTitleSliver` (C82),
/// `AppContextStrip` + `StudentScope` (C83, C85), `AppBottomBar` +
/// `AppCameraButton` + `AppNavTab` (C84), `AppSystemOverlay`; panos 1.18,
/// 1.19, 1.23, 1.24, 3.1, 10.1, 10.4.
///
/// Every demo is a 402-wide phone frame with the reference safe areas (62
/// top, 34 bottom) and its own `CustomScrollView`: scroll inside a frame to
/// see the bands shrink and the detail titles move into the bar. Use the
/// "Metin 1,3" and "Koyu tema" chips above for the other board states.
class NavigationGallery extends StatefulWidget {
  const NavigationGallery({super.key});

  @override
  State<NavigationGallery> createState() => _NavigationGalleryState();
}

class _NavigationGalleryState extends State<NavigationGallery> {
  var _segment = 0;
  var _tab = 0;

  static const _student = StudentRef(id: '41', name: 'Alparslan Kuloğlu');

  @override
  Widget build(BuildContext context) {
    final exam = DateTime(2027, 6, 19);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GallerySection(
          title: 'AppRootBand · C80 · pano 1.18 kare 1 ve 3',
          note:
              'Lacivert, 134. Kaydırınca 110: başlık 24→17, alt köşeler düzleşir '
              '(süre yok, kaydırmayı izler). Sağda en çok bir eylem.',
          children: [
            _Phone(
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppRootBand(
                    title: 'Görüşmelerim',
                    action: AppIconButton(
                      icon: PhosphorIconsRegular.plus,
                      semanticLabel: 'Yeni görüşme',
                      variant: AppIconButtonVariant.onNavy,
                      onPressed: _noop,
                    ),
                  ),
                  _FakeItems(),
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppRootBand · bantta ana kontrol · pano 1.18 kare 2',
          note:
              'Segmentli bant 178, sekmeli 174; küçülmez, kontrol bantta sabit '
              'kalır.',
          children: [
            _Phone(
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppRootBand(
                    title: 'Derslerim',
                    bottom: AppRootBandBottom.segment(
                      child: AppSegmented<int>(
                        onNavy: true,
                        value: _segment,
                        onChanged: (v) => setState(() => _segment = v),
                        segments: const [
                          AppSegment(value: 0, label: 'TYT'),
                          AppSegment(value: 1, label: 'AYT'),
                        ],
                      ),
                    ),
                  ),
                  const _FakeItems(),
                ],
              ),
            ),
            _Phone(
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppRootBand(
                    title: 'Analizlerim',
                    bottom: AppRootBandBottom.tabs(
                      child: AppTabBar(
                        onNavy: true,
                        labels: const ['Genel', 'Denemelerim'],
                        selectedIndex: _tab,
                        onChanged: (v) => setState(() => _tab = v),
                      ),
                    ),
                  ),
                  const _FakeItems(),
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppHomeBand · C81 · pano 3.1, 10.1',
          note:
              'Öğrenci 194, koç 138; ikisi de 110\'a iner: sayaç tek satıra '
              'çıkar ("YKS\'ye 252 gün"), avatar 32, selam 17/24.',
          children: [
            _Phone(
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppHomeBand.student(
                    name: 'Alparslan',
                    counter: AppHomeCounter(daysLeft: 252, examDate: exam),
                  ),
                  const _FakeItems(),
                ],
              ),
            ),
            const _Phone(
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppHomeBand.coach(
                    name: 'Mehmet',
                    studentCount: 5,
                    upcomingMeetings: 2,
                  ),
                  _FakeItems(),
                ],
              ),
            ),
            const _Phone(
              height: 300,
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppHomeBand.coach(name: 'Mehmet', studentCount: 0),
                  _FakeItems(count: 3),
                ],
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'AppDetailBar + LargeTitleSliver · C82 · pano 1.18 kare 4, 5',
          note:
              'Başlık içerikte büyük (3 satıra kadar); kaydırınca bara 17/24 · '
              '700, sola hizalı, iki satıra kadar iner ve alt ayraç belirir. '
              'Sağda Eksiklerim: AppBarAction; ikinci karede ikon eylemi.',
          children: [
            _Phone(
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppDetailBar(
                    title: 'Türkçe',
                    action: AppBarAction(
                      label: 'Eksiklerim (31)',
                      onPressed: _noop,
                    ),
                  ),
                  LargeTitleSliver(title: 'Türkçe'),
                  _FakeItems(),
                ],
              ),
            ),
            _Phone(
              child: CustomScrollView(
                primary: false,
                slivers: [
                  AppDetailBar(
                    title:
                        'İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk '
                        'Edebiyatı)',
                    action: AppIconButton(
                      icon: PhosphorIconsRegular.cards,
                      semanticLabel: 'Kartlarım',
                      onPressed: _noop,
                    ),
                  ),
                  LargeTitleSliver(
                    title:
                        'İslamiyet Etkisindeki Türk Edebiyatı (Divan-Halk '
                        'Edebiyatı)',
                  ),
                  _FakeItems(),
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppContextStrip + StudentScope · C83, C85 · pano 1.18 kare 6',
          note:
              'Koç bir öğrencinin ekranındayken barın altında, barla birlikte '
              'sabit; içerik 40 aşağı kayar. StudentScope koç bağlamını ve '
              'öğrenci kimliğini alt ağaca taşır.',
          children: [
            _Phone(
              child: StudentScope(
                student: _student,
                child: CustomScrollView(
                  primary: false,
                  slivers: [
                    const AppDetailBar(title: 'Türkiye Geneli Deneme 6'),
                    const LargeTitleSliver(title: 'Türkiye Geneli Deneme 6'),
                    const PinnedHeaderSliver(
                      child: AppContextStrip(
                        student: _student,
                        detail: '12. Sınıf · EA',
                        detailSemantics: '12. sınıf, Eşit Ağırlık',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(AppSpacing.gutter),
                          child: GalleryNote(
                            'Kapsamda: koç görünümü='
                            '${StudentScope.isCoachView(context)}, '
                            'öğrenci kimliği=${StudentScope.studentIdOf(context)}',
                          ),
                        ),
                      ),
                    ),
                    const _FakeItems(),
                  ],
                ),
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'AppBottomBar · AppNavTab · AppCameraButton · C84 · pano 1.19',
          note:
              '68 + 34. Tek turuncu gösterge sekmeler arasında kayar (250 ms); '
              'seçili Fill + 700; Okut sekme değil: 0,92 + orta haptik. Uzun '
              'bas: büyük ikon ve ad balonu. Çubuğun arkasından liste bulanık '
              'geçer.',
          children: [
            _BarDemo(role: AppBottomBarRole.student),
            _BarDemo(role: AppBottomBarRole.coach, initial: 3),
            _BarDemo(role: AppBottomBarRole.coach, initial: 2, largeText: true),
          ],
        ),
        const GallerySection(
          title: 'AppSystemOverlay · durum çubuğu',
          note:
              'band ve camera: açık ikonlar, iki temada; bar: açık temada '
              'koyu ikonlar. Ekran görüntüsünde değil, cihazda görülür; '
              'bantlar ve bar kendi AnnotatedRegion\'ını taşır.',
          children: [],
        ),
      ],
    );
  }
}

/// A 402 pt wide phone frame with the reference safe areas.
class _Phone extends StatelessWidget {
  const _Phone({required this.child, this.height = 520});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(AppSize.referenceWidth, constraints.maxWidth);
        const safe = EdgeInsets.only(
          top: AppSize.referenceSafeTop,
          bottom: AppSize.referenceSafeBottom,
        );
        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderXl,
                border: Border.all(color: colors.borderSubtle),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.borderXl,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: Size(width, height),
                    padding: safe,
                    viewPadding: safe,
                  ),
                  child: ColoredBox(color: colors.bgCanvas, child: child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Filler rows so a frame has something to scroll.
class _FakeItems extends StatelessWidget {
  const _FakeItems({this.count = 14});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s16,
        AppSpacing.gutter,
        AppSize.referenceSafeBottom + AppSize.bottomBar,
      ),
      sliver: SliverList.separated(
        itemCount: count,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s8),
        itemBuilder: (context, i) => AppCard(
          child: Text(
            'Örnek satır ${i + 1}',
            style: context.appText.titleSm.copyWith(color: colors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// A frame with a bottom bar over a scrolling list.
class _BarDemo extends StatefulWidget {
  const _BarDemo({
    required this.role,
    this.initial = 1,
    this.largeText = false,
  });

  final AppBottomBarRole role;
  final int initial;
  final bool largeText;

  @override
  State<_BarDemo> createState() => _BarDemoState();
}

class _BarDemoState extends State<_BarDemo> {
  late int _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final scale = widget.largeText ? const TextScaler.linear(1.3) : null;
    Widget frame = _Phone(
      height: 420,
      child: Stack(
        children: [
          const CustomScrollView(primary: false, slivers: [_FakeItems()]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomBar(
              role: widget.role,
              selectedIndex: _selected,
              onTap: (i) => setState(() => _selected = i),
              onCamera: _noop,
            ),
          ),
        ],
      ),
    );
    if (scale != null) {
      frame = MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: scale),
        child: frame,
      );
    }
    return GalleryState(
      label:
          '${widget.role == AppBottomBarRole.student ? 'Öğrenci' : 'Koç'}'
          '${widget.largeText ? ' · metin 1,3' : ''}',
      child: SizedBox(width: double.infinity, child: frame),
    );
  }
}
