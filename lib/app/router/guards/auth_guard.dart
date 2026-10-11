import 'package:smap/app/router/guards/access_guard.dart';
import 'package:smap/app/router/guards/route_access.dart';

/// Second guard: shells need a session, the sign-in doors need none
/// (`authStage`).
class AuthGuard extends AccessGuard {
  const AuthGuard({
    required super.catalog,
    required super.session,
    required super.preferences,
    super.logger,
  }) : super(stage: authStage, name: 'AuthGuard');
}
