import 'package:flutter/material.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/controls/app_segmented.dart';
import 'package:smap/shared/ui/controls/app_tab_bar.dart';
import 'package:smap/shared/ui/controls/segment_layout.dart';

/// Gallery page of the segment and the in-screen tabs: `AppSegmented` (C04)
/// and `AppTabBar` (C05), pano 1.10.
class ControlsGallery extends StatefulWidget {
  const ControlsGallery({super.key});

  @override
  State<ControlsGallery> createState() => _ControlsGalleryState();
}

class _ControlsGalleryState extends State<ControlsGallery> {
  var _two = 'TYT';
  var _three = 'AYT';
  var _four = 'Eşit Ağırlık';
  var _counted = 'TYT';
  var _inline = 'TYT';
  var _navySeg = 'TYT';
  var _tabFixed = 0;
  var _tabTwo = 1;
  var _tabScroll = 0;
  var _tabNavy = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppSegmented · C04 · pano 1.10',
          note:
              'Başparmak 250 ms kayar; seçenek genişliği etikete göre. '
              'Sayaç adını söyler; boş sayaç çizilmez (0 ya da veri yok).',
          children: [
            GalleryState(
              label: '2 seçenek',
              child: AppSegmented<String>(
                segments: const [
                  AppSegment(value: 'TYT', label: 'TYT'),
                  AppSegment(value: 'AYT', label: 'AYT'),
                ],
                value: _two,
                onChanged: (v) => setState(() => _two = v),
              ),
            ),
            GalleryState(
              label: '3 seçenek',
              child: AppSegmented<String>(
                segments: const [
                  AppSegment(value: 'TYT', label: 'TYT'),
                  AppSegment(value: 'AYT', label: 'AYT'),
                  AppSegment(value: 'SOS-2', label: 'SOS-2'),
                ],
                value: _three,
                onChanged: (v) => setState(() => _three = v),
              ),
            ),
            GalleryState(
              label: '4 seçenek (metin 1,3 ile sarılır)',
              child: AppSegmented<String>(
                segments: const [
                  AppSegment(value: 'Sayısal', label: 'Sayısal'),
                  AppSegment(value: 'Eşit Ağırlık', label: 'Eşit Ağırlık'),
                  AppSegment(value: 'Sözel', label: 'Sözel'),
                  AppSegment(value: 'Dil', label: 'Dil'),
                ],
                value: _four,
                onChanged: (v) => setState(() => _four = v),
              ),
            ),
            GalleryState(
              label: 'Sayaçlı, 3 seçenek (AYT için sayaç yok)',
              child: AppSegmented<String>(
                segments: [
                  AppSegment(
                    value: 'Tümü',
                    label: 'Tümü',
                    counter: SegmentCounter.format(count: 31, unit: 'eksik'),
                  ),
                  AppSegment(
                    value: 'TYT',
                    label: 'TYT',
                    counter: SegmentCounter.format(count: 28, unit: 'eksik'),
                  ),
                  AppSegment(
                    value: 'AYT',
                    label: 'AYT',
                    counter: SegmentCounter.format(count: 0, unit: 'eksik'),
                  ),
                ],
                value: _counted,
                onChanged: (v) => setState(() => _counted = v),
              ),
            ),
            GalleryState(
              label: 'Sayaçlı, 2 seçenek (tek satır)',
              child: AppSegmented<String>(
                segments: [
                  AppSegment(
                    value: 'TYT',
                    label: 'TYT',
                    counter: SegmentCounter.format(count: 7, unit: 'eksik'),
                  ),
                  AppSegment(
                    value: 'AYT',
                    label: 'AYT',
                    counter: SegmentCounter.format(count: 7, unit: 'eksik'),
                  ),
                ],
                value: _inline,
                onChanged: (v) => setState(() => _inline = v),
              ),
            ),
            GalleryState(
              label: 'Pasif',
              child: AppSegmented<String>(
                segments: const [
                  AppSegment(value: 'TYT', label: 'TYT'),
                  AppSegment(value: 'AYT', label: 'AYT'),
                ],
                value: 'TYT',
                onChanged: null,
              ),
            ),
            GalleryPanel(
              tone: GalleryTone.navy,
              child: AppSegmented<String>(
                onNavy: true,
                segments: const [
                  AppSegment(value: 'TYT', label: 'TYT'),
                  AppSegment(value: 'AYT', label: 'AYT'),
                ],
                value: _navySeg,
                onChanged: (v) => setState(() => _navySeg = v),
              ),
            ),
            const GalleryNote('Odak: klavyede Tab; seçenekte içe 2 pt halka.'),
          ],
        ),
        GallerySection(
          title: 'AppTabBar · C05 · pano 1.10',
          note:
              'Turuncu çizgi konumu bildirir; sığmazsa kendiliğinden kayar, '
              'seçilen sekme görünür alana gelir.',
          children: [
            GalleryState(
              label: 'Sabit, 4 sekme',
              child: AppTabBar(
                labels: const ['Genel', 'Sorular', 'Konular', 'Kartlar'],
                selectedIndex: _tabFixed,
                onChanged: (i) => setState(() => _tabFixed = i),
              ),
            ),
            GalleryState(
              label: 'Sabit, 2 sekme',
              child: AppTabBar(
                labels: const ['Genel', 'Denemelerim'],
                selectedIndex: _tabTwo,
                onChanged: (i) => setState(() => _tabTwo = i),
              ),
            ),
            GalleryState(
              label: 'Kaydırılabilir',
              child: AppTabBar(
                scrollable: true,
                labels: const [
                  'Genel',
                  'Sorular',
                  'Konular',
                  'Kartlar',
                  'Denemelerim',
                ],
                selectedIndex: _tabScroll,
                onChanged: (i) => setState(() => _tabScroll = i),
              ),
            ),
            GalleryPanel(
              tone: GalleryTone.navy,
              child: AppTabBar(
                onNavy: true,
                labels: const ['Genel', 'Denemelerim'],
                selectedIndex: _tabNavy,
                onChanged: (i) => setState(() => _tabNavy = i),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
