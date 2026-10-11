import 'package:flutter/widgets.dart';

/// Where a state is drawn (C77, C78): the whole screen (or a tab's content)
/// or one section of a screen that keeps working around it.
enum AppStateLevel {
  /// Centered block: picture or icon circle, title, sentence, one action.
  screen,

  /// A card inside the page: one sentence and a text button.
  section,
}

/// A text button drawn without its 12 pt side padding so its label lines up
/// with the text above it (C77 "dolgu 0"). The layout is unchanged; only
/// the painting and the touch area move.
class AlignedTextAction extends StatelessWidget {
  const AlignedTextAction({required this.child, super.key});

  final Widget child;

  /// The text button's own side padding.
  static const double inset = 12;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(offset: const Offset(-inset, 0), child: child);
  }
}
