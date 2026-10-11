import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

/// Helpers on the stack of a router (pattern of Sepello's
/// `stack_router_x.dart`).
extension StackRouterX on StackRouter {
  /// The name of the page under the top one, if any.
  String? get belowName =>
      stack.length < 2 ? null : stack[stack.length - 2].name;

  /// Goes back when [route] is the page underneath; pushes it otherwise.
  ///
  /// For two pages that open each other without piling up.
  Future<void> pushOrPop(PageRouteInfo route) async {
    if (belowName == route.routeName) {
      await maybePop();
    } else {
      await push(route);
    }
  }
}

/// Helpers on a page's context.
extension RouteBelowContext on BuildContext {
  /// The name of the page under this page in its stack, also while another
  /// page covers it: for the back button's label.
  String? get routeBelowName {
    final data = RouteData.of(this);
    final stack = AutoRouter.of(this).stackData;
    final index = stack.indexOf(data);
    return index > 0 ? stack[index - 1].name : null;
  }
}
