import 'dart:async';
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:gamepads/gamepads.dart';

import 'input/gamepad_input.dart';

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
  PptxMonstersGame({Stream<NormalizedGamepadEvent>? gamepadEvents})
    : _gamepadEvents = gamepadEvents;

  /// Controller events to follow. The app passes the real platform stream;
  /// tests leave it null, so building a game never touches a platform channel.
  final Stream<NormalizedGamepadEvent>? _gamepadEvents;
  StreamSubscription<NormalizedGamepadEvent>? _gamepadSubscription;

  /// The connected controller's sticks, shared by every page.
  final GamepadInput gamepad = GamepadInput();

  late final RouterComponent router;

  @override
  Color backgroundColor() => Palette.workspace;

  @override
  Future<void> onLoad() async {
    _gamepadSubscription = _gamepadEvents?.listen(
      gamepad.handle,
      // A controller failing should cost you the controller, not the game.
      onError: (Object error) => debugPrint('Gamepad input failed: $error'),
    );
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

  @override
  void onDispose() {
    _gamepadSubscription?.cancel();
    super.onDispose();
  }
}
