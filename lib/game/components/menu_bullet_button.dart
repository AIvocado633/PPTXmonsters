import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../slide/focusable.dart';
import '../theme/palette.dart';
import '../theme/slide_text.dart';
import 'placeholder_frame.dart';
import 'slide_painting.dart';

/// A menu entry drawn as a bullet point on a content placeholder.
///
/// The whole row is the hit target, which keeps it comfortable to tap on a
/// phone while still looking like an ordinary line of slide text.
class MenuBulletButton extends PositionComponent
    with TapCallbacks, HoverCallbacks, Focusable {
  MenuBulletButton({
    required this.label,
    required this.onSelected,
    this.hint,
    this.enabled = true,
    super.position,
    double width = 640,
    double height = 74,
  }) : super(size: Vector2(width, height));

  final String label;
  final String? hint;
  final bool enabled;
  final void Function() onSelected;

  static const double _indentWhenActive = 14;
  static const double _bulletInset = 22;
  static const double _labelInset = 58;

  bool _pressed = false;

  /// Content lives in its own child so the hover indent can be animated
  /// without re-laying out the text every frame.
  late final PositionComponent _content;

  final Paint _highlightPaint = Paint();

  @override
  Future<void> onLoad() async {
    final centreY = height / 2;
    _content = PositionComponent(position: Vector2.zero());
    _content.add(
      _BulletGlyph(
        position: Vector2(_bulletInset, centreY - 9),
        colour: enabled ? Palette.brand : Palette.locked,
      ),
    );
    _content.add(
      TextComponent(
        text: label,
        textRenderer: enabled ? SlideText.bullet : SlideText.bulletDisabled,
        position: Vector2(_labelInset, centreY),
        anchor: Anchor.centerLeft,
      ),
    );
    final hintText = hint;
    if (hintText != null) {
      _content.add(
        TextComponent(
          text: hintText,
          textRenderer: SlideText.bulletHint,
          position: Vector2(width - _bulletInset, centreY),
          anchor: Anchor.centerRight,
        ),
      );
    }
    await add(_content);
  }

  @override
  bool get canFocus => enabled;

  @override
  void activate() {
    if (enabled) {
      onSelected();
    }
  }

  bool get _isActive => enabled && (isHighlighted || _pressed);

  @override
  void update(double dt) {
    super.update(dt);
    final target = _isActive ? _indentWhenActive : 0.0;
    // Frame-rate independent ease towards the target indent.
    final t = 1 - math.pow(0.0005, dt).toDouble();
    _content.position.x += (target - _content.position.x) * t;
  }

  @override
  void render(Canvas canvas) {
    if (!_isActive) {
      return;
    }
    _highlightPaint.color = _pressed
        ? Palette.brandWashStrong
        : Palette.brandWash;
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      _highlightPaint,
    );
    if (isHighlighted) {
      drawSelection(canvas, size.toRect().inflate(3), handleSize: 9);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!enabled) {
      return;
    }
    _pressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!_pressed) {
      return;
    }
    _pressed = false;
    onSelected();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }
}

class _BulletGlyph extends PositionComponent {
  _BulletGlyph({required Vector2 position, required this.colour})
    : super(position: position, size: Vector2.all(18));

  final Color colour;

  late final Paint _paint = Paint()..color = colour;

  @override
  void render(Canvas canvas) {
    canvas.drawPath(
      trianglePath(Offset(width / 2, height / 2), width),
      _paint,
    );
  }
}
