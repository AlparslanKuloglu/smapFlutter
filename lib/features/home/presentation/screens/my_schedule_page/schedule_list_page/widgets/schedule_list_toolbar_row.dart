import 'package:flutter/material.dart';

class ScheduleListToolbarRow extends StatelessWidget {
  const ScheduleListToolbarRow({
    super.key,
    this.leading,
    required this.center,
    this.trailing,
  });

  static const padding = EdgeInsets.fromLTRB(16, 8, 16, 16);
  static const gap = 8.0;

  final Widget? leading;
  final Widget center;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: gap),
            ],
            Expanded(child: center),
            if (trailing != null) ...[
              const SizedBox(width: gap),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class ScheduleListToolbarSideButton extends StatelessWidget {
  const ScheduleListToolbarSideButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: 1, child: child);
  }
}
