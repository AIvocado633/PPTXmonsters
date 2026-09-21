import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pptx_monsters/game/combat/projectiles.dart';
import 'package:pptx_monsters/game/combat/smartart_boss.dart';
import 'package:pptx_monsters/game/components/result_panel.dart';
import 'package:pptx_monsters/game/pptx_monsters_game.dart';

import 'arena_harness.dart';

const int _smartArtLevel = 2;

void main() {
  group('layouts', () {
    test('keep every shape inside the diagram, at any shape count', () {
      final box = Vector2(460, 230);
      const half = SmartArtBoss.nodeSize / 2;

      for (final layout in SmartArtLayout.values) {
        for (var count = 1; count <= 6; count++) {
          final places = SmartArtBoss.positionsFor(layout, count, box);

          expect(places.length, count, reason: '$layout with $count shapes');
          for (final place in places) {
            expect(
              place.x,
              inInclusiveRange(half, box.x - half),
              reason: '$layout with $count shapes spills sideways',
            );
            expect(
              place.y,
              inInclusiveRange(half, box.y - half),
              reason: '$layout with $count shapes spills vertically',
            );
          }
        }
      }
    });

    test('never stack two shapes on the same spot', () {
      final box = Vector2(460, 230);

      for (final layout in SmartArtLayout.values) {
        for (var count = 2; count <= 6; count++) {
          final places = SmartArtBoss.positionsFor(layout, count, box);
          for (var i = 0; i < places.length; i++) {
            for (var j = i + 1; j < places.length; j++) {
              expect(
                places[i].distanceTo(places[j]),
                greaterThan(1),
                reason: '$layout with $count shapes overlaps $i and $j',
              );
            }
          }
        }
      }
    });
  });

  group('SmartArt boss', () {
    testWithGame<PptxMonstersGame>(
      'opens as a six-shape cycle',
      PptxMonstersGame.new,
      (game) async {
        final boss =
            (await openArena(game, level: _smartArtLevel)).boss as SmartArtBoss;

        expect(boss.livingShapes.length, 6);
        expect(boss.layout, SmartArtLayout.cycle);
        expect(boss.readout, '6 shapes');
        expect(boss.remainingHits, boss.totalHits);
      },
    );

    testWithGame<PptxMonstersGame>(
      'takes two hits to break one shape',
      PptxMonstersGame.new,
      (game) async {
        final boss =
            (await openArena(game, level: _smartArtLevel)).boss as SmartArtBoss;

        boss.takeHit();
        expect(boss.livingShapes.length, 6, reason: 'one hit only dents it');

        boss.takeHit();
        expect(boss.livingShapes.length, 5);
        expect(boss.readout, '5 shapes');
      },
    );

    testWithGame<PptxMonstersGame>(
      'rearranges itself the moment a shape is broken',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game, level: _smartArtLevel);
        final boss = arena.boss as SmartArtBoss;
        final before = boss.livingShapes.map((s) => s.position.clone()).toList();

        boss.takeHit(SmartArtBoss.hitsPerShape);
        expect(boss.layout, SmartArtLayout.process, reason: 'next layout');

        advance(game, 0.8);
        await game.ready();

        final after = boss.livingShapes.map((s) => s.position).toList();
        expect(after.length, 5);
        // The survivors have gone somewhere else entirely, which is the fight.
        for (var i = 0; i < after.length; i++) {
          expect(after[i].distanceTo(before[i + 1]), greaterThan(1));
        }
        expect(
          after,
          pairwiseCompare<Vector2, Vector2>(
            SmartArtBoss.positionsFor(
              SmartArtLayout.process,
              5,
              boss.size,
            ),
            (actual, expected) => actual.distanceTo(expected) < 0.5,
            'settled into the process layout',
          ),
        );
      },
    );

    testWithGame<PptxMonstersGame>(
      'walks on through the layouts as it is dismantled',
      PptxMonstersGame.new,
      (game) async {
        final boss =
            (await openArena(game, level: _smartArtLevel)).boss as SmartArtBoss;

        boss.takeHit(SmartArtBoss.hitsPerShape);
        expect(boss.layout, SmartArtLayout.process);
        boss.takeHit(SmartArtBoss.hitsPerShape);
        expect(boss.layout, SmartArtLayout.hierarchy);
        boss.takeHit(SmartArtBoss.hitsPerShape);
        expect(boss.layout, SmartArtLayout.pyramid);
        boss.takeHit(SmartArtBoss.hitsPerShape);
        expect(boss.layout, SmartArtLayout.cycle, reason: 'wraps around');
      },
    );

    testWithGame<PptxMonstersGame>(
      'throws connector arrows at the player',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game, level: _smartArtLevel);
        expect(arena.floor.children.whereType<ConnectorArrow>(), isEmpty);

        advance(game, 1.3);
        await game.ready();

        final arrows = arena.floor.children.whereType<ConnectorArrow>();
        expect(arrows, isNotEmpty);
        // Thrown downwards, because the player stands below the diagram.
        expect(arrows.first.velocity.y, greaterThan(0));
      },
    );

    testWithGame<PptxMonstersGame>(
      'running out of shapes wins the slide',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game, level: _smartArtLevel);

        arena.boss.takeHit(arena.boss.totalHits);
        expect(arena.boss.isDefeated, isTrue);

        advance(game, 0.7);
        await game.ready();

        expect(arena.isResolved, isTrue);
        final panel = arena.children.whereType<ResultPanel>().single;
        expect(panel.won, isTrue);
      },
    );

    testWithGame<PptxMonstersGame>(
      'a bullet point that reaches a shape breaks it down',
      PptxMonstersGame.new,
      (game) async {
        final arena = await openArena(game, level: _smartArtLevel);
        final before = arena.boss.remainingHits;

        arena.player.fire();
        advance(game, 0.8);
        await game.ready();

        expect(arena.boss.remainingHits, lessThan(before));
        expect(arena.floor.children.whereType<BulletPoint>(), isEmpty);
      },
    );
  });
}
