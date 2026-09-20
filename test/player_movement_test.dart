import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pptx_monsters/game/components/control_stick.dart';
import 'package:pptx_monsters/game/components/player.dart';
import 'package:pptx_monsters/game/components/pptx_actor.dart';
import 'package:pptx_monsters/game/pages/arena_page.dart';
import 'package:pptx_monsters/game/pptx_monsters_game.dart';
import 'package:pptx_monsters/game/routes.dart';

void main() {
  group('player', () {
    testWithGame<PptxMonstersGame>(
      'starts in the middle of the arena',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        expect(arena.player.position, closeToVector(arena.floor.centre, 0.01));
      },
    );

    testWithGame<PptxMonstersGame>(
      'walks in the direction the keys are held',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        final start = arena.player.position.clone();

        hold(arena.player, {LogicalKeyboardKey.keyD});
        game.update(0.5);

        expect(arena.player.position.x, closeTo(start.x + 160, 0.01));
        expect(arena.player.position.y, closeTo(start.y, 0.01));
      },
    );

    testWithGame<PptxMonstersGame>(
      'stops when the keys are released',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        hold(arena.player, {LogicalKeyboardKey.keyD});
        game.update(0.2);
        final moved = arena.player.position.clone();

        hold(arena.player, const {});
        game.update(0.2);

        expect(arena.player.position, closeToVector(moved, 0.01));
      },
    );

    testWithGame<PptxMonstersGame>(
      'does not travel faster diagonally',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        final start = arena.player.position.clone();

        hold(arena.player, {LogicalKeyboardKey.keyW, LogicalKeyboardKey.keyD});
        game.update(0.5);

        final travelled = arena.player.position - start;
        expect(travelled.length, closeTo(160, 0.01));
        expect(travelled.x, greaterThan(0));
        expect(travelled.y, lessThan(0));
      },
    );

    testWithGame<PptxMonstersGame>(
      'cancels out opposite keys',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        final start = arena.player.position.clone();

        hold(arena.player, {LogicalKeyboardKey.keyA, LogicalKeyboardKey.keyD});
        game.update(0.5);

        expect(arena.player.position, closeToVector(start, 0.01));
      },
    );

    testWithGame<PptxMonstersGame>(
      'cannot walk out of the arena',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        final half = arena.player.size / 2;

        hold(arena.player, {LogicalKeyboardKey.keyD, LogicalKeyboardKey.keyS});
        for (var frame = 0; frame < 300; frame++) {
          game.update(1 / 60);
        }

        expect(
          arena.player.position.x,
          closeTo(arena.floor.size.x - half.x, 0.01),
        );
        expect(
          arena.player.position.y,
          closeTo(arena.floor.size.y - half.y, 0.01),
        );

        hold(arena.player, {LogicalKeyboardKey.keyA, LogicalKeyboardKey.keyW});
        for (var frame = 0; frame < 300; frame++) {
          game.update(1 / 60);
        }

        expect(arena.player.position.x, closeTo(half.x, 0.01));
        expect(arena.player.position.y, closeTo(half.y, 0.01));
      },
    );

    testWithGame<PptxMonstersGame>(
      'faces the way it is walking and mirrors the art going west',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        final art = arena.player.children.whereType<PptxActor>().single;

        hold(arena.player, {LogicalKeyboardKey.keyD});
        game.update(1 / 60);
        expect(arena.player.facing, Facing.east);
        expect(art.scale.x, 1);

        hold(arena.player, {LogicalKeyboardKey.keyA});
        game.update(1 / 60);
        expect(arena.player.facing, Facing.west);
        expect(art.scale.x, -1);

        hold(arena.player, {LogicalKeyboardKey.keyW});
        game.update(1 / 60);
        expect(arena.player.facing, Facing.north);
        expect(art.scale.x, 1);
      },
    );
  });

  group('thumb stick', () {
    test('adds its push to the keyboard and stays capped at full tilt', () {
      final stick = _StubStick();
      final player = Player(
        position: Vector2.zero(),
        size: 100,
        joystick: stick,
      );

      // Half tilt east.
      stick.push = Vector2(0.5, 0);
      player.update(1);
      expect(player.direction.length, closeTo(0.5, 1e-9));

      // Full tilt east plus the D key must not stack into double speed.
      stick.push = Vector2(1, 0);
      hold(player, {LogicalKeyboardKey.keyD});
      player.update(1);
      expect(player.direction.length, closeTo(1, 1e-9));
    });

    testWithGame<PptxMonstersGame>(
      'is on the arena page and wired to the player',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game);
        final sticks = arena.children.whereType<ControlStick>();

        expect(sticks.length, 1);
        expect(arena.player.joystick, same(sticks.single));
      },
    );
  });
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

Future<ArenaPage> openArena(PptxMonstersGame game) async {
  await game.ready();
  game.router.pushNamed(Routes.slideShow);
  await game.ready();
  return game.router.currentRoute.children.whereType<ArenaPage>().single;
}

/// A stick whose push can be set directly, so the player's handling of it can
/// be tested without synthesising drag gestures.
class _StubStick extends ControlStick {
  _StubStick() : super(position: Vector2.zero());

  Vector2 push = Vector2.zero();

  @override
  Vector2 get relativeDelta => push;
}
