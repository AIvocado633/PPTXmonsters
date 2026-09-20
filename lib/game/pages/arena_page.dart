import 'dart:ui';

import 'package:flame/components.dart';

import '../components/arena_floor.dart';
import '../components/chip_button.dart';
import '../components/control_stick.dart';
import '../components/player.dart';
import '../components/pptx_actor.dart';
import '../levels.dart';
import '../slide/fly_in.dart';
import '../slide/slide_metrics.dart';
import '../slide/slide_page.dart';
import '../theme/palette.dart';
import '../theme/slide_text.dart';

/// Gameplay, presented as a running slide show.
///
/// The arena is one screen: it is a slide, so the whole playfield is visible at
/// once and there is no scrolling camera to reason about. The player moves
/// inside it with the thumb stick or the keyboard. Combat is not built yet, so
/// the two features standing in the arena are scenery for now.
class ArenaPage extends SlidePage {
  static const double _arenaWidth = 900;
  static const double _arenaHeight = 420;
  static const double _arenaTop = 150;
  static const double _actorSize = 120;

  @override
  Color get surfaceColor => Palette.showBlack;

  @override
  bool get castsShadow => false;

  final LevelDefinition _level = kLevels.first;

  late final ArenaFloor floor;
  late final ControlStick stick;
  late final Player player;

  @override
  Future<void> onLoad() async {
    floor = ArenaFloor(
      position: Vector2((kSlideWidth - _arenaWidth) / 2, _arenaTop),
      size: Vector2(_arenaWidth, _arenaHeight),
    );
    stick = ControlStick(position: Vector2(120, 612));
    player = Player(
      position: floor.centre,
      size: _actorSize,
      joystick: stick,
    );

    floor.addAll([
      player,
      _feature(Vector2(_arenaWidth * 0.22, _arenaHeight * 0.26)),
      _feature(Vector2(_arenaWidth * 0.78, _arenaHeight * 0.26)),
    ]);

    await addAll([
      TextComponent(
        text: 'Slide ${_level.number} · ${_level.boss}',
        textRenderer: SlideText.showHeading,
        position: Vector2(kSlideWidth / 2, 80),
        anchor: Anchor.center,
      )..flyIn(delay: 0.05),
      floor,
      stick,
      TextComponent(
        text: 'Move with the stick or WASD. Combat lands here next.',
        textRenderer: SlideText.showBody,
        position: Vector2(kSlideWidth / 2, 598),
        anchor: Anchor.center,
      ),
      ChipButton(
        label: 'End Show',
        filled: true,
        position: Vector2(kSlideWidth - kSlideMargin, 80),
        anchor: Anchor.centerRight,
        width: 150,
        height: 44,
        onSelected: game.router.pop,
      ),
    ]);
  }

  PptxActor _feature(Vector2 position) {
    return PptxActor(
      artPrefix: 'autofit_idle_',
      tint: Palette.selection,
      position: position,
      size: Vector2.all(_actorSize),
      anchor: Anchor.center,
    );
  }
}
