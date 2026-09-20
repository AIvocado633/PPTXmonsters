import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../components/placeholder_frame.dart';
import '../components/pptx_actor.dart';
import '../theme/palette.dart';
import 'health.dart';
import 'projectiles.dart';

/// The first boss: the feature that shrinks your text because it did not fit.
///
/// Its health *is* a font size. Every bullet point that lands steps it down the
/// same ladder of point sizes PowerPoint walks when AutoFit kicks in, and the
/// boss is drawn smaller each time. Run it down to nothing and the feature has
/// shrunk itself out of existence.
class AutoFitBoss extends PositionComponent with CollisionCallbacks {
  AutoFitBoss({
    required Vector2 position,
    required this.aimAt,
    required this.onDefeated,
  }) : super(position: position, size: Vector2(220, 170), anchor: Anchor.center);

  /// Where to throw resize handles: the player's arena-local position.
  final Vector2 Function() aimAt;

  final void Function() onDefeated;

  /// The point sizes AutoFit steps through, longest-standing first. One step
  /// per hit, so the ladder's length is the boss's hit points.
  static const List<int> pointLadder = [
    54, 48, 44, 40, 36, 32, 28, 24, 20, 18, 16, 14,
  ];

  static const double _fireInterval = 1.5;
  static const double _patrolSpeed = 0.7;
  static const double _patrolReach = 150;

  late final Health health = Health(max: pointLadder.length, minScale: 0.35);

  /// The point size currently shown, or zero once the boss is finished.
  int get pointSize =>
      health.isDead ? 0 : pointLadder[pointLadder.length - health.current];

  bool get isDefeated => _defeated;
  bool _defeated = false;

  double _sinceLastShot = 0;
  double _patrolPhase = 0;
  late final double _patrolOrigin = position.x;

  late final TextComponent _label;

  @override
  Future<void> onLoad() async {
    await addAll([
      PlaceholderFrame(
        position: Vector2.zero(),
        size: size.clone(),
        strokeColor: Palette.selection,
      ),
      PptxActor(
        artPrefix: 'autofit_idle_',
        tint: Palette.selection,
        position: Vector2(width / 2, 68),
        size: Vector2.all(104),
        anchor: Anchor.center,
      ),
      _label = TextComponent(
        text: '$pointSize pt',
        textRenderer: _labelRenderer(pointSize),
        position: Vector2(width / 2, height - 28),
        anchor: Anchor.center,
      ),
      RectangleHitbox(),
    ]);
  }

  static TextPaint _labelRenderer(int points) {
    return TextPaint(
      style: TextStyle(
        // The readout shrinks along with the number it is reporting.
        fontSize: 10 + points * 0.34,
        fontWeight: FontWeight.w700,
        color: Palette.slide,
        fontFamilyFallback: const ['Segoe UI', 'Roboto', 'Arial'],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_defeated) {
      return;
    }

    _patrolPhase += dt * _patrolSpeed;
    position.x = _patrolOrigin + math.sin(_patrolPhase) * _patrolReach;

    _sinceLastShot += dt;
    if (_sinceLastShot >= _fireInterval) {
      _sinceLastShot = 0;
      _throwHandle();
    }
  }

  void _throwHandle() {
    final toTarget = aimAt() - position;
    if (toTarget.isZero()) {
      return;
    }
    parent?.add(
      ResizeHandle(
        position: position.clone(),
        velocity: toTarget.normalized() * ResizeHandle.speed,
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is! BulletPoint || _defeated) {
      return;
    }
    other.removeFromParent();
    takeHit(other.damage);
  }

  /// Steps the boss down the ladder. Exposed so the fight can be driven from
  /// tests without synthesising collisions.
  void takeHit([int amount = 1]) {
    if (_defeated) {
      return;
    }
    health.damage(amount);
    scale = Vector2.all(health.scale);
    _label
      ..text = '$pointSize pt'
      ..textRenderer = _labelRenderer(pointSize);

    if (health.isDead) {
      _defeated = true;
      _shrinkAway();
    }
  }

  /// AutoFit's own medicine: shrink until there is nothing left to read.
  void _shrinkAway() {
    add(
      ScaleEffect.to(
        Vector2.zero(),
        EffectController(duration: 0.45, curve: Curves.easeInBack),
        onComplete: () {
          removeFromParent();
          onDefeated();
        },
      ),
    );
  }
}
