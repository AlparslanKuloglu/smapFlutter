/// What went wrong, in the terms the UI cares about.
///
/// Every code has an l10n key ([l10nKey]) whose string lives in
/// `lib/l10n/arb/errors_tr.arb`. The key is the ARB key, so the presentation
/// layer maps `code → AppLocalizations` getter with one exhaustive `switch`.
///
/// [offline] and [server] are separate on purpose: a server that answers 5xx
/// is not "no connection" (an offline banner for a backend failure sends the
/// user to check a connection that works).
enum AppErrorCode {
  /// The request left the device but the connection broke or was refused.
  network('errors_network'),

  /// A connect, send or receive deadline passed.
  timeout('errors_timeout'),

  /// The device has no usable route to the server.
  offline('errors_offline'),

  /// Credentials were rejected (wrong username or password) on a request that
  /// does not carry a session.
  unauthorized('errors_unauthorized'),

  /// The session cookie is no longer valid (401, 403 or a redirect to login
  /// on a request that needs a session).
  sessionExpired('errors_sessionExpired'),

  /// The account may not do this (403 outside the session-expiry policy).
  forbidden('errors_forbidden'),

  /// The resource does not exist (404).
  notFound('errors_notFound'),

  /// The server rejected the input (400, 409, 422).
  validation('errors_validation'),

  /// The server failed (5xx except 503) or answered something unusable.
  server('errors_server'),

  /// The server is in maintenance (503).
  maintenance('errors_maintenance'),

  /// The caller cancelled the request; usually not shown to the user.
  cancelled('errors_cancelled'),

  /// Anything else, including decoder failures.
  unknown('errors_unknown');

  const AppErrorCode(this.l10nKey);

  /// Key of this code's message in the ARB files.
  final String l10nKey;

  /// Whether a "Tekrar Dene" button makes sense.
  bool get isRetryable => switch (this) {
    network || timeout || offline || server || maintenance || unknown => true,
    unauthorized ||
    sessionExpired ||
    forbidden ||
    notFound ||
    validation ||
    cancelled => false,
  };

  /// Whether the user has to sign in again.
  bool get requiresSignIn => this == sessionExpired;

  /// Whether the UI should stay silent (the caller asked for the cancel).
  bool get isSilent => this == cancelled;
}
