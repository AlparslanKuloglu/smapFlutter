import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/root/presentation/widgets/header_user_section.dart';

class CustomTopAppBar extends StatelessWidget {
  const CustomTopAppBar({
    super.key,
    this.radius = false,
    this.title,
    this.showBackButton = false,
    this.showBottomBorder = false,
    this.onBackPressed,
  });

  final bool radius;
  final String? title;
  final bool showBackButton;
  final bool showBottomBorder;
  final VoidCallback? onBackPressed;

  static const double bottomCornerRadius = 32;

  @override
  Widget build(BuildContext context) {
    final displayTitle = title?.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: radius
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(bottomCornerRadius),
                bottomRight: Radius.circular(bottomCornerRadius),
              )
            : BorderRadius.zero,
        border: showBottomBorder
            ? const Border(
                bottom: BorderSide(color: AppColors.primaryOrange, width: 2),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SizedBox(
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AppHeaderUserSection(
                  showBackButton: showBackButton,
                  onBackPressed: onBackPressed,
                ),
                if (displayTitle != null && displayTitle.isNotEmpty)
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Text(
                        displayTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
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
