import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart';
import 'package:smap/features/shared/presentation/widgets/app_user_avatar.dart';

class AppHeaderUserSection extends StatelessWidget {
  const AppHeaderUserSection({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
  });

  final bool showBackButton;
  final VoidCallback? onBackPressed;

  String _getAimTypeName(int? aimType) {
    if (aimType == 2) return 'Eşit Ağırlık';
    if (aimType == 3) return 'Sayısal';
    if (aimType == 4) return 'Sözel';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    final String studentBranch = userProvider.userRole == 'coach'
        ? 'Öğrenci Koçu'
        : _getAimTypeName(user?.aimType);

    return Row(
      children: [
        // Sol taraf: Geri butonu veya büyütülmüş logo.
        if (showBackButton)
          IconButton(
            onPressed: onBackPressed ?? () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 22,
            ),
          )
        else
          GestureDetector(
            onTap: () {},
            child: SizedBox(
              width: 50,
              height: 40,
              child: Image.asset(
                'assets/smaplogo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),

        const Spacer(),

        // Sağ taraf: Kullanıcı bilgileri ve avatar.
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.name ?? 'Yükleniyor...',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      studentBranch,
                      style: const TextStyle(
                        color: AppColors.primaryOrange,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const AppUserAvatar(radius: 16, borderWidth: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
