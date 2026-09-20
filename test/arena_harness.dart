import 'package:flutter/services.dart';
import 'package:pptx_monsters/game/components/player.dart';
import 'package:pptx_monsters/game/pages/arena_page.dart';
import 'package:pptx_monsters/game/pptx_monsters_game.dart';
import 'package:pptx_monsters/game/routes.dart';

/// Opens the arena and returns its page, ready to be driven frame by frame.
Future<ArenaPage> openArena(PptxMonstersGame game) async {
  await game.ready();
  game.router.pushNamed(Routes.slideShow);
  await game.ready();
  return game.router.currentRoute.children.whereType<ArenaPage>().single;
}

/// Tells [player] which keys are currently down.
void hold(Player player, Set<LogicalKeyboardKey> keys) {
  player.onKeyEvent(
    const KeyDownEvent(
      physicalKey: PhysicalKeyboardKey.keyW,
      logicalKey: LogicalKeyboardKey.keyW,
      timeStamp: Duration.zero,
    ),
    keys,
  );
}

/// Runs the game forward for [seconds] at a steady 60 fps.
///
/// Steps with `update`, which is what the real loop calls on the root game:
/// it delegates to `updateTree` for the lifecycle queue and children, and
/// then runs collision detection. Calling `updateTree` directly skips the
/// collision pass, so nothing would ever be hit.
///
/// Components spawned during a frame mount at the start of the next one, so
/// await `game.ready()` before inspecting `children`.
void advance(PptxMonstersGame game, double seconds) {
  final frames = (seconds * 60).round();
  for (var frame = 0; frame < frames; frame++) {
    game.update(1 / 60);
  }
}
