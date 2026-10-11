import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/guards/route_access.dart';

/// What the guards need to know about the router's routes, so they stay free
/// of the generated route classes (`AppRouter` implements it).
abstract interface class RouteCatalog {
  /// The group of the route called [routeName] (`XxxRoute.name`).
  RouteGroup groupOf(String routeName);

  /// The page a redirect to [target] opens.
  PageRouteInfo pageFor(RouteTarget target);
}
