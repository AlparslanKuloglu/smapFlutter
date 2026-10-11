import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/features/schedule/application/program_entry.dart';
import 'package:smap/features/schedule/presentation/widgets/hour_slot.dart';
import 'package:smap/features/schedule/presentation/widgets/program_row.dart';
import 'package:smap/features/schedule/presentation/widgets/week_grid.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';
import 'package:smap/shared/ui/pickers/app_calendar.dart';
import 'package:smap/shared/ui/pickers/app_day_chip.dart';
import 'package:smap/shared/ui/pickers/calendar_math.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

void _noop() {}

/// Gallery page of the program pickers and grids: `AppDayChip` (C62, pano
/// 3.4 kare 3, 3.5 kare 2), `AppCalendar` (C65, pano 3.5 kare 1), `HourSlot`
/// (C64, pano 3.5 kare 2), `WeekGrid` (C63, pano 3.4 kare 4, 3.8) and
/// `ProgramRow` (C29, pano 3.4 kare 1).
///
/// The dates are the boards' own: today is Cumartesi 10 Ekim 2026.
class PickersGallery extends StatefulWidget {
  const PickersGallery({super.key});

  @override
  State<PickersGallery> createState() => _PickersGalleryState();
}

class _PickersGalleryState extends State<PickersGallery> {
  static final DateTime _today = DateTime(2026, 10, 10);

  DateTime _chip = _today;
  DateTime _largeChip = DateTime(2026, 10, 12);
  final Set<DateTime> _picked = {
    for (var d = 12; d <= 17; d++) DateTime(2026, 10, d),
  };
  late List<ProgramEntry> _slots = _entries([
    (DateTime(2026, 10, 12), 10, 'Türkçe', 'Fiilde Çatı'),
    (DateTime(2026, 10, 12), 14, 'Tarih', 'Kurtuluş Savaşı Hazırlık Dönemi'),
  ]);

  static const String _turkce = '663e37a24fb443839593141b';
  static const String _tarih = '66214a6982ff212039ea3294';
  static const String _cografya = '6660eec58cf59b23d04006b4';

  static List<ProgramEntry> _entries(
    List<(DateTime, int, String, String)> rows,
  ) {
    var n = 0;
    return [
      for (final (day, hour, lesson, topic) in rows)
        ProgramEntry.of(
          ProgramTaskDraft(
            id: 'g${n++}',
            day: day,
            hour: hour,
            minute: 0,
            lessonId: switch (lesson) {
              'Türkçe' => _turkce,
              'Tarih' => _tarih,
              _ => _cografya,
            },
            lessonName: 'TYT $lesson',
            title: topic,
            mainSubjectId: 'm',
          ),
        ),
    ];
  }

  void _toggle(DateTime day) {
    setState(() {
      final existing = _picked.where((d) => CalendarMath.sameDay(d, day));
      if (existing.isEmpty) {
        _picked.add(day);
      } else {
        _picked.removeAll(existing.toList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final week = CalendarMath.weekOf(_today);
    final nextWeek = CalendarMath.weekOf(DateTime(2026, 10, 12));
    final weekEntries = _entries([
      (DateTime(2026, 10, 10), 10, 'Türkçe', 'Fiilde Çatı'),
      (DateTime(2026, 10, 10), 14, 'Tarih', 'Kurtuluş Savaşı Hazırlık Dönemi'),
      (DateTime(2026, 10, 10), 20, 'Coğrafya', 'İklim Bilgisi'),
      (DateTime(2026, 10, 8), 9, 'Türkçe', 'Cümlenin Öğeleri'),
      (DateTime(2026, 10, 8), 9, 'Tarih', 'İlk Türk Devletleri'),
    ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'AppDayChip · C62 · pano 3.4 kare 3',
          note:
              '48 x 64, yedi gün iki yana yaslı. Bugün turuncu nokta, seçili '
              'lacivert. Okunuş: "Cumartesi 10 Ekim, bugün, seçili".',
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in week)
                  AppDayChip(
                    date: day,
                    today: CalendarMath.sameDay(day, _today),
                    selected: CalendarMath.sameDay(day, _chip),
                    onTap: () => setState(() => _chip = day),
                  ),
              ],
            ),
          ],
        ),
        GallerySection(
          title: 'AppDayChip büyük · pano 3.5 kare 2',
          note: '56 x 76, sayı satırı altında "2 konu".',
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (i, day) in nextWeek.take(6).indexed) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.s8),
                    AppDayChip(
                      date: day,
                      size: AppDayChipSize.large,
                      selected: CalendarMath.sameDay(day, _largeChip),
                      caption: i == 0 ? '2 konu' : null,
                      onTap: () => setState(() => _largeChip = day),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AppCalendar · C65 · pano 3.5 kare 1',
          note:
              'Çoklu seçim; geçmiş günler pasif ama okunur; bugün 2 pt '
              'turuncu halka. İlk ayda "Önceki ay" pasif.',
          children: [
            AppCalendar(selected: _picked, today: _today, onToggle: _toggle),
            const AppCalendarLegend(),
          ],
        ),
        GallerySection(
          title: 'HourSlot · C64 · pano 3.5 kare 2',
          note:
              'Boş saat: "09:00, boş, konu ekle" (Tab ile odaklanınca '
              '"Konu Ekle"). Dolu saat: ders zemini, çıkar düğmesi.',
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              clip: true,
              child: Column(
                children: [
                  for (final hour in [9, 10, 11, 14, 15, 16])
                    HourSlot(
                      hour: hour,
                      entries: [
                        for (final e in _slots)
                          if (e.hour == hour) e,
                      ],
                      onAdd: _noop,
                      onRemove: (entry) => setState(
                        () => _slots = [
                          for (final e in _slots)
                            if (e.id != entry.id) e,
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'WeekGrid · C63 · pano 3.4 kare 4, 3.8',
          note:
              'Saat sütunu 44, gün sütunu 84, satır 40. Yatay ve dikey kayar; '
              'başlık ve saat sütunu sabit. Bugünün sütunu ve ilk çalışma '
              'görünür açılır. Aynı saatteki iki konu yan yana.',
          children: [
            SizedBox(
              height: 480,
              child: WeekGrid(
                days: week,
                entries: weekEntries,
                today: _today,
                onOpenEntry: (_) {},
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'ProgramRow · C29 · pano 3.4 kare 1',
          children: [
            AppCard(
              padding: EdgeInsets.zero,
              clip: true,
              child: Column(
                children: [
                  ProgramRow(
                    name: 'Ekim 2. Hafta',
                    motto: 'Her gün biraz daha',
                    range: '5–11 Ekim 2026',
                    isThisWeek: true,
                    onTap: _noop,
                  ),
                  ProgramRow(
                    name: 'Ekim 3. Hafta',
                    range: '12–18 Ekim 2026',
                    onTap: _noop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
