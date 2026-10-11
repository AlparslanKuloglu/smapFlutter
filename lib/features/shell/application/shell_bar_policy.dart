import 'package:smap/core/theme/app_spacing.dart';

/// What a tap on a bottom bar tab does (spec §3.1 "Seçili sekmeye yeniden
/// dokunmak dalın köküne döner ve başa kaydırır"; pano 1.19 "Ne zaman
/// görünür").
enum ShellTabAction {
  /// Another tab: show it, keeping its own stack as it was.
  switchTab,

  /// The tab that is already selected: pop its stack to the root page and
  /// scroll that page to the top.
  backToRoot,
}

/// The pure decisions of the shell (student and coach), apart from the widgets
/// so they are unit-tested.
abstract final class ShellBarPolicy {
  /// The action of a tap on tab [tapped] while tab [active] is selected.
  static ShellTabAction onTap({required int tapped, required int active}) =>
      tapped == active ? ShellTabAction.backToRoot : ShellTabAction.switchTab;

  /// Whether a bottom bar is on screen: a shell (one of [shellRouteNames])
  /// is the topmost page of the root stack. A full-screen flow on top of it
  /// (the camera, the result moment, sign-in) hides the bar by covering it
  /// (pano 1.19 "Ne zaman görünür"; spec §3.2).
  static bool barVisible({
    required List<String> rootStack,
    required Set<String> shellRouteNames,
  }) => rootStack.isNotEmpty && shellRouteNames.contains(rootStack.last);

  /// The value for `ToastService.bottomBarHeight`: the bar's height without
  /// the safe area while it shows, `null` while a full-screen flow hides it
  /// (a toast then sits at the bottom safe area plus 16; pano 1.19 "Toast ile
  /// ilişki").
  static double? toastBarHeight({required bool barVisible}) =>
      barVisible ? AppSize.bottomBar : null;
}
