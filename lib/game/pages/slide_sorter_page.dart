import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../components/chip_button.dart';
import '../components/ribbon_bar.dart';
import '../components/slide_painting.dart';
import '../components/status_bar.dart';
import '../levels.dart';
import '../routes.dart';
import '../slide/fly_in.dart';
import '../slide/slide_metrics.dart';
import '../slide/slide_page.dart';
import '../theme/palette.dart';
import '../theme/slide_text.dart';

/// Level select, dressed as PowerPoint's slide sorter view.
class SlideSorterPage extends SlidePage {
  static const double _thumbWidth = 300;
  static const double _thumbHeight = 169;
  static const double _gapX = 40;
  static const double _gapY = 70;
  static const int _columns = 3;
  static const double _gridTop = 190;

  @override
  Future<void> onLoad() async {
    await addAll([
      RibbonBar(activeTab: 'Design'),
      StatusBar(slideLabel: 'Slide sorter · ${kLevels.length} slides'),
      TextComponent(
        text: 'Slide Sorter',
        textRenderer: SlideText.sectionTitle,
        position: Vector2(kSlideMargin, 100),
        anchor: Anchor.centerLeft,
      )..flyIn(delay: 0.05),
      TextComponent(
        text: 'Pick the feature you are prepared to argue with.',
        textRenderer: SlideText.subtitle,
        position: Vector2(kSlideMargin + 4, 140),
        anchor: Anchor.centerLeft,
      )..flyIn(delay: 0.1),
    ]);

    const gridWidth = _columns * _thumbWidth + (_columns - 1) * _gapX;
    final originX = (kSlideWidth - gridWidth) / 2;

    for (final (index, level) in kLevels.indexed) {
      final column = index % _columns;
      final row = index ~/ _columns;
      await add(
        _SlideThumbnail(
          level: level,
          position: Vector2(
            originX + column * (_thumbWidth + _gapX),
            _gridTop + row * (_thumbHeight + _gapY),
          ),
          size: Vector2(_thumbWidth, _thumbHeight),
          onSelected: () => game.router.pushNamed(Routes.slideShow),
        )..flyIn(delay: 0.16 + index * 0.05),
      );
    }

    // Top-right, so it stays clear of the second row's captions.
    await add(
      ChipButton(
        label: 'Back to Normal View',
        position: Vector2(kSlideWidth - kSlideMargin - 250, 92),
        width: 250,
        onSelected: game.router.pop,
      )..flyIn(from: Vector2(120, 0), delay: 0.5),
    );
  }
}

/// One slide thumbnail in the sorter grid: a level, locked or not.
class _SlideThumbnail extends PositionComponent
    with TapCallbacks, HoverCallbacks {
  _SlideThumbnail({
    required this.level,
    required this.onSelected,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  final LevelDefinition level;
  final void Function() onSelected;

  bool get _enabled => level.unlocked;

  final Paint _surfacePaint = Paint()..color = Palette.slide;
  final Paint _lockedSurfacePaint = Paint()..color = const Color(0xFFF6F6F6);
  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _bulletPaint = Paint()..color = Palette.brand;
  final Paint _lockedBulletPaint = Paint()..color = Palette.locked;
  final Paint _linePaint = Paint()..color = const Color(0xFFE3E3E3);

  @override
  Future<void> onLoad() async {
    addAll([
      TextComponent(
        text: '${level.number}',
        textRenderer: SlideText.thumbnailNumber,
        position: Vector2(0, -10),
        anchor: Anchor.bottomLeft,
      ),
      TextComponent(
        text: level.boss,
        textRenderer: level.unlocked
            ? SlideText.thumbnailTitle
            : SlideText.thumbnailTitleLocked,
        position: Vector2(0, height + 16),
      ),
      TextComponent(
        text: level.tagline,
        textRenderer: SlideText.thumbnailSubtitle,
        position: Vector2(0, height + 44),
      ),
    ]);
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect, _enabled ? _surfacePaint : _lockedSurfacePaint);

    // A miniature of the slide's content: a title bar and two bullet lines.
    final bullet = _enabled ? _bulletPaint : _lockedBulletPaint;
    canvas.drawRect(Rect.fromLTWH(22, 26, 150, 14), bullet);
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(22, 66.0 + i * 22, 210 - i * 34, 8),
        _linePaint,
      );
    }
    if (!_enabled) {
      canvas.drawPath(
        boltPath(Offset(width - 46, height - 42), 40),
        _lockedBulletPaint,
      );
    }

    _borderPaint.color = _enabled
        ? (isHovered ? Palette.brand : Palette.ribbonEdge)
        : Palette.ribbonEdge;
    canvas.drawRect(rect, _borderPaint);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (_enabled) {
      onSelected();
    }
  }
}
