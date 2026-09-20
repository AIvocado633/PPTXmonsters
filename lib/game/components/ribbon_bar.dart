import 'dart:ui';

import 'package:flame/components.dart';

import '../slide/slide_metrics.dart';
import '../theme/palette.dart';
import '../theme/slide_text.dart';

/// The strip of ribbon tabs along the top of a slide.
///
/// Purely decorative: it exists so that the first thing a player sees is
/// unmistakably PowerPoint.
class RibbonBar extends PositionComponent {
  RibbonBar({this.activeTab = 'Slide Show'})
    : super(position: Vector2.zero(), size: Vector2(kSlideWidth, kRibbonHeight));

  static const List<String> tabs = [
    'Home',
    'Insert',
    'Design',
    'Transitions',
    'Animations',
    'Slide Show',
    'Review',
  ];

  /// Which tab is drawn highlighted.
  final String activeTab;

  static const double _fileTabWidth = 86;
  static const double _tabPadding = 20;

  final Paint _backgroundPaint = Paint()..color = Palette.ribbon;
  final Paint _edgePaint = Paint()..color = Palette.ribbonEdge;
  final Paint _fileTabPaint = Paint()..color = Palette.brand;
  final Paint _underlinePaint = Paint()..color = Palette.brand;

  /// Left edge of each tab label, measured once so `render` stays layout-free.
  final List<double> _tabOffsets = [];
  double _activeTabWidth = 0;

  @override
  Future<void> onLoad() async {
    var cursor = _fileTabWidth + _tabPadding;
    for (final tab in tabs) {
      final width = SlideText.ribbonTab.getLineMetrics(tab).width;
      _tabOffsets.add(cursor);
      if (tab == activeTab) {
        _activeTabWidth = SlideText.ribbonTabActive.getLineMetrics(tab).width;
      }
      cursor += width + _tabPadding * 2;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _backgroundPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, kRibbonHeight - 1.5, kSlideWidth, 1.5),
      _edgePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _fileTabWidth, kRibbonHeight),
      _fileTabPaint,
    );
    SlideText.ribbonFileTab.render(
      canvas,
      'File',
      Vector2(_fileTabWidth / 2, kRibbonHeight / 2),
      anchor: Anchor.center,
    );

    for (var i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final isActive = tab == activeTab;
      final renderer = isActive
          ? SlideText.ribbonTabActive
          : SlideText.ribbonTab;
      renderer.render(
        canvas,
        tab,
        Vector2(_tabOffsets[i], kRibbonHeight / 2),
        anchor: Anchor.centerLeft,
      );
      if (isActive) {
        canvas.drawRect(
          Rect.fromLTWH(_tabOffsets[i], kRibbonHeight - 4, _activeTabWidth, 3),
          _underlinePaint,
        );
      }
    }
  }
}
