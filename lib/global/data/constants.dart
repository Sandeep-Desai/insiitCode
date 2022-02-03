import 'dart:ui';

import 'package:insiit/data/data_container.dart';

late DataContainer dataContainer;

bool darkMode = false;

class ScreenSize {
  static late Size size;
  static late double width;
  static late double height;
}

List<String> messHeadings = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];

Map<int, String> dayOfWeek = {
  1: 'Monday',
  2: 'Tuesday',
  3: 'Wednesday',
  4: 'Thursday',
  5: 'Friday',
  6: 'Saturday',
  7: 'Sunday'
};
