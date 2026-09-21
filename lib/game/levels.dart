/// The deck the player has to get through.
///
/// Each level is one slide, and each boss is a PowerPoint feature that has
/// personally wronged someone.
class LevelDefinition {
  const LevelDefinition({
    required this.number,
    required this.boss,
    required this.tagline,
    required this.winLine,
    required this.lossLine,
    this.unlocked = false,
  });

  final int number;
  final String boss;

  /// One line on the slide sorter thumbnail.
  final String tagline;

  /// How the feature goes out, shown when the slide is won.
  final String winLine;

  /// How the feature got you, shown when the slide is lost.
  final String lossLine;

  /// Whether the level can be played. For now this tracks whether its boss has
  /// actually been built; `deck_test` fails if the two ever disagree.
  final bool unlocked;
}

/// The level with this [LevelDefinition.number].
LevelDefinition levelNumbered(int number) =>
    kLevels.firstWhere((level) => level.number == number);

const List<LevelDefinition> kLevels = [
  LevelDefinition(
    number: 1,
    boss: 'AutoFit',
    tagline: 'Shrinks your text on sight',
    winLine: 'AutoFit shrank itself out of the deck. One feature down.',
    lossLine: 'AutoFit shrank you until you no longer fit on the slide.',
    unlocked: true,
  ),
  LevelDefinition(
    number: 2,
    boss: 'SmartArt',
    tagline: 'Neither smart nor art',
    winLine: 'SmartArt ran out of shapes to rearrange. Two features down.',
    lossLine: 'SmartArt rearranged the slide until there was no room for you.',
    unlocked: true,
  ),
  LevelDefinition(
    number: 3,
    boss: 'Slide Master',
    tagline: 'Changes everything at once',
    winLine: 'The Slide Master has been overruled.',
    lossLine: 'The Slide Master changed you, along with everything else.',
  ),
  LevelDefinition(
    number: 4,
    boss: 'Animation Pane',
    tagline: 'Seventeen triggers, no order',
    winLine: 'The Animation Pane is finally empty.',
    lossLine: 'Your exit animation was set to On Click. Someone clicked.',
  ),
  LevelDefinition(
    number: 5,
    boss: 'Snap to Grid',
    tagline: 'Almost where you wanted it',
    winLine: 'Snap to Grid has been switched off. Nothing lines up. It is fine.',
    lossLine: 'You were snapped to the nearest gridline and left there.',
  ),
  LevelDefinition(
    number: 6,
    boss: 'Compatibility Mode',
    tagline: 'Saved as .ppt in 2003',
    winLine: 'Saved as .pptx at last.',
    lossLine: 'Some features are not available in this file format. You were one.',
  ),
];
