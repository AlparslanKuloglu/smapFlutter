import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/core/utils/tr_format.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/notification_preferences.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/data/notification_permission_gateway.dart';
import 'package:smap/features/account/presentation/notifications/notifications_dialogs.dart';
import 'package:smap/features/account/presentation/notifications/notifications_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/controls/app_switch.dart';
import 'package:smap/features/account/presentation/account_bar_clearance.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';

part 'widgets/notifications_categories.dart';
part 'widgets/notifications_notice.dart';
part 'widgets/notifications_quiet.dart';

/// Bildirimler (pano 9.6 "Bildirimler · 3 kare"; flow 13.10; spec §4.C 9.6;
/// route `/account/notifications`).
///
/// The back button and the title, the box ("Bildirimler planlı: ..." or, when
/// the system permission is off, "Bildirim izni kapalı. ..." with "Ayarları
/// Aç"), the group "Kategoriler" with four switches, the group "Sessiz
/// saatler" with its switch and the "Başlangıç" and "Bitiş" rows that open the
/// time wheel, and the note "Değişiklikler anında kaydedilir." There is no
/// Save button.
///
/// The choices live on the device (see [NotificationsViewModel]); the screen
/// reads the permission again whenever the app comes back to the front.
@RoutePage()
class NotificationsView extends StackedView<NotificationsViewModel> {
  const NotificationsView({super.key});

  @override
  bool get reactive => false;

  @override
  NotificationsViewModel viewModelBuilder(BuildContext context) {
    final preferences = locator<DevicePreferences>();
    return NotificationsViewModel(
      store: NotificationPreferencesStore(preferences),
      permission: const PermissionHandlerNotificationPermission(),
      dialogs: SheetNotificationsDialogs(l10n: AppLocalizations.of(context)),
      currentUser: locator<CurrentUserService>(),
      account: locator<AccountRepository>(),
      preferences: preferences,
      notificationsEnabled: FeatureFlags.notificationsEnabled,
    );
  }

  @override
  void onViewModelReady(NotificationsViewModel viewModel) => viewModel.init();

  @override
  Widget builder(
    BuildContext context,
    NotificationsViewModel viewModel,
    Widget? child,
  ) => _NotificationsPage(viewModel: viewModel);
}

/// The page: the bar, the title, the box and the groups in one
/// `CustomScrollView`; the tab runs under the bottom bar. It follows the app's
/// life cycle: coming back from the system settings reads the permission
/// again.
class _NotificationsPage extends StatefulWidget {
  const _NotificationsPage({required this.viewModel});

  final NotificationsViewModel viewModel;

  @override
  State<_NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<_NotificationsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.viewModel.refreshPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context).notifications_title;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          AppDetailBar(title: title),
          LargeTitleSliver(title: title),
          const _NoticeSliver(),
          const _CategoriesSliver(),
          const _QuietSliver(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: accountBarClearance(context) + AppSpacing.s16,
            ),
          ),
        ],
      ),
    );
  }
}

/// The gap between the box and the groups (pano 9.6: "bölümler arası 20"). Not
/// on the 4-pt scale of `AppSpacing`.
const double _sectionGap = 20;
