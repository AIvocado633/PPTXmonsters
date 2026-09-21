import 'combat/autofit_boss.dart';
import 'combat/boss.dart';
import 'combat/smartart_boss.dart';

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
    this.buildBoss,
  });

  final int number;

  /// The feature's name, as the slide sorter and the arena show it.
  final String boss;

  /// One line on the slide sorter thumbnail.
  final String tagline;

  /// How the feature goes out, shown when the slide is won.
  final String winLine;

  /// How the feature got you, shown when the slide is lost.
  final String lossLine;

  /// Builds the feature standing in the way, or null while its fight has not
  /// been written yet.
  final BossBuilder? buildBoss;

  /// Whether this slide's fight exists in this build of the game. Whether the
  /// player has earned it yet is a separate question.
  bool get isBuilt => buildBoss != null;
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
    buildBoss: AutoFitBoss.new,
  ),
  LevelDefinition(
    number: 2,
    boss: 'SmartArt',
    tagline: 'Neither smart nor art',
    winLine: 'SmartArt ran out of shapes to rearrange. Two features down.',
    lossLine: 'SmartArt rearranged the slide until there was no room for you.',
    buildBoss: SmartArtBoss.new,
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
