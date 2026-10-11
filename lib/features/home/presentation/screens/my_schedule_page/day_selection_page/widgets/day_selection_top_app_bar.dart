import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';

class DaySelectionTopAppBar extends StatelessWidget {
  const DaySelectionTopAppBar({super.key, required this.onBack, this.onNext});

  final VoidCallback onBack;
  final VoidCallback? onNext;

  /// The corner radius of the legacy top bar this one was drawn after.
  static const double _bottomCornerRadius = 32;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_bottomCornerRadius),
          bottomRight: Radius.circular(_bottomCornerRadius),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const Text(
                'Gün Seçimi',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
