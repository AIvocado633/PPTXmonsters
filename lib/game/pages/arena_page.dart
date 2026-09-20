import 'dart:ui';

import 'package:flame/components.dart';

import '../components/chip_button.dart';
import '../components/pptx_actor.dart';
import '../levels.dart';
import '../slide/fly_in.dart';
import '../slide/slide_metrics.dart';
import '../slide/slide_page.dart';
import '../theme/palette.dart';
import '../theme/slide_text.dart';

/// Gameplay, presented as a running slide show.
///
/// This is a staging area, not the finished level: it establishes the
/// top-down camera framing, the projector-black surround and the actors, so
/// movement, collisions and the boss fight can be dropped straight in.
class ArenaPage extends SlidePage {
  static const double _arenaWidth = 900;
  static const double _arenaHeight = 420;

  @override
  Color get surfaceColor => Palette.showBlack;

  @override
  bool get castsShadow => false;

  final LevelDefinition _level = kLevels.first;

  @override
  Future<void> onLoad() async {
    final arenaOrigin = Vector2(
      (kSlideWidth - _arenaWidth) / 2,
      150,
    );

    await addAll([
      TextComponent(
        text: 'Slide ${_level.number} · ${_level.boss}',
        textRenderer: SlideText.showHeading,
        position: Vector2(kSlideWidth / 2, 80),
        anchor: Anchor.center,
      )..flyIn(delay: 0.05),
      _ArenaFloor(position: arenaOrigin, size: Vector2(_arenaWidth, _arenaHeight)),
      PptxActor(
        artPrefix: 'hero_idle_',
        position: arenaOrigin + Vector2(_arenaWidth / 2, _arenaHeight * 0.62),
        size: Vector2.all(150),
        anchor: Anchor.center,
      ),
      PptxActor(
        artPrefix: 'autofit_idle_',
        tint: Palette.selection,
        position: arenaOrigin + Vector2(_arenaWidth * 0.22, _arenaHeight * 0.3),
        size: Vector2.all(120),
        anchor: Anchor.center,
      ),
      PptxActor(
        artPrefix: 'autofit_idle_',
        tint: Palette.selection,
        position: arenaOrigin + Vector2(_arenaWidth * 0.78, _arenaHeight * 0.3),
        size: Vector2.all(120),
        anchor: Anchor.center,
      ),
      TextComponent(
        text: 'Arena under construction — movement and combat land here next.',
        textRenderer: SlideText.showBody,
        position: Vector2(kSlideWidth / 2, 604),
        anchor: Anchor.center,
      ),
      ChipButton(
        label: 'End Show',
        filled: true,
        position: Vector2(kSlideWidth / 2, 656),
        anchor: Anchor.center,
        width: 200,
        onSelected: game.router.pop,
      ),
    ]);
  }
}

/// The top-down playfield: a tiled floor seen from directly above.
class _ArenaFloor extends PositionComponent {
  _ArenaFloor({required Vector2 position, required Vector2 size})
    : super(position: position, size: size);

  static const double _tile = 60;

  final Paint _floorPaint = Paint()..color = const Color(0xFF1A1A1A);
  final Paint _gridPaint = Paint()
    ..color = const Color(0xFF2E2E2E)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _borderPaint = Paint()
    ..color = Palette.brand
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, _floorPaint);
    for (var x = _tile; x < width; x += _tile) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), _gridPaint);
    }
    for (var y = _tile; y < height; y += _tile) {
      canvas.drawLine(Offset(0, y), Offset(width, y), _gridPaint);
    }
    canvas.drawRect(rect, _borderPaint);
  }
}
