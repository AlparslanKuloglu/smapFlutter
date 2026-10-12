import 'package:flutter/material.dart';
import 'package:smap/features/account/application/avatar_catalog.dart';
import 'package:smap/features/coach/domain/attention_item.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/widgets/attention_row.dart';
import 'package:smap/features/coach/presentation/widgets/code_card.dart';
import 'package:smap/features/coach/presentation/widgets/meeting_row.dart';
import 'package:smap/features/coach/presentation/widgets/student_row.dart';
import 'package:smap/features/coach/presentation/widgets/student_tile.dart';
import 'package:smap/features/debug/gallery_widgets.dart';
import 'package:smap/shared/ui/surfaces/app_card.dart';

void _noop() {}

void _noopRect(Rect? _) {}

ImageProvider _avatar(int index) => AssetImage(AvatarCatalog.assetAt(index));

/// Gallery page of the coach components (tasks E15, E16, E18), with the
/// sample data of the boards: StudentTile C32 and the meeting rows C34
/// (pano 10.1), AttentionRow C33 (pano 10.1 kare 2, behind
/// `FeatureFlags.attentionListEnabled`), StudentRow C31 (pano 10.2) and
/// CodeCard C35 (panos 10.1 kare 3, 10.3 kare 2).
///
/// The light / dark switch of the gallery shows every demo in both themes.
class CoachGallery extends StatelessWidget {
  const CoachGallery({super.key});

  static final DateTime _lastExam = DateTime(2026, 10, 5);
  static final DateTime _meetingA = DateTime(2026, 10, 14, 16);
  static final DateTime _meetingB = DateTime(2026, 10, 17, 19, 30);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GallerySection(
          title: 'StudentTile · C32 · pano 10.1',
          note:
              'Koç Anasayfa şeridi: avatar, ad (iki satır), varsa son deneme '
              'tarihi. Avatarsız öğrencide baş harf.',
          children: [
            GalleryState(
              label: 'Avatarlı · son denemeli / avatarsız · tarihsiz',
              child: GalleryWrap(
                children: [
                  StudentTile(
                    name: 'Alparslan Kuloğlu',
                    avatar: _avatar(0),
                    lastExam: _lastExam,
                    onTap: _noop,
                  ),
                  StudentTile(
                    name: 'Elif Şahin',
                    avatar: _avatar(1),
                    onTap: _noop,
                  ),
                  const StudentTile(name: 'Mehmet Yılmaz', onTap: _noop),
                ],
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'StudentRow · C31 · pano 10.2',
          note:
              'Öğrencilerim satırı; aramada eşleşen kısım vurgulu. Son net '
              'sunucuda yok (#29), satır onsuz da çizilir.',
          children: [
            GalleryState(
              label: 'Normal · arama "eli" · son netli',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    StudentRow(
                      name: 'Alparslan Kuloğlu',
                      semanticLabel: 'Alparslan Kuloğlu, 12. Sınıf',
                      meta: '12. Sınıf · Eşit Ağırlık',
                      avatar: _avatar(0),
                      onTap: _noop,
                    ),
                    StudentRow(
                      name: 'Elif Şahin',
                      semanticLabel: 'Elif Şahin, 11. Sınıf',
                      meta: '11. Sınıf · Sayısal',
                      query: 'eli',
                      avatar: _avatar(1),
                      onTap: _noop,
                    ),
                    StudentRow(
                      name: 'Kerem Aydın',
                      semanticLabel: 'Kerem Aydın, Mezun, son net 74,75',
                      meta: 'Mezun · Sözel',
                      lastNet: '74,75',
                      lastNetLabel: 'son net',
                      avatar: _avatar(2),
                      onTap: _noop,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'AttentionRow · C33 · pano 10.1 kare 2',
          note:
              'Bayrak kapalı (uç yok, #28): ekranda yok. İki kural: 14 gün '
              'deneme yok, son iki aynı tür denemede net düştü.',
          children: [
            GalleryState(
              label: 'Pasif · net düşüşü',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    AttentionRow(
                      name: 'Alparslan Kuloğlu',
                      sentence: '45 gündür deneme okutmadı',
                      rule: AttentionRule.inactive,
                      semanticLabel:
                          'Alparslan Kuloğlu, 45 gündür deneme okutmadı',
                      avatar: _avatar(0),
                      onTap: _noop,
                    ),
                    AttentionRow(
                      name: 'Elif Şahin',
                      sentence: 'Son iki TYT denemesinde net düştü',
                      rule: AttentionRule.netDrop,
                      evidence: '68 → 66,75 · 17 Haz. ve 4 Ağu.',
                      semanticLabel:
                          'Elif Şahin, son iki TYT denemesinde net düştü',
                      avatar: _avatar(1),
                      onTap: _noop,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        GallerySection(
          title: 'MeetingRow · C34 · pano 10.1, 10.5',
          note: 'Anasayfa: tarih bloklu. Görüşmelerim: liste satırı.',
          children: [
            GalleryState(
              label: 'Tarih bloklu (Koç Anasayfa)',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    MeetingRow.dateBlock(
                      name: 'Alparslan Kuloğlu',
                      date: _meetingA,
                      type: InterviewType.student,
                      avatar: _avatar(0),
                      onTap: _noop,
                    ),
                    MeetingRow.dateBlock(
                      name: 'Elif Şahin',
                      date: _meetingB,
                      type: InterviewType.parent,
                      avatar: _avatar(1),
                      onTap: _noop,
                    ),
                  ],
                ),
              ),
            ),
            GalleryState(
              label: 'Liste',
              child: AppCard(
                padding: EdgeInsets.zero,
                child: MeetingRow.list(
                  name: 'Alparslan Kuloğlu',
                  date: _meetingA,
                  type: InterviewType.student,
                  avatar: _avatar(0),
                  onTap: _noop,
                ),
              ),
            ),
          ],
        ),
        const GallerySection(
          title: 'CodeCard · C35 · pano 10.1 kare 3, 10.3 kare 2',
          note: 'Kopyala ve Paylaş eşit ağırlıkta; Kopyala toast verir.',
          children: [
            GalleryState(
              label: 'Koçluk kodu',
              child: CodeCard(
                code: 'MOZK-4821',
                onCopy: _noop,
                onShare: _noopRect,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
