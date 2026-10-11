import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart' hide StackedRouterExtensions;

import 'package:smap/app/router/app_router.dart';
import 'package:smap/app/router/stack_router_x.dart';
import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/dependency_injection/injection_container.dart';
import 'package:smap/features/auth/presentation/login/login_error_text.dart';
import 'package:smap/features/auth/presentation/login/login_viewmodel.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/session_manager.dart';
import 'package:smap/shared/ui/buttons/app_button.dart';
import 'package:smap/shared/ui/identity/app_logo.dart';
import 'package:smap/shared/ui/inputs/app_text_field.dart';
import 'package:smap/shared/ui/navigation/app_detail_bar.dart';
import 'package:smap/shared/ui/navigation/large_title_sliver.dart';
import 'package:smap/shared/ui/surfaces/app_notice_box.dart';

part 'widgets/login_bar.dart';
part 'widgets/login_brand.dart';
part 'widgets/login_fields.dart';
part 'widgets/login_footer.dart';
part 'widgets/login_notice.dart';
part 'widgets/login_social.dart';

/// The gap between the form's items and between the lockup and the title
/// (pano 2.3: "aralık 20", lockup bottom 146 to title top 174 with the title's
/// own 8). Not on the 4-pt scale of `AppSpacing`.
const double _formGap = 20;

/// Giriş (pano 2.3 kare 1 to 4; flow 13.2).
///
/// The back button, the SMAP lockup, "Giriş yap", the user name and the
/// password (with the show/hide button), "Şifremi Unuttum", the red box for
/// wrong credentials, the primary "Giriş Yap" and, at the bottom, "Hesabın yok
/// mu? Kayıt Ol". The Apple and Google variant (kare 4) and "Şifremi
/// Unuttum" are behind `FeatureFlags` and drawn only when they are on.
///
/// The back button is there only when a screen lies under this one (the
/// welcome screen opens it with a push, the "oturum bitti" sheet opens it over
/// the app); as the first screen of the signed-out app it has none. There is
/// no "Beni Hatırla": the session stays (T7.3). The role is read from the
/// account after the sign-in and the router's guards open the right shell.
///
/// A finished password reset brings the account's user name back; the field
/// then has it ready (`LoginViewModel.prefill`).
@RoutePage()
class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  bool get reactive => false;

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel(
    session: locator<SessionManager>(),
    router: locator<AppRouter>(),
    forgotPasswordEnabled: FeatureFlags.forgotPasswordEnabled,
    socialLoginEnabled: FeatureFlags.socialLoginEnabled,
  );

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) => const _LoginPage();
}

/// The page: bar, brand, title, form and the sign-up line, in one
/// `CustomScrollView` so the form scrolls above the keyboard and at large
/// text.
class _LoginPage extends StatelessWidget {
  const _LoginPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.appColors.bgCanvas,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          const _LoginBar(),
          const _LoginBrand(),
          LargeTitleSliver(
            title: l10n.login_title,
            gutter: AppSpacing.gutterAuth,
          ),
          const _LoginFormSection(),
          const _LoginFooter(),
        ],
      ),
    );
  }
}
