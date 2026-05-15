import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

class Sym {
  static IconData mic(bool filled) => filled ? Symbols.mic_rounded : Symbols.mic;
  static IconData dashboard(bool filled) =>
      filled ? Symbols.dashboard_rounded : Symbols.dashboard;
  static IconData home(bool filled) => filled ? Symbols.home_rounded : Symbols.home;
  static IconData person(bool filled) => filled ? Symbols.person_rounded : Symbols.person;
  static IconData mail(bool filled) => filled ? Symbols.mail_rounded : Symbols.mail;
  static IconData locationOn(bool filled) =>
      filled ? Symbols.location_on_rounded : Symbols.location_on;

  static const IconData cellTower = Symbols.cell_tower;
  static const IconData mosque = Symbols.mosque;
  static const IconData chevronLeft = Symbols.chevron_left;
  static const IconData stopFilled = Symbols.stop_rounded;
  static const IconData pause = Symbols.pause;
  static const IconData edit = Symbols.edit;
  static const IconData checkCircle = Symbols.check_circle_rounded;
  static const IconData cancelCircle = Symbols.cancel_rounded;
  static const IconData trendingUp = Symbols.trending_up_rounded;
  static const IconData keyboardDoubleArrowUp = Symbols.keyboard_double_arrow_up;
  static const IconData signalCellular = Symbols.signal_cellular_alt_rounded;
  static const IconData wifi = Symbols.wifi_rounded;
  static const IconData batteryFull = Symbols.battery_full_rounded;
}
