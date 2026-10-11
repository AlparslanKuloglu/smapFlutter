import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:smap/app/shell/shell_preview.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/home/presentation/provider/home_nav_provider.dart';
import 'package:smap/features/home/presentation/screens/home_flow_screen.dart';
import 'package:smap/features/legacy/legacy_theme.dart';
import 'package:smap/features/my_interviews/interviews_screen.dart';
import 'package:smap/features/my_students/my_students_screen.dart';
import 'package:smap/features/profile/presentation/provider/account_nav_provider.dart';
import 'package:smap/features/profile/presentation/screens/account/account_flow_screen.dart';
import 'package:smap/features/shared/presentation/provider/user_provider.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/repository/coach_repository.dart';
import 'package:smap/repository/profile_repository.dart';
import 'package:smap/shared/ui/buttons/app_icon_button.dart';
import 'package:smap/shared/ui/indicators/app_spinner.dart';
import 'package:smap/shared/ui/navigation/app_system_overlay.dart';

// The legacy screens as the root pages of the shell's tabs, until the screen
// tasks (E6 Anasayfa, E10 and on) replace them one by one (Rehber §7 E5
// "Geçiş"). Each page is the content the old `RootScreen` showed for that
// tab, with the Provider it got there (the legacy navigation notifiers of
// the hub screens); the repositories and the `UserProvider` come from
// `LegacyScope` above the router.
//
// What the old root drew around the tabs is gone: its bottom bar is the
// shell's now, and its top bar (logo, name, avatar, back) is replaced by a
// plain navy band with the tab's title and, inside a hub screen's sub page,
// a back button ([_LegacyBand]). The Derslerim tab has none, as before: its
// screen draws its own header.
//
// The pages sit in two themes: the band and the spinner under `SmapTheme`,
// the screen under `LegacyTheme` (the look it was built for).

/// Student Hesap tab (`/account`): the legacy account hub and its sub pages.
@RoutePage()
class LegacyAccountTabPage extends StatelessWidget {
  const LegacyAccountTabPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegacyAccountTab();
}

/// Coach Anasayfa tab (`/coach/home`): the legacy home hub (students).
@RoutePage()
class LegacyCoachHomeTabPage extends StatelessWidget {
  const LegacyCoachHomeTabPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegacyHomeTab();
}

/// Coach Öğrencilerim tab (`/coach/students`): the legacy student list.
@RoutePage()
class LegacyStudentsTabPage extends StatefulWidget {
  const LegacyStudentsTabPage({super.key});

  @override
  State<LegacyStudentsTabPage> createState() => _LegacyStudentsTabPageState();
}

class _LegacyStudentsTabPageState extends State<LegacyStudentsTabPage> {
  final CoachRepository _repository = CoachRepository();

  @override
  Widget build(BuildContext context) => _LegacyTabFrame(
    title: AppLocalizations.of(context).nav_tabStudents,
    child: MyStudentsScreen(coachRepository: _repository),
  );
}

/// Coach Görüşmelerim tab (`/coach/meetings`): the legacy meetings screen.
@RoutePage()
class LegacyMeetingsTabPage extends StatelessWidget {
  const LegacyMeetingsTabPage({super.key});

  @override
  Widget build(BuildContext context) => _LegacyTabFrame(
    title: AppLocalizations.of(context).nav_tabMeetings,
    child: const GorusmeFlowScreen(),
  );
}

/// Coach Hesap tab (`/coach/account`): the legacy account hub.
@RoutePage()
class LegacyCoachAccountTabPage extends StatelessWidget {
  const LegacyCoachAccountTabPage({super.key});

  @override
  Widget build(BuildContext context) => const _LegacyAccountTab();
}

/// The home hub with its [HomeNavNotifier]: the band shows "Anasayfa", or
/// the sub page's title ("Programım") with Back while a sub page is open.
class _LegacyHomeTab extends StatelessWidget {
  const _LegacyHomeTab();

  @override
  Widget build(BuildContext context) => _LegacyGate(
    child: ChangeNotifierProvider<HomeNavNotifier>(
      create: (_) => HomeNavNotifier(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<HomeNavNotifier>(
            builder: (context, nav, _) => _LegacyBand(
              title: nav.isHub
                  ? AppLocalizations.of(context).nav_tabHome
                  : nav.title,
              onBack: nav.showBackButton ? nav.backToHub : null,
            ),
          ),
          const Expanded(child: LegacyTheme(child: HomeFlowScreen())),
        ],
      ),
    ),
  );
}

/// The account hub with its [AccountNavNotifier] (hub, profile, notifications,
/// contracts ...).
class _LegacyAccountTab extends StatelessWidget {
  const _LegacyAccountTab();

  @override
  Widget build(BuildContext context) => _LegacyGate(
    child: ChangeNotifierProvider<AccountNavNotifier>(
      create: (_) => AccountNavNotifier(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Consumer<AccountNavNotifier>(
            builder: (context, nav, _) => _LegacyBand(
              title: nav.isHub
                  ? AppLocalizations.of(context).nav_tabAccount
                  : nav.title,
              onBack: nav.showBackButton ? nav.backToHub : null,
            ),
          ),
          Expanded(
            child: LegacyTheme(
              child: Builder(
                builder: (context) => AccountFlowScreen(
                  profileRepository: context.read<ProfileRepository>(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// A legacy tab with a band and no notifier of its own.
class _LegacyTabFrame extends StatelessWidget {
  const _LegacyTabFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => _LegacyGate(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LegacyBand(title: title),
        Expanded(child: LegacyTheme(child: child)),
      ],
    ),
  );
}

/// Shows [child] once the legacy `UserProvider` holds the user (the bridge in
/// `LegacyScope` loads it from the session), as the old root did; a spinner
/// until then. The shell preview has no user, so it passes straight through.
class _LegacyGate extends StatelessWidget {
  const _LegacyGate({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ready =
        ShellPreview.active ||
        context.select<UserProvider, bool>((user) => user.userRole != null);
    if (ready) return child;
    return ColoredBox(
      color: context.appColors.bgCanvas,
      child: Center(
        child: AppSpinner(
          semanticLabel: AppLocalizations.of(context).kit_loading,
        ),
      ),
    );
  }
}

/// The navy band over a legacy tab: [title] in white on `bgNavy` under the
/// status bar, with Back at the left when [onBack] is set (the old top bar's
/// only function the new shell does not have). Flat, 56 high; the real
/// `AppRootBand` is a sliver of the screen's own scroll view and comes with
/// the screen.
class _LegacyBand extends StatelessWidget {
  const _LegacyBand({required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final back = onBack;
    return AppSystemOverlayRegion(
      kind: AppSystemOverlayKind.band,
      child: ColoredBox(
        color: colors.bgNavy,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: AppSize.rowMin,
            child: Row(
              children: [
                if (back != null)
                  AppIconButton(
                    icon: PhosphorIconsRegular.caretLeft,
                    semanticLabel: AppLocalizations.of(context).nav_back,
                    variant: AppIconButtonVariant.onNavy,
                    onPressed: back,
                  )
                else
                  const SizedBox(width: AppSpacing.gutter),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.titleLg.copyWith(
                        color: colors.textOnNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.gutter),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
