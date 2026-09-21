import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pptx_monsters/game/levels.dart';
import 'package:pptx_monsters/game/pages/arena_page.dart';

/// Guards the deck as a whole, rather than any one fight.
void main() {
  group('the deck', () {
    test('has a boss built for every level it lets you open', () {
      for (final level in kLevels.where((level) => level.unlocked)) {
        expect(
          () => ArenaPage.bossFor(
            level,
            aimAt: Vector2.zero,
            onDefeated: () {},
          ),
          returnsNormally,
          reason:
              'slide ${level.number} (${level.boss}) is unlocked but has no '
              'boss; either build it or lock the level again',
        );
      }
    });

    test('numbers its levels from one, in order, with no gaps', () {
      for (var i = 0; i < kLevels.length; i++) {
        expect(kLevels[i].number, i + 1);
      }
    });

    test('unlocks a contiguous run from the front', () {
      final unlocked = kLevels.map((level) => level.unlocked).toList();
      expect(
        unlocked.skipWhile((isUnlocked) => isUnlocked),
        everyElement(isFalse),
        reason: 'a locked level sits before an unlocked one',
      );
    });
  });
}
