import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabTap,
    required this.onCameraTap,
    required this.userRole, // Rol parametresi zorunlu hale getirildi
  });

  final int selectedIndex;
  final ValueChanged<int> onTabTap;
  final VoidCallback onCameraTap;
  final String userRole; // Eklendi

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.fromLTRB(4, 0, 4, math.max(0, bottomInset - 8)),
      height: 72 + bottomInset,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double indicatorWidth = 60;
          final double slotWidth =
              constraints.maxWidth / 5; // Toplam 5 slot (Kamera dahil)

          // Kamera butonu (Slot 3) tıklanabilir bir sekme olmadığından,
          // çizginin doğru slot üzerine kayması için index ayarı:
          final int slotIndex = selectedIndex < 2
              ? selectedIndex
              : selectedIndex + 1;
          final double rawLeft =
              (slotIndex * slotWidth) + ((slotWidth - indicatorWidth) / 2);

          // Taşmayı engelle
          final double indicatorLeft = rawLeft.clamp(
            0.0,
            constraints.maxWidth - indicatorWidth,
          );

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Indicator — navbar'ın tam tepesinde
              SizedBox(
                height: 4,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      left: indicatorLeft,
                      top: 0,
                      child: Container(
                        width: indicatorWidth,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.navIndicator,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Nav item'ları
              Expanded(
                child: Row(
                  children: [
                    // SLOT 1: Anasayfa (Her iki rolde de ortak)
                    Expanded(
                      child: _NavItem(
                        svgPath: 'assets/home.svg',
                        label: 'Anasayfa',
                        selected: selectedIndex == 0,
                        onTap: () => onTabTap(0),
                      ),
                    ),

                    // SLOT 2: Şartlı Alan (Öğretmense Öğrencilerim, Öğrenciyse Analizlerim)
                    Expanded(
                      child: userRole == 'coach'
                          ? _NavItem(
                              icon: Icons.people_rounded,
                              label: 'Öğrencilerim',
                              selected: selectedIndex == 1,
                              onTap: () => onTabTap(1),
                            )
                          : _NavItem(
                              svgPath: 'assets/chart.svg',
                              label: 'Analizlerim',
                              selected: selectedIndex == 1,
                              onTap: () => onTabTap(1),
                            ),
                    ),

                    // SLOT 3: Sabit Kamera Butonu (Tam Ortada ve Taşan Tasarım)
                    Expanded(child: _CameraNavButton(onTap: onCameraTap)),

                    // SLOT 4: Şartlı Alan (Öğretmense Görüşmelerim, Öğrenciyse Kartlarım)
                    Expanded(
                      child: userRole == 'coach'
                          ? _NavItem(
                              icon: Icons.chat,
                              label: 'Görüşmelerim',
                              selected: selectedIndex == 2,
                              onTap: () => onTabTap(2),
                            )
                          : _NavItem(
                              svgPath: 'assets/cards.svg',
                              label: 'Derslerim',
                              selected: selectedIndex == 2,
                              onTap: () => onTabTap(2),
                            ),
                    ),

                    // SLOT 5: Hesap (Her iki rolde de ortak)
                    Expanded(
                      child: _NavItem(
                        svgPath: 'assets/profile.svg',
                        label: 'Hesap',
                        selected: selectedIndex == 3,
                        onTap: () => onTabTap(3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Yardımcı Alt Widgetlar (_NavItem ve _CameraNavButton)
// --------------------------------------------------------------------------
class _NavItem extends StatelessWidget {
  const _NavItem({
    this.icon,
    this.svgPath,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : assert(
         icon != null || svgPath != null,
         'icon veya svgPath ikilisinden en az biri verilmelidir.',
       );

  final IconData? icon;
  final String? svgPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? AppColors.primaryOrange
        : AppColors.navUnselected;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 28,
            decoration: BoxDecoration(
              color: selected ? AppColors.navSelectedBg : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: svgPath != null && svgPath!.isNotEmpty
                ? SvgPicture.asset(
                    svgPath!,
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  )
                : Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraNavButton extends StatelessWidget {
  const _CameraNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.orangeShadow,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/camera.svg',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
