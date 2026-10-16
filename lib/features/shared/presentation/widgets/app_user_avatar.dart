import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/features/shared/presentation/provider/user_provider.dart'; // UserProvider'ı ekledik

class AppUserAvatar extends StatelessWidget {
  const AppUserAvatar({super.key, this.radius = 24, this.borderWidth = 2});

  const AppUserAvatar.compact({super.key}) : radius = 11, borderWidth = 2;

  final double radius;
  final double borderWidth;

  static const Color _fill = Color(0xFF1A3D66);

  @override
  Widget build(BuildContext context) {
    // UserProvider'dan kullanıcıyı çekiyoruz
    final user = context.watch<UserProvider>().user;
    final double iconSize = radius < 16 ? 14 : radius * 1.08;

    // Fotoğraf var mı ve boş değil mi kontrolü
    final bool hasPhoto = user?.photo != null && user!.photo.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: _fill,
        child: hasPhoto
            ? ClipOval(
                child: Image.asset(
                  'assets/avatars/${user.photo}', // Assets klasöründeki yol
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                  // Eğer asset bulunamazsa yine ikona düşmesi için hata yakalayıcı:
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultIcon(iconSize),
                ),
              )
            : _buildDefaultIcon(iconSize),
      ),
    );
  }

  // Varsayılan İkon Widget'ı
  Widget _buildDefaultIcon(double size) {
    return Icon(
      Icons.person_rounded,
      size: size,
      color: Colors.white.withValues(alpha: 0.85),
    );
  }
}
