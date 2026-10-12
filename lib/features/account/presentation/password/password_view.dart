import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/account/application/password_repository.dart';
import 'package:smap/features/account/application/password_rules.dart';
import 'package:smap/features/account/presentation/password/password_navigator.dart';
import 'package:smap/features/account/presentation/password/password_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';

part 'widgets/password_form.dart';

/// Şifre (pano 9.3 "Şifre · 3 kare"; flow 13.10; spec §4.C 9.3; route
/// `/account/password`).
///
/// The back button, the title "Şifre" and three labelled password fields,
/// "Mevcut şifre", "Yeni şifre" (with the rule "En az 8 karakter." under it)
/// and "Yeni şifre (tekrar)", then the single primary button "Şifreyi
/// Güncelle". A wrong current password is drawn under the first field and
/// keeps the focus there (kare 2); success returns to Hesap with the toast
/// "Şifren güncellendi." (kare 3).
///
/// The route is open only while `FeatureFlags.passwordChangeEnabled` is on
/// (it is not in the route list otherwise) and needs a `PasswordRepository`
/// in the locator, which does not exist until the backend has the endpoint
/// (spec §6.3 #8).
@RoutePage()
class PasswordView extends StackedView<PasswordViewModel> {
  const PasswordView({super.key});

  @override
  bool get reactive => false;

  @override
  PasswordViewModel viewModelBuilder(BuildContext context) => PasswordViewModel(
    repository: locator<PasswordRepository>(),
    navigator: RouterPasswordNavigator(context.router),
    toast: locator<ToastService>(),
  );

  @override
  Widget builder(
    BuildContext context,
    PasswordViewModel viewModel,
    Widget? child,
  ) => const _PasswordPage();
}

/// The page: the bar, the title and the form in one `CustomScrollView`; the
/// tab runs under the bottom bar.
class _PasswordPage extends StatelessWidget {
  const _PasswordPage();

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context).password_title;
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          AppDetailBar(title: title),
          LargeTitleSliver(title: title),
          const _PasswordFormSection(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppBottomBar.heightOf(context) + AppSpacing.s16,
            ),
          ),
        ],
      ),
    );
  }
}
