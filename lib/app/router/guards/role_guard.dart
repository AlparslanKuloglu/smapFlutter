import 'package:smap/app/router/guards/access_guard.dart';
import 'package:smap/app/router/guards/route_access.dart';

/// Third guard: a student gets the student shell, a coach the coach shell, an
/// unknown role "Hesabın açılamadı" (`roleStage`).
class RoleGuard extends AccessGuard {
  const RoleGuard({
    required super.catalog,
    required super.session,
    required super.preferences,
    super.logger,
  }) : super(stage: roleStage, name: 'RoleGuard');
}
