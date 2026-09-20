import 'dart:ui';

import 'package:flame/components.dart';

import '../theme/palette.dart';
import 'slide_painting.dart';

/// The dashed outline PowerPoint draws around an empty content placeholder.
///
/// Used as the frame for the game title and for the side panel, so the start
/// menu reads as a half-finished deck.
class PlaceholderFrame extends PositionComponent {
  PlaceholderFrame({
    super.position,
    super.size,
    this.cornerRadius = 6,
    this.strokeColor = Palette.placeholderStroke,
    this.fillColor,
  });

  final double cornerRadius;
  final Color strokeColor;
  final Color? fillColor;

  late final Paint _strokePaint = Paint()
    ..color = strokeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;

  @override
  void render(Canvas canvas) {
    final rrect = RRect.fromRectAndRadius(
      size.toRect(),
      Radius.circular(cornerRadius),
    );
    final fill = fillColor;
    if (fill != null) {
      canvas.drawRRect(rrect, Paint()..color = fill);
    }
    drawDashedRRect(canvas, rrect, _strokePaint);
  }
}

/// The eight white resize handles PowerPoint puts around a selected shape.
class SelectionHandles extends PositionComponent {
  SelectionHandles({super.position, super.size, this.handleSize = 11});

  final double handleSize;

  final Paint _fillPaint = Paint()..color = Palette.slide;
  final Paint _strokePaint = Paint()
    ..color = Palette.selection
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;
  final Paint _outlinePaint = Paint()
    ..color = Palette.selection.withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _outlinePaint);
    for (final dx in [0.0, 0.5, 1.0]) {
      for (final dy in [0.0, 0.5, 1.0]) {
        if (dx == 0.5 && dy == 0.5) {
          continue;
        }
        _handle(canvas, Offset(width * dx, height * dy));
      }
    }
    // The rotation handle, floating above the top edge.
    final rotate = Offset(width / 2, -26);
    canvas.drawLine(Offset(width / 2, 0), rotate, _outlinePaint);
    canvas.drawCircle(rotate, handleSize / 2, _fillPaint);
    canvas.drawCircle(rotate, handleSize / 2, _strokePaint);
  }

  void _handle(Canvas canvas, Offset centre) {
    final rect = Rect.fromCenter(
      center: centre,
      width: handleSize,
      height: handleSize,
    );
    canvas.drawRect(rect, _fillPaint);
    canvas.drawRect(rect, _strokePaint);
  }
}
