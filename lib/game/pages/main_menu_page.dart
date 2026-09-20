import 'dart:ui';

import 'package:flame/components.dart';

import '../components/autoshape_backdrop.dart';
import '../components/menu_bullet_button.dart';
import '../components/placeholder_frame.dart';
import '../components/pptx_actor.dart';
import '../components/ribbon_bar.dart';
import '../components/status_bar.dart';
import '../routes.dart';
import '../slide/fly_in.dart';
import '../slide/slide_metrics.dart';
import '../slide/slide_page.dart';
import '../theme/palette.dart';
import '../theme/slide_text.dart';

/// The start menu: slide 1 of the deck, still sitting in normal editing view.
class MainMenuPage extends SlidePage {
  static const double _titleLeft = kSlideMargin;
  static const double _titleTop = 100;
  static const double _panelLeft = 840;
  static const double _panelWidth = 364;

  @override
  Future<void> onLoad() async {
    await addAll([
      AutoshapeBackdrop(seed: 7),
      RibbonBar(activeTab: 'Slide Show'),
      StatusBar(slideLabel: 'Slide 1 of 6'),
    ]);

    await add(_buildTitle());
    await add(_buildSubtitle());
    await addAll(_buildMenu());
    await add(_buildDesignIdeasPanel());
    await add(_buildFooter());
  }

  PositionComponent _buildTitle() {
    final frame = PlaceholderFrame(
      position: Vector2(_titleLeft, _titleTop),
      size: Vector2(700, 150),
    );
    const brandWord = 'PPTX ';
    final brandWidth = SlideText.titleBrand.getLineMetrics(brandWord).width;
    frame.addAll([
      TextComponent(
        text: brandWord,
        textRenderer: SlideText.titleBrand,
        position: Vector2(28, 75),
        anchor: Anchor.centerLeft,
      ),
      TextComponent(
        text: 'MONSTERS',
        textRenderer: SlideText.titleInk,
        position: Vector2(28 + brandWidth, 75),
        anchor: Anchor.centerLeft,
      ),
      _Caret(position: Vector2(28 + brandWidth + _monstersWidth + 10, 75)),
    ]);
    return frame..flyIn(delay: 0.05);
  }

  static final double _monstersWidth =
      SlideText.titleInk.getLineMetrics('MONSTERS').width;

  PositionComponent _buildSubtitle() {
    return TextComponent(
      text: 'Click to defeat the features that defeated you.',
      textRenderer: SlideText.subtitle,
      position: Vector2(_titleLeft + 30, 282),
      anchor: Anchor.centerLeft,
    )..flyIn(delay: 0.16);
  }

  List<PositionComponent> _buildMenu() {
    final entries = <({String label, String? hint, String route, bool enabled})>[
      (
        label: 'Start Slide Show',
        hint: 'F5',
        route: Routes.slideShow,
        enabled: true,
      ),
      (
        label: 'Slide Sorter',
        hint: 'Levels',
        route: Routes.slideSorter,
        enabled: true,
      ),
      (
        label: 'Design Ideas',
        hint: 'Settings',
        route: Routes.designIdeas,
        enabled: true,
      ),
    ];

    return [
      for (final (index, entry) in entries.indexed)
        MenuBulletButton(
          label: entry.label,
          hint: entry.hint,
          enabled: entry.enabled,
          position: Vector2(_titleLeft - 4, 336 + index * 78),
          onSelected: () => game.router.pushNamed(entry.route),
        )..flyIn(delay: 0.24 + index * 0.08),
    ];
  }

  PositionComponent _buildDesignIdeasPanel() {
    final panel = PlaceholderFrame(
      position: Vector2(_panelLeft, _titleTop),
      size: Vector2(_panelWidth, 470),
      fillColor: const Color(0xFFFBFAF9),
    );

    const actorSize = 230.0;
    final actorTopLeft = Vector2((_panelWidth - actorSize) / 2, 110);

    panel.addAll([
      TextComponent(
        text: 'DESIGN IDEAS',
        textRenderer: SlideText.panelHeading,
        position: Vector2(_panelWidth / 2, 34),
        anchor: Anchor.center,
      ),
      PptxActor(
        artPrefix: 'hero_idle_',
        position: actorTopLeft,
        size: Vector2.all(actorSize),
      ),
      SelectionHandles(
        position: actorTopLeft - Vector2.all(10),
        size: Vector2.all(actorSize + 20),
      ),
      TextComponent(
        text: 'The Presenter',
        textRenderer: SlideText.heading,
        position: Vector2(_panelWidth / 2, 384),
        anchor: Anchor.center,
      ),
      TextComponent(
        text: 'Shape 1 · drawn in PowerPoint',
        textRenderer: SlideText.caption,
        position: Vector2(_panelWidth / 2, 420),
        anchor: Anchor.center,
      ),
    ]);

    return panel..flyIn(from: Vector2(120, 0), delay: 0.3);
  }

  PositionComponent _buildFooter() {
    return TextComponent(
      text: 'Six features stand between you and the end of the deck.',
      textRenderer: SlideText.caption,
      position: Vector2(_titleLeft + 30, 610),
      anchor: Anchor.centerLeft,
    )..flyIn(delay: 0.5);
  }
}

/// The text cursor that blinks at the end of the title, as if the deck is
/// still being typed.
class _Caret extends PositionComponent {
  _Caret({required Vector2 position})
    : super(position: position, size: Vector2(4, 66), anchor: Anchor.centerLeft);

  static const double _blinkPeriod = 0.55;

  double _elapsed = 0;
  bool _visible = true;

  final Paint _paint = Paint()..color = Palette.ink;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= _blinkPeriod) {
      _elapsed -= _blinkPeriod;
      _visible = !_visible;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_visible) {
      canvas.drawRect(size.toRect(), _paint);
    }
  }
}
