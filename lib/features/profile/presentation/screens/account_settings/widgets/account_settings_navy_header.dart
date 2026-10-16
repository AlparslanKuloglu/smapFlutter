import 'package:flutter/material.dart';
import 'package:studentmap/core/theme/app_colors.dart';

/// Anasayfa [HomeLessonsCards] üstündeki lacivert bant ile aynı kod ve ölçüler.
class AccountSettingsNavyHeader extends StatelessWidget {
  // Parametreyi isteğe bağlı (nullable) veya zorunlu yapabilirsin.
  // Burada string gelmesi için parametre olarak ekledik.
  final String? userImage;

  const AccountSettingsNavyHeader({
    super.key,
    this.userImage, // <-- Dışarıdan parametre olarak alıyoruz
  });

  static const double rowHeight = 120;
  static const double bandHeight = rowHeight / 2;
  static const double _avatarRadius = 44;

  /// Bant + profil fotoğrafı taşması.
  static const double totalHeight = bandHeight + _avatarRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bandHeight,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.appBarBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
            ),
          ),
          // Resim parametresini alt bileşene aktarıyoruz
          _ProfileAvatar(
            radius: _avatarRadius,
            borderWidth: 3,
            userImage: userImage,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.radius,
    required this.borderWidth,
    this.userImage,
  });

  final double radius;
  final double borderWidth;
  final String? userImage; // <-- Alt bileşene de ekledik

  static const Color _fill = Color(0xFF1A3D66);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: _fill,
        // Eğer dışarıdan asset yolu geldiyse resmi göster, gelmediyse ikona düş
        child: userImage != null && userImage!.isNotEmpty
            ? ClipOval(
                child: Image.asset(
                  userImage!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover, // Resmin yuvarlağa tam oturması için
                  // Eğer asset yüklenirken hata verirse yine güvenli ikona döner:
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person_rounded,
                    size: radius * 1.08,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: radius * 1.08,
                color: Colors.white.withValues(alpha: 0.85),
              ),
      ),
    );
  }
}
