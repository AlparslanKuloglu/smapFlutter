import 'dart:async';
import 'dart:io' show Platform;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;
import 'package:url_launcher/url_launcher.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/account_band_metrics.dart';
import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/account/application/app_version.dart';
import 'package:smap/features/account/application/system_label.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/account/account_viewmodel.dart';
import 'package:smap/features/account/presentation/account_texts.dart';
import 'package:smap/features/account/presentation/sheet_account_dialogs.dart';
import 'package:smap/features/account/presentation/stack_account_navigator.dart';
import 'package:smap/features/account/presentation/widgets/profile_summary.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';
import 'package:smap/shared/ui/surfaces/app_row.dart';
import 'package:smap/shared/ui/surfaces/app_row_group.dart';
import 'package:smap/shared/ui/surfaces/app_row_shell.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';

part 'widgets/account_band.dart';
part 'widgets/account_code_row.dart';
part 'widgets/account_footer.dart';
part 'widgets/account_groups.dart';

/// Hesap, the root of the account tab for both roles (pano 9.1 kare 1 to 4;
/// spec §4.H 9.1; flow 13.10; routes `/account` and `/coach/account`).
///
/// The navy band with the title and the profile summary (it shrinks to one
/// line as the page scrolls, kare 2), then the groups: "Hesap" (Profil,
/// Şifre), "Koçluk" (a student's coach, or a coach's code to copy and share),
/// "Bildirimler", "Yasal" (Sözleşmeler), "Destek" ("Bize Yaz", only with a
/// configured address), the red "Çıkış Yap" in a group of its own and the
/// version line. Everything on it comes from the signed-in account on the
/// device, so there is no skeleton and no error state; only the coach's name
/// waits for a request and is left out until it arrives. The offline strip is
/// the shell's.
///
/// The role comes from `CurrentUserService`: a coach has no "Koçluk" screen
/// and no grade or track; the page is otherwise the same.
@RoutePage()
class AccountView extends StackedView<AccountViewModel> {
  const AccountView({super.key});

  @override
  bool get reactive => false;

  @override
  AccountViewModel viewModelBuilder(BuildContext context) => AccountViewModel(
    currentUser: locator<CurrentUserService>(),
    accounts: locator<AccountRepository>(),
    session: locator<SessionManager>(),
    navigator: StackAccountNavigator(context.router),
    dialogs: SheetAccountDialogs(l10n: AppLocalizations.of(context)),
    toast: locator<ToastService>(),
    config: locator<AppConfig>(),
    readVersion: _readVersion,
    systemLabel: () => SystemLabel.of(
      Platform.operatingSystem,
      Platform.operatingSystemVersion,
    ),
    openUrl: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
    copyText: (text) => Clipboard.setData(ClipboardData(text: text)),
    shareText: (text, {origin}) async {
      await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: origin),
      );
    },
  );

  @override
  void onViewModelReady(AccountViewModel viewModel) =>
      unawaited(viewModel.init());

  @override
  Widget builder(
    BuildContext context,
    AccountViewModel viewModel,
    Widget? child,
  ) => const _AccountPage();
}

/// The version of the installed build, `null` when the platform cannot tell.
Future<AppVersion?> _readVersion() async {
  final info = await PackageInfo.fromPlatform();
  return AppVersion(version: info.version, build: info.buildNumber);
}

/// The gap between the groups (pano 9.1: "gruplar arası 20").
const double _groupGap = 20;

/// The page: the band, the groups and the version line in one
/// `CustomScrollView`; the tab runs under the bottom bar, so the page ends
/// `AppBottomBar.heightOf` above the edge.
class _AccountPage extends StatelessWidget {
  const _AccountPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          const _AccountBand(),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.s16,
              AppSpacing.gutter,
              AppBottomBar.heightOf(context) + AppSpacing.s16,
            ),
            sliver: const SliverList(
              delegate: SliverChildListDelegate.fixed([
                _AccountGroups(),
                SizedBox(height: AppSpacing.s16),
                _AccountVersion(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
