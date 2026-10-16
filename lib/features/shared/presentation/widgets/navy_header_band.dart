import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';

/// Anasayfa ders kartları üstündeki ve hesap ayarlarındaki lacivert bant.
class NavyHeaderBand extends StatelessWidget {
  const NavyHeaderBand({
    super.key,
    required this.height,
    this.bottomRadius = 0,
  });

  final double height;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: bottomRadius > 0
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(bottomRadius),
                  bottomRight: Radius.circular(bottomRadius),
                )
              : BorderRadius.zero,
        ),
      ),
    );
  }
}
