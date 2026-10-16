import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:studentmap/core/theme/app_colors.dart';

enum SavedCardBrand { mastercard, visa }

class SavedCardWidget extends StatelessWidget {
  const SavedCardWidget({
    super.key,
    required this.brand,
    required this.lastFourDigits,
    this.isDefault = false,
    this.onMoreTap,
  });

  final SavedCardBrand brand;
  final String lastFourDigits;
  final bool isDefault;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault
              ? AppColors.appBarBackground
              : const Color(0xFFE8ECF0),
          width: isDefault ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _BrandLogo(brand: brand),
              if (isDefault) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x28102849),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Varsayılan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: onMoreTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
          Text(
            '**** **** **** $lastFourDigits',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.brand});

  final SavedCardBrand brand;

  @override
  Widget build(BuildContext context) {
    return switch (brand) {
      SavedCardBrand.mastercard => const _MastercardLogo(),
      SavedCardBrand.visa => const _VisaLogo(),
    };
  }
}

class _MastercardLogo extends StatelessWidget {
  const _MastercardLogo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/master.svg',
      width: 44,
      height: 28,
      fit: BoxFit.contain,
    );
  }
}

class _VisaLogo extends StatelessWidget {
  const _VisaLogo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/visaa.svg',
      width: 56,
      height: 28,
      fit: BoxFit.contain,
    );
  }
}
