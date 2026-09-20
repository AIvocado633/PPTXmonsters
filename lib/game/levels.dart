/// The deck the player has to get through.
///
/// Each level is one slide, and each boss is a PowerPoint feature that has
/// personally wronged someone.
class LevelDefinition {
  const LevelDefinition({
    required this.number,
    required this.boss,
    required this.tagline,
    this.unlocked = false,
  });

  final int number;
  final String boss;
  final String tagline;
  final bool unlocked;
}

const List<LevelDefinition> kLevels = [
  LevelDefinition(
    number: 1,
    boss: 'AutoFit',
    tagline: 'Shrinks your text on sight',
    unlocked: true,
  ),
  LevelDefinition(
    number: 2,
    boss: 'SmartArt',
    tagline: 'Neither smart nor art',
  ),
  LevelDefinition(
    number: 3,
    boss: 'Slide Master',
    tagline: 'Changes everything at once',
  ),
  LevelDefinition(
    number: 4,
    boss: 'Animation Pane',
    tagline: 'Seventeen triggers, no order',
  ),
  LevelDefinition(
    number: 5,
    boss: 'Snap to Grid',
    tagline: 'Almost where you wanted it',
  ),
  LevelDefinition(
    number: 6,
    boss: 'Compatibility Mode',
    tagline: 'Saved as .ppt in 2003',
  ),
];
