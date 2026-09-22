import 'package:flame/components.dart';
import 'package:flame/events.dart';

import 'slide_page.dart';

/// Something on a slide that can be chosen with the keyboard or a controller
/// as well as by tapping it.
///
/// Focus is kept by the [SlidePage] the component sits on. Hovering with a
/// mouse moves focus too, so hover and focus are one highlight: whatever
/// [isHighlighted] says, only one thing on a page is ever lit.
mixin Focusable on PositionComponent, HoverCallbacks {
  /// Whether focus can land here. A disabled menu entry says no.
  bool get canFocus => true;

  /// Does what tapping would. Called for Enter, Space and controller A.
  void activate();

  SlidePage? _page;

  @override
  void onMount() {
    super.onMount();
    _page = findParent<SlidePage>();
  }

  /// Whether to draw this as selected: it has focus, and either the player is
  /// steering with keys or a controller, or the mouse is over it.
  bool get isHighlighted {
    final page = _page;
    return page != null &&
        identical(page.focused, this) &&
        (page.focusVisible || isHovered);
  }

  @override
  void onHoverEnter() {
    super.onHoverEnter();
    if (canFocus) {
      _page?.focusOn(this);
    }
  }
}
