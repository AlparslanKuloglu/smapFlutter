import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/features/home/presentation/provider/home_nav_provider.dart';
import 'package:studentmap/features/root/presentation/provider/root_nav_provider.dart';
import 'package:studentmap/features/shared/presentation/provider/user_provider.dart';
import 'package:studentmap/features/home/presentation/widgets/app_dialog.dart';

/// Anasayfa menü kartları — 2 satır × 3 sütun.
class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  static const List<_MenuItemData> _studentItems = [
    _MenuItemData(
      title: 'Analiz',
      imagePath: 'assets/menuIcons/a0.png',
      iconBg: Color(0xFFE3F2FD),
    ),
    _MenuItemData(
      title: 'Denemelerim',
      imagePath: 'assets/menuIcons/exams.png',
      iconBg: Color(0xFFE0F2F1),
    ),
    _MenuItemData(
      title: 'Derslerim',
      imagePath: 'assets/menuIcons/cards.png',
      iconBg: Color(0xFFEDE7F6),
    ),
    _MenuItemData(
      title: 'Sıralamalar',
      imagePath: 'assets/menuIcons/ranks4.png',
      iconBg: Color(0xFFE8EAF6),
      //badgeCount: 1,
    ),
    _MenuItemData(
      title: 'SmapLab',
      imagePath: 'assets/menuIcons/button.png',
      iconBg: Color(0xFFFFF8E1),
    ),
    _MenuItemData(
      title: 'Programım',
      imagePath: 'assets/menuIcons/calendar.png',
      iconBg: Color(0xFFFFEBEE),
    ),
  ];

  // --- KOÇ (ÖĞRETMEN) MENÜSÜ ---
  static const List<_MenuItemData> _coachItems = [
    _MenuItemData(
      title: 'SmapCoach',
      imagePath: 'assets/menuIcons/m7.png',
      iconBg: Color(0xFFFFF8E1),
    ),
    _MenuItemData(
      title: 'Öğrencilerim',
      imagePath: 'assets/menuIcons/students2.png',
      iconBg: Color(0xFFFFEBEE),
    ),
    _MenuItemData(
      title: 'Analizler',
      imagePath: 'assets/menuIcons/da4.png',
      iconBg: Color(0xFFE3F2FD),
    ),

    _MenuItemData(
      title: 'Müfredat',
      imagePath: 'assets/menuIcons/mf2.png',
      iconBg: Color(0xFFE8EAF6),
      //badgeCount: 1,
    ),
    _MenuItemData(
      title: 'Kaynak Takibi',
      imagePath: 'assets/menuIcons/exams.png',
      iconBg: Color(0xFFE0F2F1),
    ),
    _MenuItemData(
      title: 'Görüşmelerim',
      imagePath: 'assets/menuIcons/m3.png', // 2-3-4-5-6 , 21
      iconBg: Color(0xFFEDE7F6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Şimdilik test için elinle 'student' veya 'coach' yazabilirsin.
    // Gerçek senaryoda burayı Provider'dan çekeceğiz:
    final userProvider = context.watch<UserProvider>();
    final String? userRole = userProvider.userRole;

    // Role göre listeyi seçiyoruz
    final List<_MenuItemData> activeItems = userRole == 'coach'
        ? _coachItems
        : _studentItems;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      // Artık _items değil, aktif listeyi map ediyoruz
      children: activeItems.map((e) => _MenuTile(data: e)).toList(),
    );
  }
}

class _MenuItemData {
  const _MenuItemData({
    required this.title,
    required this.imagePath, // Artık icon değil, dosya yolu
    required this.iconBg,
    this.badgeCount,
  });

  final String title;
  final String imagePath; // Örn: 'assets/images/analiz.png'
  final Color iconBg;
  final int? badgeCount;
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.data});

  final _MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors
          .transparent, // InkWell dalgalanmasının taşmaması için transparent yaptık
      child: InkWell(
        onTap: () async {
          final userProvider = context.read<UserProvider>();
          final String activeRole = userProvider.userRole ?? 'student';
          final dynamic user = userProvider.user;

          if (data.title == 'Programım') {
            context.read<HomeNavNotifier>().open(HomeRoute.mySchedule);
            return;
          }
          if (data.title == 'Derslerim') {
            context.read<HomeNavNotifier>().resetToHub();
            context.read<RootNavNotifier>().changeTab(2);
            return;
          }
          if (data.title == 'Analiz') {
            context.read<HomeNavNotifier>().resetToHub();
            context.read<RootNavNotifier>().changeTab(1, initialTabIndex: 0);
            return;
          }
          if (data.title == 'Denemelerim') {
            context.read<HomeNavNotifier>().resetToHub();
            context.read<RootNavNotifier>().changeTab(1, initialTabIndex: 1);
            return;
          }
          if (data.title == 'SmapLab') {
            AppDialogs.showUnderConstruction(
              context,
              title: data.title,
              imagePath: data.imagePath,
              desc:
                  "Kendi bilgi kartlarından sana özel quizler oluşturabileceğin veya genel kategorilerde online rekabet edebileceğin bir alan.\n\nŞu anda yapım aşamasında.",
            );
          }
          if (data.title == 'Sıralamalar') {
            AppDialogs.showUnderConstruction(
              context,
              title: data.title,
              imagePath: data.imagePath,
              desc: "Şu anda yapım aşamasında.",
            );
          }

          if (data.title == 'SmapCoach') {
            AppDialogs.showUnderConstruction(
              context,
              title: "SmapCoach",
              desc: "Öğrenci Koçunun Profili",
              buttonType: 2,
              detailDesc:
                  "Öğrenci koçluğundaki başarılarınızı herkese göstermeye hazır mısınız? \n Çok yakında.",
              accentColor: AppColors.appBarBackground,
              imagePath: data.imagePath,
              onNotifyMe: () {
                // Bildirim isteği / analytics
              },
            );
          }
          if (data.title == 'Öğrencilerim') {
            context.read<HomeNavNotifier>().resetToHub();
            context.read<RootNavNotifier>().changeTab(1);
            return;
          }
          if (data.title == 'Analizler') {
            AppDialogs.showUnderConstruction(
              context,
              title: "Analizler",
              desc: "Öğrencilerinize Dair En Detaylı Analiz",
              buttonType: 1,
              detailDesc:
                  "Güçlü konular, zayıf konular, örüntüler, çözülen sorular, çalışma saatleri. \n Çok yakında.",
              accentColor: AppColors.appBarBackground,
              imagePath: data.imagePath,
              onNotifyMe: () {
                // Bildirim isteği / analytics
              },
            );
          }
          if (data.title == 'Müfredat') {
            AppDialogs.showUnderConstruction(
              context,
              title: "Müfredat",
              desc: "Henüz İşlenmedi Mi?",
              buttonType: 2,
              detailDesc:
                  "Öğrenciye özel müfredat düzenlemelerini yapın ve henüz işlenmemiş konuların eksik olarak gözükmesini engelleyin. \n Çok yakında.",
              accentColor: AppColors.appBarBackground,
              imagePath: data.imagePath,
              onNotifyMe: () {
                // Bildirim isteği / analytics
              },
            );
          }
          if (data.title == 'Kaynak Takibi') {
            AppDialogs.showUnderConstruction(
              context,
              title: "Kaynak Takibi",
              desc: "Ne Çözüyoruz? Siz söyleyin.",
              buttonType: 1,
              detailDesc:
                  "Öğrencilerinize ödevler atayın ve biz de bunların istatistiğini takip edelim. \n Çok yakında.",
              accentColor: AppColors.appBarBackground,
              imagePath: data.imagePath,
              onNotifyMe: () {
                // Bildirim isteği / analytics
              },
            );
          }
          if (data.title == 'Görüşmelerim') {
            context.read<HomeNavNotifier>().resetToHub();
            context.read<RootNavNotifier>().changeTab(2);
            return;
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white, // Ders kartlarındaki gibi saf beyaz arka plan
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors
                  .grey
                  .shade200, // Ders kartlarındaki modern ince kenarlık
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                data.badgeCount != null
                    ? Badge(
                        label: Text(
                          '${data.badgeCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: const Color(0xFFE53935),
                        child: _IconCircle(data: data),
                      )
                    : _IconCircle(data: data),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.data});

  final _MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, // Ders kartlarındaki görsel dengesi için boyutu 44'e çektik
      height: 52,
      padding: const EdgeInsets.all(4), // Görselin kenarlara yapışmaması için
      alignment: Alignment.center,
      child: Image.asset(
        data.imagePath,
        fit: BoxFit.contain, // Görseli bozmadan sığdırır
      ),
    );
  }
}
