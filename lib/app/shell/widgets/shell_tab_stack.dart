part of '../shell_frame.dart';

/// The four tab stacks side by side, only the selected one visible and
/// reachable (pano 1.19 "Ne zaman görünür": each tab keeps its own stack).
///
/// The tabs stay built (an `IndexedStack`), so a stack, a scroll position
/// and a half-filled form survive a tab switch. The inactive ones are out of
/// the focus order and the screen reader's reading order.
///
/// A [ShellTabContent.legacy] tab ends above the bar; a
/// [ShellTabContent.screen] tab runs under it. The media padding the body
/// gets from `extendBody` is put back to the device's own safe area, so a
/// screen adds the bar's height itself (`AppBottomBar.heightOf`).
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
    final barHeight = AppBottomBar.heightOf(context);
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
                data: specs[i].content == ShellTabContent.legacy
                    ? media.copyWith(
                        padding: media.padding.copyWith(bottom: 0),
                        viewPadding: media.viewPadding.copyWith(bottom: 0),
                      )
                    : media.copyWith(
                        padding: media.padding.copyWith(bottom: deviceBottom),
                      ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: specs[i].content == ShellTabContent.legacy
                        ? barHeight
                        : 0,
                  ),
                  child: KeyedSubtree(key: keys[i], child: child),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
