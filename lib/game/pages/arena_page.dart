import 'dart:ui';

import 'package:flame/components.dart';

import '../combat/boss.dart';
import '../components/arena_floor.dart';
import '../components/chip_button.dart';
import '../components/control_stick.dart';
import '../components/player.dart';
import '../components/result_panel.dart';
import '../levels.dart';
import '../routes.dart';
import '../slide/fly_in.dart';
import '../slide/slide_metrics.dart';
import '../slide/slide_page.dart';
import '../theme/palette.dart';
import '../theme/slide_text.dart';

/// A level: one slide, one feature, fought out from directly above.
///
/// The whole playfield is visible at once, because it is a slide. The page
/// itself is feature-agnostic -- it owns the floor, the controls and the
/// win/lose flow, and asks its [level] for whatever is standing in the way.
class ArenaPage extends SlidePage {
  /// Only a slide whose fight has been built can be opened; the slide sorter
  /// never offers the others.
  ArenaPage({required this.level})
    : assert(
        level.isBuilt,
        'Slide ${level.number} (${level.boss}) has no fight yet',
      );

  static const double _arenaWidth = 900;
  static const double _arenaHeight = 420;
  static const double _arenaTop = 150;
  static const double _playerSize = 120;

  final LevelDefinition level;

  @override
  Color get surfaceColor => Palette.showBlack;

  @override
  bool get castsShadow => false;

  late final ArenaFloor floor;

  /// Twin sticks: the left thumb moves, the right thumb aims and fires.
  late final ControlStick moveStick;
  late final ControlStick aimStick;

  late final Player player;
  late final Boss boss;

  /// True once the slide has been won or lost.
  bool get isResolved => _resolved;
  bool _resolved = false;

  late final TextComponent _sizeReadout;
  late final TextComponent _bossReadout;
  late final TextComponent _controlsHint;
  late int _shownHealth;
  late String _shownReadout;

  @override
  Future<void> onLoad() async {
    floor = ArenaFloor(
      position: Vector2((kSlideWidth - _arenaWidth) / 2, _arenaTop),
      size: Vector2(_arenaWidth, _arenaHeight),
    );
    moveStick = ControlStick(position: Vector2(120, 612));
    aimStick = ControlStick.aim(position: Vector2(1160, 612));
    player = Player(
      position: Vector2(_arenaWidth / 2, _arenaHeight - 90),
      size: _playerSize,
      moveStick: moveStick,
      aimStick: aimStick,
      gamepad: game.gamepad,
      onDefeated: _onPlayerShrunkAway,
    );
    boss = level.buildBoss!(
      BossContext(
        arenaSize: floor.size.clone(),
        aimAt: () => player.position,
        onDefeated: _onBossFinished,
      ),
    );
    _shownHealth = player.health.current;
    _shownReadout = boss.readout;

    floor.addAll([boss, player]);

    await addAll([
      TextComponent(
        text: 'Slide ${level.number} · ${level.boss}',
        textRenderer: SlideText.showHeading,
        position: Vector2(kSlideWidth / 2, 80),
        anchor: Anchor.center,
      )..flyIn(delay: 0.05),
      floor,
      moveStick,
      aimStick,
      _sizeReadout = TextComponent(
        text: _playerReadout,
        textRenderer: SlideText.showBody,
        position: Vector2(56, 524),
        anchor: Anchor.centerLeft,
      ),
      // Each feature reports its health in its own units, so the readout is
      // the boss's own wording rather than a percentage.
      _bossReadout = TextComponent(
        text: _bossReadoutText,
        textRenderer: SlideText.showBody,
        position: Vector2(1224, 524),
        anchor: Anchor.centerRight,
      ),
      _controlsHint = TextComponent(
        text: 'Left stick or WASD to move. Right stick or arrows to aim and fire.',
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
        onSelected: _leave,
      ),
    ]);
  }

  String get _playerReadout =>
      'You: ${(player.health.fraction * 100).round()}%';

  String get _bossReadoutText => '${level.boss}: ${boss.readout}';

  @override
  void update(double dt) {
    super.update(dt);
    // Only re-lay out a readout when the value it shows actually moves.
    if (_shownHealth != player.health.current) {
      _shownHealth = player.health.current;
      _sizeReadout.text = _playerReadout;
    }
    if (_shownReadout != boss.readout) {
      _shownReadout = boss.readout;
      _bossReadout.text = _bossReadoutText;
    }
  }

  void _onBossFinished() =>
      _resolve(won: true, title: 'Slide complete', message: level.winLine);

  void _onPlayerShrunkAway() =>
      _resolve(won: false, title: 'Slide failed', message: level.lossLine);

  void _resolve({
    required bool won,
    required String title,
    required String message,
  }) {
    if (_resolved) {
      return;
    }
    _resolved = true;

    // Freeze the board rather than tearing it down, so the last moment of the
    // fight stays on screen behind the dialog.
    floor.pause();
    moveStick.removeFromParent();
    aimStick.removeFromParent();
    // The hint would otherwise outlive the controls it describes.
    _controlsHint.removeFromParent();

    add(
      ResultPanel(
        position: Vector2(kSlideWidth / 2, kSlideHeight / 2),
        title: title,
        message: message,
        won: won,
        onRetry: _retry,
        onLeave: _leave,
      ),
    );
  }

  /// The route does not maintain state, so popping drops this page and pushing
  /// builds a brand new fight.
  void _retry() {
    game.router.pop();
    game.router.pushNamed(Routes.slideShowFor(level.number));
  }

  void _leave() => game.router.pop();
}
