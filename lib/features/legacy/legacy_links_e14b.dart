import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import 'package:smap/app/router/app_router.dart';

/// Opens the new "Bildirimler" (pano 9.6, E14b) from the legacy Hesap list's
/// "Bildirimler" row, on the Hesap tab's own stack so the bottom bar stays.
///
/// The legacy list (`AccountScreen`) is replaced by E14a's Hesap, which lists
/// `NotificationsRoute` itself; delete this file and the one call in
/// `AccountScreen` with it.
void openNotificationsFromLegacyHub(BuildContext context) {
  unawaited(context.router.push(const NotificationsRoute()));
}
