/// Named routes handled by the game's `RouterComponent`.
///
/// Routes are named after PowerPoint views on purpose -- the whole game is
/// framed as "you are inside a deck".
abstract final class Routes {
  /// The start menu: a blank-ish title slide in normal editing view.
  static const normalView = 'normal-view';

  /// Level select, presented as PowerPoint's slide sorter grid.
  static const slideSorter = 'slide-sorter';

  /// Gameplay: the top-down arena, presented as a running slide show.
  static const slideShow = 'slide-show';

  /// Settings, presented as the "Design Ideas" task pane.
  static const designIdeas = 'design-ideas';
}
