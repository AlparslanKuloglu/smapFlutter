import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studentmap/core/theme/app_colors.dart';

class AddLessonsTopHeader extends StatelessWidget {
  const AddLessonsTopHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.bagItemsStr,
    this.onBagTap,
    this.pendingSubject,
    this.onFinish,
  });

  final String title;
  final VoidCallback onBack;
  final String bagItemsStr;
  final Function(String)? onBagTap;
  final Map<String, dynamic>? pendingSubject;
  final VoidCallback? onFinish;

  static const _tabHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    int itemCount = 0;
    try {
      final dynamic decoded = jsonDecode(bagItemsStr);
      if (decoded is List) {
        itemCount = decoded.length;
      }
    } catch (e) {
      debugPrint('JSON Çözümlenirken hata oluştu: $e');
    }

    final isPendingMode = pendingSubject != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // DÜZELTME 1: Arka planı sarmalayan bir Column ekledik ve
            // dışarıdaki SizedBox(height: 24)'ü Stack'in İÇİNE taşıdık.
            // Artık Stack'in tıklanabilir (HitTest) alanı butonların tamamını kapsıyor.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + 10,
                    bottom: 38,
                    left: 16,
                    right: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: onBack,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Opacity(
                        opacity: 0,
                        child: IconButton(
                          onPressed: null,
                          icon: Icon(Icons.arrow_back_ios),
                        ),
                      ),
                    ],
                  ),
                ),
                // Butonların taşma payı kadar alanı Stack içine dahil ediyoruz
                SizedBox(height: _tabHeight / 2),
              ],
            ),

            // DÜZELTME 2: Artık eksi değer (-24) vermiyoruz, tam Stack'in en altına yaslıyoruz.
            // Bu sayede görsel olarak aynı yerde kalıyor ama %100 tıklanabilir oluyor.
            Positioned(
              bottom: 0,
              left: 24,
              right: 24,
              child: SizedBox(
                height: _tabHeight,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isPendingMode
                      ? _buildPendingModeBar()
                      : Row(
                          key: const ValueKey('tabs'),
                          children: [
                            Expanded(
                              child: _SegmentChip(
                                label: 'Çantam',
                                iconPath: 'assets/icons/bag.svg',
                                bagCount: itemCount,
                                onTap: () => onBagTap?.call('bag'),
                              ),
                            ),

                            Expanded(
                              child: _SegmentChip(
                                label: 'Dersler',
                                iconPath: 'assets/icons/lesson2.svg',
                                onTap: () => onBagTap?.call('lessons'),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPendingModeBar() {
    final lessonName = pendingSubject?['lesson']?['name'] ?? '';
    final topicName = pendingSubject?['data']?['name'] ?? '';

    return Container(
      key: const ValueKey('pending'),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lessonName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  topicName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onFinish,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryOrange,
              minimumSize: const Size(64, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Bitir",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({
    required this.label,
    required this.iconPath,
    this.bagCount,
    this.onTap,
  });

  final String label;
  final String iconPath;
  final int? bagCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0xFFE2E8F0);
    const Color iconColor = Color.fromARGB(255, 43, 76, 120);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      // Tıklanma (Splash) efektinin düzgün çalışması ve her pikselin algılanması için yapı
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              if (bagCount != null && bagCount! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$bagCount',
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
