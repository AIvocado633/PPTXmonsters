import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../theme/palette.dart';
import 'slide_painting.dart';

/// An on-screen thumb stick.
///
/// The arena has two, twin-stick style: one under the left thumb that moves
/// the player, and one under the right that aims -- and, the moment it leaves
/// the centre, fires. On desktop both still work with a mouse, but WASD and
/// the arrow keys are the faster way to play.
class ControlStick extends JoystickComponent {
  /// The movement stick: a plain knob.
  ControlStick({required Vector2 position})
    : this._(
        position,
        CircleComponent(
          radius: _knobRadius,
          paint: Paint()..color = Palette.brand,
        ),
      );

  /// The aiming stick. Its knob carries a bullet point that turns to face
  /// wherever the stick is pushed, which is wherever the next shot will go.
  ControlStick.aim({required Vector2 position}) : this._(position, _AimKnob());

  ControlStick._(Vector2 position, PositionComponent knob)
    : super(
        position: position,
        anchor: Anchor.center,
        // Max travel, kept just short of the ring so the knob stays inside it.
        knobRadius: 38,
        knob: knob,
        background: CircleComponent(
          radius: 64,
          paint: Paint()..color = const Color(0x24FFFFFF),
        ),
      );

  static const double _knobRadius = 26;
}

class _AimKnob extends PositionComponent {
  _AimKnob() : super(size: Vector2.all(ControlStick._knobRadius * 2));

  final Paint _facePaint = Paint()..color = Palette.brand;
  final Paint _glyphPaint = Paint()..color = Palette.slide;

  @override
  void update(double dt) {
    super.update(dt);
    // The stick parks the knob at its centre plus the push, so the knob's own
    // offset from that centre is the aim. Once released it keeps pointing the
    // way it last fired.
    final stick = parent;
    if (stick is PositionComponent) {
      final push = position - stick.size / 2;
      if (!push.isZero()) {
        angle = math.atan2(push.y, push.x);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final centre = Offset(width / 2, height / 2);
    canvas.drawCircle(centre, width / 2, _facePaint);
    canvas.drawPath(trianglePath(centre, 22), _glyphPaint);
  }
}
