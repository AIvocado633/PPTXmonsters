import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

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

/// The player character, moved by an on-screen stick or the keyboard.
///
/// Expects to be a child of an [ArenaFloor]: it moves in arena-local
/// coordinates and clamps itself to the floor every frame.
class Player extends PositionComponent with KeyboardHandler {
  Player({
    required Vector2 position,
    required double size,
    this.speed = 320,
    this.artPrefix = 'hero_idle_',
    this.joystick,
  }) : super(position: position, size: Vector2.all(size), anchor: Anchor.center);

  /// Slide units per second at full tilt.
  final double speed;

  final String artPrefix;

  /// The on-screen stick, when there is one. Its input is added to the
  /// keyboard's, so either works and neither has to be present.
  final JoystickComponent? joystick;

  /// Which way the player last moved. Drives which artwork is drawn.
  Facing get facing => _facing;
  Facing _facing = Facing.south;

  /// The direction the player is being pushed this frame, at most unit length.
  Vector2 get direction => _direction.clone();
  final Vector2 _direction = Vector2.zero();

  final Vector2 _keyboard = Vector2.zero();

  /// Built eagerly rather than in [onLoad] so that facing can be applied to it
  /// from the moment the player exists.
  late final PptxActor _art = PptxActor(
    artPrefix: artPrefix,
    tint: Palette.brand,
    position: size / 2,
    size: size.clone(),
    anchor: Anchor.center,
  );

  static final Map<LogicalKeyboardKey, (double, double)> _movementKeys = {
    LogicalKeyboardKey.keyW: (0, -1),
    LogicalKeyboardKey.arrowUp: (0, -1),
    LogicalKeyboardKey.keyS: (0, 1),
    LogicalKeyboardKey.arrowDown: (0, 1),
    LogicalKeyboardKey.keyA: (-1, 0),
    LogicalKeyboardKey.arrowLeft: (-1, 0),
    LogicalKeyboardKey.keyD: (1, 0),
    LogicalKeyboardKey.arrowRight: (1, 0),
  };

  @override
  Future<void> onLoad() async {
    await add(_art);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboard.setZero();
    for (final key in keysPressed) {
      final axis = _movementKeys[key];
      if (axis != null) {
        _keyboard.x += axis.$1;
        _keyboard.y += axis.$2;
      }
    }
    // Opposite keys held together cancel out, which is what a player expects.
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _direction
      ..setFrom(_keyboard)
      ..add(joystick?.relativeDelta ?? Vector2.zero());
    // The stick is analogue, so short pushes stay slow; anything past full
    // tilt -- including a diagonal on the keyboard -- is capped, so walking
    // diagonally is not faster than walking straight.
    if (_direction.length2 > 1) {
      _direction.normalize();
    }

    if (_direction.isZero()) {
      return;
    }

    position += _direction * speed * dt;
    final floor = parent;
    if (floor is ArenaFloor) {
      floor.clampInside(position, size);
    }
    _face(_direction);
  }

  void _face(Vector2 direction) {
    final octant = (math.atan2(direction.y, direction.x) / (math.pi / 4)).round();
    _facing = Facing.values[(octant + 8) % 8];
    _art.scale.x = _facing.isWestward ? -1 : 1;
  }
}
