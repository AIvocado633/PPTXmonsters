import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../combat/health.dart';
import '../combat/projectiles.dart';
import '../input/gamepad_input.dart';
import '../theme/palette.dart';
import 'arena_floor.dart';
import 'pptx_actor.dart';

/// The eight directions an actor can face.
///
/// Declared anticlockwise from east so that the index matches the octant of
/// `atan2(dy, dx)`, which keeps [Player.facing] a rounding away from the
/// movement vector. Screen y grows downwards, so "south" is the bottom of the
/// slide.
enum Facing {
  east,
  southEast,
  south,
  southWest,
  west,
  northWest,
  north,
  northEast;

  /// True for the three directions with a westward component, i.e. the ones
  /// whose artwork is the mirror of the drawn pose.
  bool get isWestward =>
      this == Facing.southWest || this == Facing.west || this == Facing.northWest;
}

/// The player character, armed with bullet points.
///
/// Controls are twin-stick: one input moves, a second one aims, and pushing
/// the aim input in any direction fires that way straight away, with no
/// separate trigger. Each of the two has three sources, summed, so any device
/// works and none has to be present:
///
/// |        | Touch               | Keyboard   | Controller  |
/// | ------ | ------------------- | ---------- | ----------- |
/// | Move   | [moveStick]         | WASD       | left stick  |
/// | Aim    | [aimStick]          | arrow keys | right stick |
///
/// Space still fires without aiming, along whichever way the player is
/// walking, which is how shooting worked before aiming existed.
///
/// Expects to be a child of an [ArenaFloor]: it moves in arena-local
/// coordinates and clamps itself to the floor every frame.
///
/// Taking a hit shrinks the player, because that is what AutoFit does to
/// anything that does not fit. Being small is not purely a penalty -- a smaller
/// player is a faster and narrower target -- but running out of size loses the
/// slide.
class Player extends PositionComponent with KeyboardHandler, CollisionCallbacks {
  Player({
    required Vector2 position,
    required double size,
    this.speed = 320,
    this.artPrefix = 'hero_idle_',
    this.moveStick,
    this.aimStick,
    this.gamepad,
    this.onDefeated,
  }) : super(position: position, size: Vector2.all(size), anchor: Anchor.center);

  /// Slide units per second at full tilt and full size.
  final double speed;

  final String artPrefix;

  /// The on-screen stick under the left thumb.
  final JoystickComponent? moveStick;

  /// The on-screen stick under the right thumb.
  final JoystickComponent? aimStick;

  /// A connected controller's sticks, when there is one.
  final GamepadInput? gamepad;

  /// Called once the player has been shrunk out of the fight.
  final void Function()? onDefeated;

  /// How far the aim input has to be pushed, as a fraction of full tilt,
  /// before it counts as aiming -- and so as firing. Enough to ignore a thumb
  /// merely resting on the stick, small enough that any deliberate push shoots.
  static const double aimThreshold = 0.1;

  static const double _fireCooldown = 0.32;

  late final Health health = Health(max: 8, minScale: 0.4);

  /// Which way the player is facing: towards the aim while aiming, otherwise
  /// the way it last walked. Drives which artwork is drawn.
  Facing get facing => _facing;
  Facing _facing = Facing.south;

  /// The direction the player is being pushed this frame, at most unit length.
  Vector2 get direction => _direction.clone();
  final Vector2 _direction = Vector2.zero();

  /// Where the next shot goes, unit length. While aiming it is the aim input;
  /// otherwise it follows movement. It starts pointing up the slide, so the
  /// first shot reaches the boss without having to do anything else first.
  Vector2 get aimDirection => _aim.clone();
  final Vector2 _aim = Vector2(0, -1);

  /// Whether the aim input is pushed far enough to aim and fire this frame.
  bool get isAiming => _aiming;
  bool _aiming = false;

  final Vector2 _keyboardMove = Vector2.zero();
  final Vector2 _keyboardAim = Vector2.zero();
  final Vector2 _aimInput = Vector2.zero();
  bool _spaceHeld = false;
  double _sinceLastShot = _fireCooldown;

  /// Built eagerly rather than in [onLoad] so that facing can be applied to it
  /// from the moment the player exists.
  late final PptxActor _art = PptxActor(
    artPrefix: artPrefix,
    tint: Palette.brand,
    position: size / 2,
    size: size.clone(),
    anchor: Anchor.center,
  );

  static final Map<LogicalKeyboardKey, (double, double)> _moveKeys = {
    LogicalKeyboardKey.keyW: (0, -1),
    LogicalKeyboardKey.keyS: (0, 1),
    LogicalKeyboardKey.keyA: (-1, 0),
    LogicalKeyboardKey.keyD: (1, 0),
  };

  static final Map<LogicalKeyboardKey, (double, double)> _aimKeys = {
    LogicalKeyboardKey.arrowUp: (0, -1),
    LogicalKeyboardKey.arrowDown: (0, 1),
    LogicalKeyboardKey.arrowLeft: (-1, 0),
    LogicalKeyboardKey.arrowRight: (1, 0),
  };

  @override
  Future<void> onLoad() async {
    await addAll([_art, CircleHitbox()]);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Opposite keys held together cancel out, which is what a player expects.
    _sumKeys(keysPressed, _moveKeys, into: _keyboardMove);
    _sumKeys(keysPressed, _aimKeys, into: _keyboardAim);
    _spaceHeld = keysPressed.contains(LogicalKeyboardKey.space);
    return true;
  }

  static void _sumKeys(
    Set<LogicalKeyboardKey> pressed,
    Map<LogicalKeyboardKey, (double, double)> axes, {
    required Vector2 into,
  }) {
    into.setZero();
    for (final key in pressed) {
      final axis = axes[key];
      if (axis != null) {
        into.x += axis.$1;
        into.y += axis.$2;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _readAim();
    _move(dt);
    _shoot(dt);
  }

  void _readAim() {
    _aimInput
      ..setFrom(_keyboardAim)
      ..add(aimStick?.relativeDelta ?? Vector2.zero())
      ..add(gamepad?.aim ?? Vector2.zero());
    _aiming = _aimInput.length2 >= aimThreshold * aimThreshold;
    if (_aiming) {
      _aim
        ..setFrom(_aimInput)
        ..normalize();
      _face(_aim);
    }
  }

  void _move(double dt) {
    _direction
      ..setFrom(_keyboardMove)
      ..add(moveStick?.relativeDelta ?? Vector2.zero())
      ..add(gamepad?.move ?? Vector2.zero());
    // Sticks are analogue, so short pushes stay slow; anything past full tilt
    // -- including a diagonal on the keyboard -- is capped, so walking
    // diagonally is not faster than walking straight.
    if (_direction.length2 > 1) {
      _direction.normalize();
    }

    if (_direction.isZero()) {
      return;
    }

    // Shrinking is not all bad: what you lose in presence you gain in pace.
    final pace = speed * (2 - health.scale);
    position += _direction * pace * dt;

    final floor = parent;
    if (floor is ArenaFloor) {
      floor.clampInside(position, scaledSize);
    }

    // Without an aim input, shots and facing follow the feet, as they did
    // before aiming existed.
    if (!_aiming) {
      _aim
        ..setFrom(_direction)
        ..normalize();
      _face(_direction);
    }
  }

  void _shoot(double dt) {
    _sinceLastShot += dt;
    if (!(_aiming || _spaceHeld) || _sinceLastShot < _fireCooldown) {
      return;
    }
    _sinceLastShot = 0;
    fire();
  }

  /// Sends a bullet point along [aimDirection]. Public so the fight can be
  /// driven from tests without synthesising input.
  void fire() {
    parent?.add(
      BulletPoint(
        position: position.clone(),
        velocity: _aim * BulletPoint.speed,
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is! EnemyShot || health.isDead) {
      return;
    }
    other.removeFromParent();
    takeHit(other.damage);
  }

  /// Shrinks the player by [amount] hit points.
  void takeHit([int amount = 1]) {
    if (health.isDead) {
      return;
    }
    health.damage(amount);
    scale = Vector2.all(health.scale);
    if (health.isDead) {
      onDefeated?.call();
    }
  }

  void _face(Vector2 direction) {
    final octant = (math.atan2(direction.y, direction.x) / (math.pi / 4)).round();
    _facing = Facing.values[(octant + 8) % 8];
    _art.scale.x = _facing.isWestward ? -1 : 1;
  }
}
