part of 'question_cell.dart';

/// The face of a form-check cell: read, blank read (dashed) or corrected.
class _FormCheckCell extends StatelessWidget {
  const _FormCheckCell({
    required this.number,
    required this.status,
    required this.marked,
  });

  final int number;
  final FormCheckStatus status;
  final String? marked;

  /// Edge width of the dashed and the corrected cell.
  static const double _edge = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final letter = marked?.trim() ?? '';
    final corrected = status == FormCheckStatus.corrected;
    final blankRead = status == FormCheckStatus.blankRead;
    final fill = switch (status) {
      FormCheckStatus.read => colors.bgSurface,
      FormCheckStatus.blankRead => colors.eksikBg,
      FormCheckStatus.corrected => colors.infoBg,
    };
    final markColor = corrected
        ? colors.primary
        : (blankRead || letter.isEmpty
              ? colors.textSecondary
              : colors.textPrimary);
    final small = text.caption.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w600,
      height: 16 / 13,
    );
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: blankRead ? 6 : AppSpacing.s8,
        vertical: blankRead ? 2 : 4,
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text('$number', style: small),
          ),
          if (corrected)
            Align(
              alignment: Alignment.topRight,
              child: PhosphorIcon(
                PhosphorIconsRegular.pencilSimple,
                size: 14,
                color: colors.primary,
              ),
            ),
          Center(
            child: Text(
              letter.isEmpty ? QuestionCell.blankMark : letter,
              style: text.titleMd.copyWith(
                color: markColor,
                height: 24 / 20,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );

    if (blankRead) {
      return CustomPaint(
        foregroundPainter: _DashedEdgePainter(
          color: colors.eksik,
          width: _edge,
          radius: AppRadius.sm,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.borderSm,
          ),
          child: content,
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: corrected ? colors.primary : colors.borderSubtle,
          width: corrected ? _edge : 1,
        ),
      ),
      child: content,
    );
  }
}

/// A dashed rounded edge drawn inside the box (the "Boş okundu" cell).
class _DashedEdgePainter extends CustomPainter {
  const _DashedEdgePainter({
    required this.color,
    required this.width,
    required this.radius,
  });

  final Color color;
  final double width;
  final double radius;

  static const double _dash = 4;
  static const double _gap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = width / 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, size.width - width, size.height - width),
          Radius.circular(radius - inset),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedEdgePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.width != width ||
      oldDelegate.radius != radius;
}
