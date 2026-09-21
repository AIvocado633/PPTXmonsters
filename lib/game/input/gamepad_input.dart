import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:gamepads/gamepads.dart';

/// The latest stick positions from a connected controller, in screen terms.
///
/// Fed from `Gamepads.normalizedEvents`, which already maps every platform's
/// raw key names onto a standard Xbox-style layout, so the left stick is the
/// left stick whether the pad is on Windows, Android or iOS. This class only
/// has to do two things on top of that:
///
///  * **Flip the vertical axis.** Normalized sticks report up as +1, but screen
///    y grows downwards, so pushing up must come out as negative y.
///  * **Ignore stick drift.** A resting analogue stick rarely reads exactly
///    zero, and a twin-stick shooter fires the moment the aim stick leaves the
///    centre, so anything inside [deadzone] is treated as centred.
///
/// It holds no stream subscription of its own; the game owns that, which keeps
/// this class free of platform channels and trivially testable.
class GamepadInput {
  /// How far a stick has to travel, as a fraction of full tilt, before it
  /// counts as pushed.
  static const double deadzone = 0.2;

  final Vector2 _left = Vector2.zero();
  final Vector2 _right = Vector2.zero();

  /// The movement stick, deadzoned and rescaled, at most unit length.
  Vector2 get move => _deadzoned(_left);

  /// The aiming stick: zero while centred, and a full-length direction the
  /// moment it leaves the deadzone.
  ///
  /// Unlike [move] this is deliberately not rescaled. Only the direction of a
  /// shot matters, and a twin-stick shooter should fire as soon as the stick
  /// picks a direction -- not wait until it has been pushed past some further
  /// threshold on top of the deadzone.
  Vector2 get aim =>
      _right.length < deadzone ? Vector2.zero() : _right.normalized();

  /// Folds one normalized event into the current stick state. Buttons and
  /// triggers are ignored for now.
  void handle(NormalizedGamepadEvent event) {
    switch (event.axis) {
      case GamepadAxis.leftStickX:
        _left.x = event.value;
      case GamepadAxis.leftStickY:
        _left.y = -event.value;
      case GamepadAxis.rightStickX:
        _right.x = event.value;
      case GamepadAxis.rightStickY:
        _right.y = -event.value;
      case GamepadAxis.leftTrigger:
      case GamepadAxis.rightTrigger:
      case null:
        break;
    }
  }

  /// Returns [raw] with the deadzone cut out and the remaining travel stretched
  /// back over 0..1, so a push starts slow just outside the deadzone instead
  /// of jumping straight to a fifth of full speed.
  static Vector2 _deadzoned(Vector2 raw) {
    final length = raw.length;
    if (length < deadzone) {
      return Vector2.zero();
    }
    final stretched = math.min((length - deadzone) / (1 - deadzone), 1.0);
    return raw.normalized()..scale(stretched);
  }
}
