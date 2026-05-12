import 'package:flutter/widgets.dart';

/// Spacing scale lifted from `prototype/screens/*.html` Tailwind `spacing`
/// extension. Screens consume these by name (e.g. `AppSpacing.gutter`)
/// rather than raw numbers, so a future visual revision lives here.
abstract final class AppSpacing {
  /// Base atomic unit. Most other values are multiples of this.
  static const double unit = 4;

  /// Default inter-element gap inside a card / row.
  static const double gutter = 16;

  /// Vertical gap between major content sections on a screen.
  static const double sectionGap = 24;

  /// Default horizontal padding from screen edge.
  static const double containerMargin = 20;

  /// Default inner padding for cards.
  static const double cardPadding = 16;

  /// Convenience: standard horizontal screen-edge padding.
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: containerMargin,
  );

  /// Convenience: standard symmetric card-inner padding.
  static const EdgeInsets cardInner = EdgeInsets.all(cardPadding);
}
