import 'dart:ui';

import 'package:flame/components.dart';

import '../combat/autofit_boss.dart';
import '../components/arena_floor.dart';
import '../components/chip_button.dart';
import '../components/control_stick.dart';
import '../components/fire_button.dart';
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
/// The whole playfield is visible at once, because it is a slide. Both sides of
/// the fight shrink as they lose -- AutoFit's own behaviour, turned on the
/// feature as well as on the player -- and whoever runs out of size first
/// loses.
class ArenaPage extends SlidePage {
  static const double _arenaWidth = 900;
  static const double _arenaHeight = 420;
  static const double _arenaTop = 150;
  static const double _playerSize = 120;

  @override
  Color get surfaceColor => Palette.showBlack;

  @override
  bool get castsShadow => false;

  final LevelDefinition _level = kLevels.first;

  late final ArenaFloor floor;
  late final ControlStick stick;
  late final FireButton fireButton;
  late final Player player;
  late final AutoFitBoss boss;

  /// True once the slide has been won or lost.
  bool get isResolved => _resolved;
  bool _resolved = false;

  late final TextComponent _sizeReadout;
  late final TextComponent _controlsHint;
  late int _shownHealth;

  @override
  Future<void> onLoad() async {
    floor = ArenaFloor(
      position: Vector2((kSlideWidth - _arenaWidth) / 2, _arenaTop),
      size: Vector2(_arenaWidth, _arenaHeight),
    );
    stick = ControlStick(position: Vector2(120, 612));
    player = Player(
      position: Vector2(_arenaWidth / 2, _arenaHeight - 90),
      size: _playerSize,
      joystick: stick,
      onDefeated: _onPlayerShrunkAway,
    );
    boss = AutoFitBoss(
      position: Vector2(_arenaWidth / 2, 100),
      aimAt: () => player.position,
      onDefeated: _onBossShrunkAway,
    );
    fireButton = FireButton(
      position: Vector2(1160, 612),
      onHeldChanged: (held) => player.triggerHeld = held,
    );
    _shownHealth = player.health.current;

    floor.addAll([boss, player]);

    await addAll([
      TextComponent(
        text: 'Slide ${_level.number} · ${_level.boss}',
        textRenderer: SlideText.showHeading,
        position: Vector2(kSlideWidth / 2, 80),
        anchor: Anchor.center,
      )..flyIn(delay: 0.05),
      floor,
      stick,
      fireButton,
      _sizeReadout = TextComponent(
        text: _readoutText,
        textRenderer: SlideText.showBody,
        position: Vector2(120, 524),
        anchor: Anchor.center,
      ),
      _controlsHint = TextComponent(
        text: 'Move with the stick or WASD. Fire with the button or Space.',
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

  String get _readoutText =>
      'You: ${(player.health.fraction * 100).round()}%';

  @override
  void update(double dt) {
    super.update(dt);
    // Only re-lay out the readout when the number it shows actually moves.
    if (_shownHealth != player.health.current) {
      _shownHealth = player.health.current;
      _sizeReadout.text = _readoutText;
    }
  }

  void _onBossShrunkAway() {
    _resolve(
      won: true,
      title: 'Slide complete',
      message: 'AutoFit shrank itself out of the deck. One feature down.',
    );
  }

  void _onPlayerShrunkAway() {
    _resolve(
      won: false,
      title: 'Slide failed',
      message: 'AutoFit shrank you until you no longer fit on the slide.',
    );
  }

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
    player.triggerHeld = false;
    stick.removeFromParent();
    fireButton.removeFromParent();
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
    game.router.pushNamed(Routes.slideShow);
  }

  void _leave() => game.router.pop();
}
