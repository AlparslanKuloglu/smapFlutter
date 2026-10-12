import 'package:flutter/widgets.dart';
import 'package:smap/shared/ui/navigation/app_bottom_bar.dart';

/// How far the bottom bar reaches up from the screen's edge on a Hesap
/// screen: the bar's 68 plus the device's bottom inset (home indicator).
///
/// `AppBottomBar.heightOf(context)` reads the inset from `MediaQuery`, but
/// inside the shell's `Scaffold` body the bottom `viewPadding` is already
/// zero (the Scaffold removes it for the body), so the call comes out 34 pt
/// short on a phone with a home indicator and the last row or the pinned
/// buttons slip under the bar (checked on the simulator: "Vazgeç" of Hesabını
/// sil half hidden). The inset is read from the view itself instead.
double accountBarClearance(BuildContext context) => AppBottomBar.heightOf(
  context,
  safeBottom: MediaQueryData.fromView(View.of(context)).viewPadding.bottom,
);
