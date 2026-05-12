import 'package:flutter/widgets.dart';

/// Corner-radius scale from `prototype/screens/*.html` Tailwind `borderRadius`
/// extension. The custom `rounded-[21px]` used on hero cards is exposed as
/// [hero] so screens don't have to repeat the magic number.
abstract final class AppRadii {
  static const Radius defaultRadius = Radius.circular(4);
  static const Radius lg = Radius.circular(8);
  static const Radius xl = Radius.circular(12);

  /// Hero / live-player cards — matches `rounded-[21px]` in the prototype.
  static const Radius hero = Radius.circular(21);

  /// Pills / chips / avatars.
  static const Radius full = Radius.circular(9999);

  // BorderRadius (all-sides) convenience accessors.
  static const BorderRadius defaultRadiusAll =
      BorderRadius.all(defaultRadius);
  static const BorderRadius lgAll = BorderRadius.all(lg);
  static const BorderRadius xlAll = BorderRadius.all(xl);
  static const BorderRadius heroAll = BorderRadius.all(hero);
  static const BorderRadius fullAll = BorderRadius.all(full);
}
