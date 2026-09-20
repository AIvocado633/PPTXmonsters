import 'dart:ui';

import 'package:flame/components.dart';

import '../theme/palette.dart';

/// The thumb stick that drives the player on a touch screen.
///
/// Sized and placed for a thumb resting in the bottom-left corner of a phone
/// held in landscape. On desktop it is still drawn and still works with a
/// mouse, but the keyboard is the faster way to play.
class ControlStick extends JoystickComponent {
  ControlStick({required Vector2 position})
    : super(
        position: position,
        anchor: Anchor.center,
        // Max travel, kept just short of the ring so the knob stays inside it.
        knobRadius: 38,
        knob: CircleComponent(
          radius: 26,
          paint: Paint()..color = Palette.brand,
        ),
        background: CircleComponent(
          radius: 64,
          paint: Paint()..color = const Color(0x24FFFFFF),
        ),
      );
}
