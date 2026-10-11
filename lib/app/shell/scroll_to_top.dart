import 'package:flutter/widgets.dart';

import 'package:smap/core/theme/app_motion.dart';

/// Scrolls the vertical lists under [root] back to the top (pano 1.19 "Seçili
/// sekmeye yeniden dokunmak köke döndürür ve başa kaydırır").
///
/// Every route has its own primary scroll controller, so the shell cannot
/// hold one for a tab. It walks the elements of the tab instead and animates
/// each vertical [Scrollable] that is scrolled. [duration] zero jumps (reduce
/// motion).
void scrollTabToTop(
  BuildContext root, {
  required Duration duration,
  Curve curve = AppMotion.standard,
}) {
  void visit(Element element) {
    if (element is StatefulElement && element.state is ScrollableState) {
      final position = (element.state as ScrollableState).position;
      if (position.axis == Axis.vertical && position.pixels > 0) {
        position.animateTo(0, duration: duration, curve: curve).ignore();
      }
    }
    element.visitChildren(visit);
  }

  if (root is Element && root.mounted) root.visitChildren(visit);
}
