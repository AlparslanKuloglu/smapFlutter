import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentmap/repository/profile_repository.dart';
import 'package:studentmap/features/profile/presentation/provider/account_nav_provider.dart';
import 'package:studentmap/features/profile/presentation/screens/account/account_screen.dart';
import 'package:studentmap/features/profile/presentation/screens/account_settings/account_settings_screen.dart';
import 'package:studentmap/features/profile/presentation/screens/contracts/contracts_screen.dart';
import 'package:studentmap/features/profile/presentation/screens/notifications/notifications_screen.dart';
import 'package:studentmap/features/profile/presentation/screens/payment_settings/payment_settings_screen.dart';
import 'package:studentmap/features/profile/presentation/screens/saved_cards/saved_cards_screen.dart';

class AccountFlowScreen extends StatelessWidget {
  // 1. Akış ekranının constructor'ına repository parametresini ekliyoruz
  final ProfileRepository profileRepository;

  const AccountFlowScreen({
    super.key,
    required this.profileRepository, // Zorunlu parametre yaptık
  });

  @override
  Widget build(BuildContext context) {
    final route = context.watch<AccountNavNotifier>().route;

    return PopScope(
      canPop: route == AccountRoute.hub,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.read<AccountNavNotifier>().backToHub();
      },
      child: switch (route) {
        AccountRoute.hub => const AccountScreen(),
        // 2. İlgili route tetiklendiğinde repository'yi buraya paslıyoruz
        AccountRoute.account => AccountSettingsScreen(
          profileRepository: profileRepository,
        ),
        AccountRoute.payment => const PaymentSettingsScreen(),
        AccountRoute.savedCards => const SavedCardsScreen(),
        AccountRoute.contracts => const ContractsScreen(),
        AccountRoute.notifications => const NotificationsScreen(),
      },
    );
  }
}
