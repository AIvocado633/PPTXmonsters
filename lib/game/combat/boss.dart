import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// A PowerPoint feature, standing between the player and the end of the deck.
///
/// Every feature fights in its own way, so this holds only what the arena needs
/// in order to run a slide: where the fight stands, and how to end it. How a
/// boss is laid out, what it throws and how damage is distributed inside it are
/// entirely the boss's business.
abstract class Boss extends PositionComponent with CollisionCallbacks {
  Boss({
    required Vector2 position,
    required Vector2 size,
    required this.aimAt,
    required this.onDefeated,
  }) : super(position: position, size: size, anchor: Anchor.center);

  /// Where to throw things: the player's arena-local position.
  final Vector2 Function() aimAt;

  /// Called once the feature is gone and any death animation has played.
  final void Function() onDefeated;

  /// Hits still needed to finish the feature off. Zero means beaten.
  int get remainingHits;

  /// How many hits the fight started with, so progress can be shown.
  int get totalHits;

  /// The feature's own way of reporting its health -- a point size, a shape
  /// count -- in its own units rather than as a percentage.
  String get readout;

  bool get isDefeated;

  /// Applies [amount] hits. Exposed so a fight can be driven from tests
  /// without synthesising collisions.
  void takeHit([int amount = 1]);
}
