import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';

import 'pages/arena_page.dart';
import 'pages/design_ideas_page.dart';
import 'pages/main_menu_page.dart';
import 'pages/slide_sorter_page.dart';
import 'levels.dart';
import 'routes.dart';
import 'theme/palette.dart';

/// Root of the game.
///
/// Screens are Flame [Route]s rather than Flutter navigator pages, so the whole
/// game lives inside a single `GameWidget` and transitions can be animated by
/// the engine.
///
/// [HasKeyboardHandlerComponents] lets components opt into key events, which is
/// what makes the game playable on desktop without a touch stick.
class PptxMonstersGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final RouterComponent router;

  @override
  Color backgroundColor() => Palette.workspace;

  @override
  Future<void> onLoad() async {
    await add(
      router = RouterComponent(
        initialRoute: Routes.normalView,
        routeFactories: {
          // One route per level, built on demand, and not kept alive:
          // re-entering a level should start a fresh fight rather than drop
          // you back into one you already won or lost.
          Routes.slideShow: (levelNumber) => Route(
            () => ArenaPage(level: levelNumbered(int.parse(levelNumber))),
            maintainState: false,
          ),
        },
        routes: {
          Routes.normalView: Route(MainMenuPage.new),
          Routes.slideSorter: Route(SlideSorterPage.new),
          Routes.designIdeas: Route(DesignIdeasPage.new),
        },
      ),
    );
  }
}
