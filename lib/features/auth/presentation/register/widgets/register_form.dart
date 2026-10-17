part of '../register_view.dart';

/// The side padding of the 2.x screens (pano 2.5: 24).
const double _registerGutter = AppSpacing.gutterAuth;

/// The gap between two fields and between the sections (pano 2.5 "aralık 20").
const double _registerFieldGap = 20;

/// The gap between the large title and the role segment (pano 2.5 kare 1).
const double _registerTitleGap = _registerFieldGap;

/// What the page's sections share: the text controllers, the focus nodes (so
/// the ViewModel can send focus to the first wrong field), one anchor per
/// field to scroll to, and whether the role segment is stuck under the bar.
class _RegisterScope extends InheritedWidget {
  const _RegisterScope({
    required this.fullName,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordRepeat,
    required this.focus,
    required this.anchors,
    required this.roleStuck,
    required super.child,
  });

  final TextEditingController fullName;
  final TextEditingController username;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController passwordRepeat;
  final Map<RegisterField, FocusNode> focus;
  final Map<RegisterField, GlobalKey> anchors;
  final ValueListenable<bool> roleStuck;

  static _RegisterScope of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_RegisterScope>()!;

  @override
  bool updateShouldNotify(_RegisterScope oldWidget) => false;
}

/// The fields in screen order with 20 between them (pano 2.5).
class _RegisterForm extends StatelessWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AvatarSection(),
        SizedBox(height: _registerFieldGap),
        _FullNameField(),
        SizedBox(height: _registerFieldGap),
        _UsernameField(),
        SizedBox(height: _registerFieldGap),
        _EmailField(),
        SizedBox(height: _registerFieldGap),
        _PasswordFields(),
        SizedBox(height: _registerFieldGap),
        _SchoolSection(),
        SizedBox(height: _registerFieldGap),
        _ConsentSection(),
        SizedBox(height: _registerFieldGap),
        _SubmitSection(),
      ],
    );
  }
}

/// The scroll offset at which the role segment reaches the bar: the large
/// title's height and top padding plus the gap under it; never (infinity)
/// while the role segment is not drawn (`FeatureFlags.coachSignUpEnabled`).
double _registerStuckAt(BuildContext context, bool roleBarShown) {
  if (!roleBarShown) return double.infinity;
  final height = LargeTitleMetrics.titleHeight(
    title: AppLocalizations.of(context).register_title,
    style: context.appText.titleLg,
    width: MediaQuery.sizeOf(context).width - 2 * _registerGutter,
    textScaler: MediaQuery.textScalerOf(context),
    textDirection: Directionality.of(context),
  );
  return LargeTitleMetrics.titleBottom(height) + _registerTitleGap;
}
