import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/phone_number.dart';
import 'package:smap/features/account/application/profile_draft.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/domain/school_grade.dart';
import 'package:smap/features/account/domain/study_track.dart';
import 'package:smap/features/account/presentation/account_texts.dart';
import 'package:smap/features/account/presentation/profile/profile_viewmodel.dart';
import 'package:smap/features/account/presentation/sheet_account_dialogs.dart';
import 'package:smap/features/account/presentation/stack_account_navigator.dart';
import 'package:smap/features/home/application/avatar_asset.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/buttons/app_bar_action.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/feedback/app_error_state.dart';
import 'package:smap/shared/ui/feedback/app_state_level.dart';
import 'package:smap/shared/ui/identity/app_avatar.dart';
import 'package:smap/shared/ui/inputs/app_field_frame.dart';
import 'package:smap/shared/ui/inputs/app_select_field.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/inputs/input_masks.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';

part 'widgets/profile_bar.dart';
part 'widgets/profile_delete.dart';
part 'widgets/profile_edit_form.dart';
part 'widgets/profile_identity.dart';
part 'widgets/profile_view_fields.dart';

/// Profil (pano 9.2 kare 1 to 4; spec §4.H 9.2; flow 13.10; route
/// `/account/profile`).
///
/// One screen with two modes. Reading (kare 1): "Düzenle" in the bar, the
/// avatar with "Avatarı Değiştir", the account's values in read-only boxes
/// (a value the account does not have is not drawn). Editing (kare 2):
/// "Vazgeç" and "Kaydet" in the bar, Ad Soyad, E-posta and Telefon open, the
/// user name locked, Sınıf and Alan as choices in sheets (kare 4); the
/// avatar is chosen in its own sheet (kare 3). A coach has no Sınıf and
/// Alan. "Hesabı Sil" ends the page.
///
/// Everything is on the device, so there is no skeleton; an account that is
/// not there reads as an error state with "Tekrar Dene". The page scrolls
/// under the bottom bar like the other tab screens.
@RoutePage()
class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  bool get reactive => false;

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel(
    currentUser: locator<CurrentUserService>(),
    accounts: locator<AccountRepository>(),
    navigator: StackAccountNavigator(context.router),
    dialogs: SheetAccountDialogs(l10n: AppLocalizations.of(context)),
    toast: locator<ToastService>(),
    online: locator<ConnectivityService>().online,
  );

  @override
  Widget builder(
    BuildContext context,
    ProfileViewModel viewModel,
    Widget? child,
  ) => const _ProfileGuard();
}

/// The gap between the form's rows (pano 9.2: "satırlar arası 16").
const double _fieldGap = 16;

/// Asks before a back gesture throws away an open form's changes
/// ("Değişiklikler kaydedilmesin mi?"); otherwise the screen leaves as usual.
class _ProfileGuard extends SelectorViewModelWidget<ProfileViewModel, bool> {
  const _ProfileGuard();

  @override
  bool selector(ProfileViewModel viewModel) => viewModel.hasUnsavedChanges;

  @override
  Widget build(BuildContext context, bool dirty) {
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final viewModel = getParentViewModel<ProfileViewModel>(
          context,
          listen: false,
        );
        final leave = await viewModel.confirmLeave();
        if (leave && context.mounted) context.router.pop();
      },
      child: const _ProfilePage(),
    );
  }
}

/// The page: the bar, the title and the form, or the unavailable state.
class _ProfilePage extends SelectorViewModelWidget<ProfileViewModel, bool> {
  const _ProfilePage();

  @override
  bool selector(ProfileViewModel viewModel) => viewModel.hasUser;

  @override
  Widget build(BuildContext context, bool hasUser) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProfileViewModel>(
      context,
      listen: false,
    );
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        slivers: [
          const _ProfileBar(),
          LargeTitleSliver(title: l10n.account_profileTitle),
          if (hasUser)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                AppSpacing.s8,
                AppSpacing.gutter,
                AppBottomBar.heightOf(context) + AppSpacing.s16,
              ),
              sliver: const SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _ProfileAvatarRow(),
                  SizedBox(height: _fieldGap),
                  _ProfileViewFields(),
                  _ProfileEditFields(),
                  _ProfileDelete(),
                ]),
              ),
            )
          else
            SliverToBoxAdapter(
              child: AppErrorState.screen(
                title: l10n.account_profileErrorTitle,
                message: l10n.account_loadErrorMessage,
                onRetry: () => unawaited(viewModel.retry()),
              ),
            ),
        ],
      ),
    );
  }
}
