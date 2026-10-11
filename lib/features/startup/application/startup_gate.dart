/// What stops the app from opening at launch.
enum StartupBlock {
  /// Nothing: the app opens.
  none,

  /// This version is below the minimum the backend accepts.
  forceUpdate,

  /// The server answers that it is in maintenance.
  maintenance,
}

/// Decides at launch whether the app may open (spec §3.1 "Global redirect
/// sırası", steps 1 and 2).
///
/// Both checks need a public config endpoint the backend does not have yet
/// (`/public-config`, backend question S10), so the shipped gate is
/// [DisabledStartupGate] and the two stop screens are reachable only through
/// this seam. Replace the registration in `registerStartupServices` when the
/// endpoint exists.
abstract interface class StartupGate {
  /// The block that applies now; never throws, answers [StartupBlock.none]
  /// when it cannot tell.
  Future<StartupBlock> check();
}

/// The trigger flag, closed: no version floor, no maintenance signal.
final class DisabledStartupGate implements StartupGate {
  const DisabledStartupGate();

  @override
  Future<StartupBlock> check() async => StartupBlock.none;
}
