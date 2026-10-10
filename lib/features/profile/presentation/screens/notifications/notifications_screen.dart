import 'package:flutter/material.dart';
import 'package:smap/core/theme/app_colors.dart';
import 'package:smap/features/profile/presentation/screens/notifications/widgets/notification_toggle_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isActive = true;
  bool _notificationsEnabled = true;
  bool _usersCanSee = false;
  bool _defaultNotification = false;
  bool _showOnMobile = false;
  bool _autoUpdates = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          NotificationToggleTile(
            label: 'Aktif',
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
          ),
          NotificationToggleTile(
            label: 'Bildirimleri Aç',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          NotificationToggleTile(
            label: 'Kullanıcılar Görebilsin',
            value: _usersCanSee,
            onChanged: (v) => setState(() => _usersCanSee = v),
          ),
          NotificationToggleTile(
            label: 'Varsayılan Bildirim',
            value: _defaultNotification,
            onChanged: (v) => setState(() => _defaultNotification = v),
          ),
          NotificationToggleTile(
            label: 'Mobilde Göster',
            value: _showOnMobile,
            onChanged: (v) => setState(() => _showOnMobile = v),
          ),
          NotificationToggleTile(
            label: 'Otomatik Güncellemeleri Aç',
            value: _autoUpdates,
            onChanged: (v) => setState(() => _autoUpdates = v),
            showDivider: false,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Değişiklikleri Kaydet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
