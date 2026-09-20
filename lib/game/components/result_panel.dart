import 'dart:ui';

import 'package:flame/components.dart';

import '../theme/palette.dart';
import '../theme/slide_text.dart';
import 'chip_button.dart';

/// The dialog that ends a slide, win or lose.
class ResultPanel extends PositionComponent {
  ResultPanel({
    required Vector2 position,
    required this.title,
    required this.message,
    required this.onRetry,
    required this.onLeave,
    this.won = true,
  }) : super(position: position, size: Vector2(580, 260), anchor: Anchor.center);

  final String title;
  final String message;
  final void Function() onRetry;
  final void Function() onLeave;
  final bool won;

  static const double _headerHeight = 58;

  late final Paint _surfacePaint = Paint()..color = Palette.slide;
  late final Paint _headerPaint = Paint()
    ..color = won ? Palette.brand : Palette.inkSoft;
  final Paint _shadowPaint = Paint()
    ..color = const Color(0x99000000)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

  @override
  Future<void> onLoad() async {
    await addAll([
      TextComponent(
        text: title,
        textRenderer: SlideText.resultTitle,
        position: Vector2(width / 2, _headerHeight / 2),
        anchor: Anchor.center,
      ),
      TextComponent(
        text: message,
        textRenderer: SlideText.caption,
        position: Vector2(width / 2, 118),
        anchor: Anchor.center,
      ),
      ChipButton(
        label: 'Retry Slide',
        filled: true,
        position: Vector2(180, 192),
        anchor: Anchor.center,
        width: 180,
        onSelected: onRetry,
      ),
      ChipButton(
        label: 'End Show',
        position: Vector2(400, 192),
        anchor: Anchor.center,
        width: 180,
        onSelected: onLeave,
      ),
    ]);
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    canvas.drawRect(rect.deflate(8), _shadowPaint);
    canvas.drawRect(rect, _surfacePaint);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, _headerHeight),
      _headerPaint,
    );
  }
}
