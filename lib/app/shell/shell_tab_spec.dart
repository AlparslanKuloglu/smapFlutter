import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

/// What a tab's root page is made of: decides how the shell lays it out.
enum ShellTabContent {
  /// A legacy screen (Rehber §7 "Geçiş"): it knows nothing of the bottom bar,
  /// so the shell ends the tab above the bar, and the pages the legacy
  /// screens push (`MaterialPageRoute` on the tab's navigator) stay clear of
  /// it too. Flips to [screen] when the tab's screen task replaces the
  /// legacy page.
  legacy,

  /// A new screen (`XxxView`): one `CustomScrollView` that scrolls under the
  /// bar (`extendBody`), with the bottom padding
  /// `AppBottomBar.heightOf(context)` of its own (Rehber §6 madde 13).
  screen,
}

/// One tab of a shell: the route of its stack and what its root shows.
@immutable
class ShellTabSpec {
  const ShellTabSpec({
    required this.route,
    this.content = ShellTabContent.legacy,
  });

  /// The tab's stack route (`HomeTabRoute()`): an empty shell page that holds
  /// the tab's own navigator.
  final PageRouteInfo route;

  final ShellTabContent content;
}
