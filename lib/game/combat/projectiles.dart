import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../components/arena_floor.dart';
import '../components/slide_painting.dart';
import '../theme/palette.dart';

/// Shared behaviour for everything that flies across the arena.
///
/// Projectiles live in arena-local space as children of the [ArenaFloor], and
/// take themselves off the board as soon as they leave it.
abstract class Projectile extends PositionComponent with CollisionCallbacks {
  Projectile({
    required Vector2 position,
    required this.velocity,
    required double size,
  }) : super(
         position: position,
         size: Vector2.all(size),
         anchor: Anchor.center,
         // The hitbox is a constructor child rather than an `await add` in an
         // async onLoad, because an async onLoad defers mounting until the
         // event loop next turns. A projectile has to be live on the very next
         // frame, so it must load synchronously.
         children: [CircleHitbox(collisionType: CollisionType.passive)],
       );

  final Vector2 velocity;

  /// Hit points removed from whatever this hits.
  int get damage => 1;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    final floor = parent;
    if (floor is ArenaFloor && !floor.size.toRect().contains(position.toOffset())) {
      removeFromParent();
    }
  }
}

/// The player's shot: a bullet point, fired at the feature responsible.
class BulletPoint extends Projectile {
  BulletPoint({required super.position, required super.velocity})
    : super(size: 24);

  static const double speed = 640;

  final Paint _paint = Paint()..color = Palette.brand;

  @override
  void render(Canvas canvas) {
    canvas.drawPath(trianglePath(Offset(width / 2, height / 2), width), _paint);
  }
}

/// The boss's shot: one of the little white squares PowerPoint puts around a
/// selected shape, thrown at you so it can resize you down.
class ResizeHandle extends Projectile {
  ResizeHandle({required super.position, required super.velocity})
    : super(size: 20);

  static const double speed = 300;

  final Paint _fill = Paint()..color = Palette.slide;
  final Paint _stroke = Paint()
    ..color = Palette.selection
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  @override
  void update(double dt) {
    super.update(dt);
    angle += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect().deflate(2);
    canvas.drawRect(rect, _fill);
    canvas.drawRect(rect, _stroke);
  }
}
