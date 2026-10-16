import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/root/presentation/widgets/header_user_section.dart';

class MyCardHeader extends StatelessWidget {
  const MyCardHeader({
    super.key,
    required this.title,
    required this.selectedTab,
    required this.onTabChanged,
    this.onBack,
  });

  final String title;
  final String selectedTab;
  final ValueChanged<String> onTabChanged;
  final VoidCallback? onBack;

  static const double _tabHeight = 48.0;
  static const double _tabOverlap = _tabHeight / 2;

  // Üst başlık alanı: 50 yükseklik + 2 alt boşluk + 12 dikey padding.
  static const double _headerContentHeight = 64.0;

  // Lacivert arka planın mevcut alt sınırı.
  static const double _headerBackgroundHeight =
      _headerContentHeight + _tabOverlap;

  // Chip'in tamamının hit-test alanında kalması için ayrılan toplam yükseklik.
  static const double _layoutHeight = _headerBackgroundHeight + _tabOverlap;

  static const Color _headerColor = AppColors.appBarBackground;
  static const Color _segmentBg = AppColors.menuCardBackground;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: topInset + _layoutHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lacivert arka planın yüksekliği değişmez.
          // Alt 24 px'lik bölüm sayfanın kendi arka planında kalır.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset + _headerBackgroundHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(color: _headerColor),
            ),
          ),

          // Stack artık chip'in tamamını kapsıyor.
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Üst başlık alanı.
                  Padding(
                    padding: const EdgeInsets.only(bottom: _tabOverlap),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: SizedBox(
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AppHeaderUserSection(
                                showBackButton: onBack != null,
                                onBackPressed: onBack,
                              ),
                              IgnorePointer(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 56,
                                  ),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // TYT / AYT segmenti.
                  // Alt yarısı artık Stack sınırının dışında değil.
                  Positioned(
                    bottom: 0,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: _tabHeight,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _segmentBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTabChanged('TYT'),
                              child: _SegmentChip(
                                label: 'TYT',
                                selected: selectedTab == 'TYT',
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTabChanged('AYT'),
                              child: _SegmentChip(
                                label: 'AYT',
                                selected: selectedTab == 'AYT',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.white : MyCardHeader._segmentBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
            color: selected ? AppColors.primaryOrange : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
