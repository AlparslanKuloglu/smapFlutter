import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/core/theme/app_colors.dart';
import 'package:studentmap/features/profile/presentation/provider/account_nav_provider.dart';
import 'package:studentmap/features/profile/presentation/screens/account/widgets/account_menu_tile.dart';
import 'package:studentmap/features/shared/presentation/provider/user_provider.dart';
import 'package:studentmap/features/auth/data/repositories/auth_repository_impl.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  // Çıkış yapma onay dialogu ve mantığı
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                'Çıkış Yap?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: const Text(
            'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
            style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Dialog'ı kapat
              child: const Text(
                'Vazgeç',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // 1. Önce Dialog'u kapat
                Navigator.pop(dialogContext);

                // 2. main.dart'ta AuthRepositoryImpl olarak sağlandığı için onu çağırıyoruz
                await context.read<AuthRepositoryImpl>().logout();

                if (!context.mounted) return;

                // 3. UserProvider durumunu sıfırla
                context.read<UserProvider>().clearUserData();

                // 4. Login ekranına yönlendir
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountNav = context.read<AccountNavNotifier>();

    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          AccountMenuTile(
            title: 'Profilim ve Şifre',
            svgPath: "assets/svgs/personalcard.svg",
            onTap: () => accountNav.open(AccountRoute.account),
          ),
          AccountMenuTile(
            title: 'Ödeme ve Paketler',
            svgPath: "assets/svgs/bag.svg",
            onTap: () => accountNav.open(AccountRoute.payment),
          ),
          AccountMenuTile(
            title: 'Kayıtlı Kartlarım',
            svgPath: "assets/svgs/cards.svg",
            onTap: () => accountNav.open(AccountRoute.savedCards),
          ),
          AccountMenuTile(
            title: 'Sözleşmeler',
            svgPath: "assets/svgs/note.svg",
            onTap: () => accountNav.open(AccountRoute.contracts),
          ),
          AccountMenuTile(
            title: 'Bildirimler',
            svgPath: "assets/svgs/ntf.svg",
            onTap: () => accountNav.open(AccountRoute.notifications),
          ),

          // --- ÇIKIŞ YAP ALANI ---
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Color(0xFFE8ECF0), thickness: 1),
          ),
          AccountMenuTile(
            title: 'Çıkış Yap',
            svgPath: "assets/svgs/logout.svg",
            textColor: Colors.redAccent,
            iconColor: Colors.redAccent,
            showChevron: false, // Sağdaki oku kaldırdık
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }
}
