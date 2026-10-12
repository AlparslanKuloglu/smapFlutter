part of '../shell_frame.dart';

/// The four tab stacks side by side, only the selected one visible and
/// reachable (pano 1.19 "Ne zaman görünür": each tab keeps its own stack).
///
/// The tabs stay built (an `IndexedStack`), so a stack, a scroll position
/// and a half-filled form survive a tab switch. The inactive ones are out of
/// the focus order and the screen reader's reading order.
///
/// Every tab runs under the bar. The media padding the body gets from
/// `extendBody` is put back to the device's own safe area, so a screen adds
/// the bar's height itself (`AppBottomBar.heightOf`).
class _ShellTabStack extends StatelessWidget {
  const _ShellTabStack({
    required this.activeIndex,
    required this.specs,
    required this.keys,
    required this.children,
  });

  final int activeIndex;
  final List<ShellTabSpec> specs;
  final List<GlobalKey> keys;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final deviceBottom = media.viewPadding.bottom;
    return IndexedStack(
      index: activeIndex,
      sizing: StackFit.expand,
      children: [
        for (final (i, child) in children.indexed)
          ExcludeSemantics(
            excluding: i != activeIndex,
            child: ExcludeFocus(
              excluding: i != activeIndex,
              child: MediaQuery(
                data: media.copyWith(
                  padding: media.padding.copyWith(bottom: deviceBottom),
                ),
                child: KeyedSubtree(key: keys[i], child: child),
              ),
            ),
          ),
      ],
    );
  }
}
