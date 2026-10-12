import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';

/// One tab of a shell: the route of its stack and what its root shows.
@immutable
class ShellTabSpec {
  const ShellTabSpec({required this.route});

  /// The tab's stack route (`HomeTabRoute()`): an empty shell page that holds
  /// the tab's own navigator.
  final PageRouteInfo route;
}
