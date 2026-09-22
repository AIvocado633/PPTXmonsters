import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../pptx_monsters_game.dart';
import '../save/save_data.dart';
import '../theme/palette.dart';
import 'slide_metrics.dart';

/// Base class for every screen in the game.
///
/// A [SlidePage] is a fixed [kSlideWidth] x [kSlideHeight] canvas that scales
/// itself to fit the window and centres itself, leaving letterbox bars on
/// screens that are not 16:9. Subclasses lay out their children in slide units
/// and never have to deal with the real screen size.
abstract class SlidePage extends PositionComponent
    with HasGameReference<PptxMonstersGame> {
  SlidePage() : super(size: slideSize);

  /// Colour of the slide surface. Override for e.g. the projector-black used
  /// while a slide show is running.
  Color get surfaceColor => Palette.slide;

  /// Whether to draw the drop shadow that separates the slide from the desk.
  bool get castsShadow => true;

  final Paint _surfacePaint = Paint();
  final Paint _shadowPaint = Paint()
    ..color = Palette.slideShadow
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

  /// Called when the player's progress changes while this page exists, e.g.
  /// when a slide is won on a page pushed on top of it. Pages that show
  /// progress rebuild those parts here; they built them first in `onLoad`.
  void onProgressChanged() {}

  Progress? _progressShown;

  @override
  void update(double dt) {
    super.update(dt);
    // Progress is immutable and replaced whenever it changes, so identity
    // says whether this page is out of date.
    final progress = game.save.data.progress;
    if (_progressShown != null && !identical(progress, _progressShown)) {
      onProgressChanged();
    }
    _progressShown = progress;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (size.x <= 0 || size.y <= 0) {
      return;
    }
    final factor = math.min(size.x / kSlideWidth, size.y / kSlideHeight);
    scale = Vector2.all(factor);
    position = (size - slideSize * factor) / 2;
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    if (castsShadow) {
      canvas.drawRect(rect.deflate(6), _shadowPaint);
    }
    canvas.drawRect(rect, _surfacePaint..color = surfaceColor);
  }
}
