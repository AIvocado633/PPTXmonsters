import 'dart:ui';

/// Colours lifted straight from the PowerPoint UI.
///
/// Every screen in this game is dressed as a slide, so the whole palette is
/// deliberately "Office" rather than "game": the fun comes from the contrast.
abstract final class Palette {
  /// The grey desk the slide sits on (visible as letterbox bars).
  static const workspace = Color(0xFF2B2B2B);
  static const workspaceEdge = Color(0xFF1C1C1C);

  /// The slide surface itself.
  static const slide = Color(0xFFFFFFFF);
  static const slideShadow = Color(0x66000000);

  /// PowerPoint's signature orange-red, plus shades for hover/press states.
  static const brand = Color(0xFFC43E1C);
  static const brandDark = Color(0xFFA23214);
  static const brandLight = Color(0xFFE8664A);
  static const brandWash = Color(0x14C43E1C);
  static const brandWashStrong = Color(0x29C43E1C);

  /// Ribbon / chrome greys.
  static const ribbon = Color(0xFFF3F2F1);
  static const ribbonEdge = Color(0xFFE1DFDD);
  static const statusBar = Color(0xFFF3F2F1);

  /// Text.
  static const ink = Color(0xFF1B1B1B);
  static const inkSoft = Color(0xFF605E5C);
  static const inkFaint = Color(0xFF8A8886);

  /// Empty-placeholder chrome (the dashed boxes on a blank slide).
  static const placeholderStroke = Color(0xFFBFBFBF);
  static const placeholderText = Color(0xFFA6A6A6);

  /// Accents.
  static const hyperlink = Color(0xFF0563C1);
  static const selection = Color(0xFF2B579A);
  static const locked = Color(0xFFD6D6D6);

  /// Presenting mode: the projector-black behind a running slide show.
  static const showBlack = Color(0xFF0D0D0D);
}
