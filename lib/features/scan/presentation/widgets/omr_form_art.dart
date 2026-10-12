import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smap/core/theme/smap_colors.dart';

/// The optical form as the boards draw it (pano 4.1 kare 1, 4.2): a sheet
/// of 300 x 470 units with a title and three boxes, the grey strip of the
/// subject names, and the answer area of four columns of 40 rows of five
/// bubbles with a few marked ones; the answer area has its corner squares.
///
/// It is a printed sheet, so it keeps the paper's colors in both themes (the
/// light roles); only what stands behind it follows the theme. [paint] draws
/// in the form's own units: the caller moves and scales the canvas first.
abstract final class OmrFormArt {
  /// Width and height of the sheet in its own units.
  static const double width = 300;
  static const double height = 470;

  /// The answer area: its frame and the four columns.
  static const Rect answerFrame = Rect.fromLTWH(6, 112, 288, 350);
  static const Rect strip = Rect.fromLTWH(6, 80, 288, 24);

  static const double _gridTop = 117;
  static const double _gridHeight = 340;
  static const double _rowHeight = 8.5;
  static const List<double> _columnX = [6, 78, 150, 222];

  /// The bubbles' centers in a row, from the column's left edge.
  static const List<double> _bubbleX = [20, 31, 42, 53, 64];

  /// The marked bubbles of one block of eight rows: (x, y) from the column's
  /// top left.
  static const List<Offset> _marks = [
    Offset(42, 4.25),
    Offset(20, 12.75),
    Offset(53, 21.25),
    Offset(31, 29.75),
    Offset(64, 38.25),
    Offset(42, 46.75),
    Offset(31, 55.25),
    Offset(53, 63.75),
  ];
  static const double _markBlock = 68;

  /// The four corner squares of the answer area.
  static const List<Offset> _cornerSquares = [
    Offset(3, 109),
    Offset(291, 109),
    Offset(3, 459),
    Offset(291, 459),
  ];

  /// Draws the sheet. [hatchStrip] crosses out the subject-name strip in red
  /// (pano 4.2: "ders adları şeridi kırmızı taralı"); [frame] draws the
  /// orange dashed answer-area frame with its four handles of radius
  /// [handleRadius].
  static void paint(
    Canvas canvas,
    SmapColors colors, {
    bool hatchStrip = true,
    bool frame = true,
    double handleRadius = 10,
  }) {
    const paper = SmapColors.light;
    final line = paper.borderStrong;
    final faint = paper.textDisabled;
    final ink = paper.textSecondary;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-1, -1, 302, 472),
        const Radius.circular(6),
      ),
      Paint()
        ..color = paper.bgSurface
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-1, -1, 302, 472),
        const Radius.circular(6),
      ),
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final fill = Paint()..style = PaintingStyle.fill;
    void bar(Rect rect, Color color) => canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      fill..color = color,
    );
    bar(const Rect.fromLTWH(14, 14, 150, 6), line);
    bar(const Rect.fromLTWH(14, 26, 110, 6), line);
    final box = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final x in const [14.0, 104.0, 194.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 44, 84, 26),
          const Radius.circular(2),
        ),
        box,
      );
    }
    canvas.drawRect(strip, fill..color = paper.bgSunken);
    for (final x in const [20.0, 92.0, 164.0, 236.0]) {
      bar(Rect.fromLTWH(x, 88, 44, 7), faint);
    }
    canvas.drawRect(answerFrame, box);

    for (final x in _columnX) {
      _paintColumn(canvas, x, faint, ink);
    }
    for (final corner in _cornerSquares) {
      canvas.drawRect(
        Rect.fromLTWH(corner.dx, corner.dy, 6, 6),
        fill..color = ink,
      );
    }

    if (hatchStrip) _paintHatch(canvas, paper.error);
    if (frame) _paintFrame(canvas, paper, handleRadius);
  }

  static void _paintColumn(Canvas canvas, double x, Color faint, Color ink) {
    final dash = Paint()..color = faint;
    final bubble = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    final mark = Paint()..color = ink;
    final rows = (_gridHeight / _rowHeight).floor();
    for (var row = 0; row < rows; row++) {
      final top = _gridTop + row * _rowHeight;
      canvas.drawRect(Rect.fromLTWH(x + 2, top + 3.45, 8, 1.6), dash);
      for (final cx in _bubbleX) {
        canvas.drawCircle(Offset(x + cx, top + 4.25), 2.5, bubble);
      }
    }
    final blocks = (_gridHeight / _markBlock).ceil();
    for (var block = 0; block < blocks; block++) {
      for (final point in _marks) {
        final y = _gridTop + block * _markBlock + point.dy;
        if (y > _gridTop + _gridHeight) continue;
        canvas.drawCircle(Offset(x + point.dx, y), 2.6, mark);
      }
    }
  }

  static void _paintHatch(Canvas canvas, Color red) {
    canvas
      ..save()
      ..clipRect(strip)
      ..translate(strip.left, strip.top)
      ..rotate(math.pi / 4);
    final stripe = Paint()
      ..color = red.withValues(alpha: 0.55)
      ..strokeWidth = 2.4;
    const gap = 10.0;
    final reach = strip.width + strip.height;
    for (var x = -reach; x < reach; x += gap) {
      canvas.drawLine(Offset(x, -reach), Offset(x, reach), stripe);
    }
    canvas.restore();
    canvas.drawRect(
      strip,
      Paint()
        ..color = red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  static void _paintFrame(Canvas canvas, SmapColors paper, double handle) {
    final dashed = Paint()
      ..color = paper.accentLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path()..addRect(answerFrame);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 10), dashed);
        distance += 17;
      }
    }
    final dot = Paint()..color = paper.accent;
    final ring = Paint()
      ..color = paper.textOnNavy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final corner in [
      answerFrame.topLeft,
      answerFrame.topRight,
      answerFrame.bottomLeft,
      answerFrame.bottomRight,
    ]) {
      canvas.drawCircle(corner, handle, dot);
      canvas.drawCircle(corner, handle, ring);
    }
  }
}
