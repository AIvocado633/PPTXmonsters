import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../theme/palette.dart';
import 'slide_painting.dart';

/// The attack button, sitting under the right thumb opposite the stick.
///
/// Reports being held rather than tapped, so leaning on it auto-fires at the
/// player's cadence instead of demanding one tap per bullet point.
class FireButton extends PositionComponent with TapCallbacks {
  FireButton({required Vector2 position, required this.onHeldChanged})
    : super(position: position, size: Vector2.all(120), anchor: Anchor.center);

  final void Function(bool held) onHeldChanged;

  bool _held = false;

  final Paint _ringPaint = Paint()..color = const Color(0x24FFFFFF);
  final Paint _facePaint = Paint();
  final Paint _glyphPaint = Paint()..color = Palette.slide;

  void _setHeld(bool value) {
    if (_held == value) {
      return;
    }
    _held = value;
    onHeldChanged(value);
  }

  @override
  void render(Canvas canvas) {
    final centre = Offset(width / 2, height / 2);
    canvas.drawCircle(centre, width / 2, _ringPaint);
    _facePaint.color = _held ? Palette.brandDark : Palette.brand;
    canvas.drawCircle(centre, width / 2 - 14, _facePaint);
    canvas.drawPath(trianglePath(centre, 34), _glyphPaint);
  }

  @override
  void onTapDown(TapDownEvent event) => _setHeld(true);

  @override
  void onTapUp(TapUpEvent event) => _setHeld(false);

  @override
  void onTapCancel(TapCancelEvent event) => _setHeld(false);
}
