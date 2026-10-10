import 'package:flutter/material.dart';
import 'package:smap/features/auth/presentation/widgets/auth_enums.dart';

class SocialProviderIcon extends StatelessWidget {
  const SocialProviderIcon({super.key, required this.provider});

  final SocialProvider provider;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color, double iconSize) = switch (provider) {
      SocialProvider.apple => (Icons.apple, Colors.black, 28.0),
      SocialProvider.google => (Icons.g_mobiledata, Colors.red, 32.0),
    };

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Center(child: Icon(icon, size: iconSize, color: color)),
    );
  }
}
