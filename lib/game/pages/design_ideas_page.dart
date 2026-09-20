import 'dart:ui';

import 'package:flame/components.dart';

import '../components/chip_button.dart';
import '../components/placeholder_frame.dart';
import '../components/ribbon_bar.dart';
import '../components/status_bar.dart';
import '../slide/fly_in.dart';
import '../slide/slide_metrics.dart';
import '../slide/slide_page.dart';
import '../theme/slide_text.dart';

/// Settings, dressed as PowerPoint's "Design Ideas" task pane.
///
/// A stub for now: the pane exists so the menu entry leads somewhere real, and
/// so there is an obvious home for audio, controls and accessibility options.
class DesignIdeasPage extends SlidePage {
  static const List<({String title, String body})> _ideas = [
    (title: 'Sound', body: 'Music and effect volume'),
    (title: 'Controls', body: 'Joystick side and dead zone'),
    (title: 'Motion', body: 'Reduce slide transitions'),
  ];

  @override
  Future<void> onLoad() async {
    await addAll([
      RibbonBar(activeTab: 'Design'),
      StatusBar(slideLabel: 'Design Ideas'),
      TextComponent(
        text: 'Design Ideas',
        textRenderer: SlideText.sectionTitle,
        position: Vector2(kSlideMargin, 110),
        anchor: Anchor.centerLeft,
      )..flyIn(delay: 0.05),
      TextComponent(
        text: 'Settings live here. None of them do anything yet.',
        textRenderer: SlideText.subtitle,
        position: Vector2(kSlideMargin + 4, 152),
        anchor: Anchor.centerLeft,
      )..flyIn(delay: 0.1),
    ]);

    for (final (index, idea) in _ideas.indexed) {
      final card = PlaceholderFrame(
        position: Vector2(kSlideMargin, 210 + index * 120),
        size: Vector2(kSlideWidth - kSlideMargin * 2, 100),
        fillColor: const Color(0xFFFBFAF9),
      );
      card.addAll([
        TextComponent(
          text: idea.title,
          textRenderer: SlideText.heading,
          position: Vector2(28, 34),
          anchor: Anchor.centerLeft,
        ),
        TextComponent(
          text: idea.body,
          textRenderer: SlideText.caption,
          position: Vector2(28, 68),
          anchor: Anchor.centerLeft,
        ),
      ]);
      await add(card..flyIn(delay: 0.16 + index * 0.07));
    }

    await add(
      ChipButton(
        label: 'Back to Normal View',
        position: Vector2(kSlideMargin, 596),
        width: 250,
        onSelected: game.router.pop,
      )..flyIn(delay: 0.42),
    );
  }
}
