import 'package:flutter/material.dart';
import 'package:insiit/global/data/constants.dart';

class ThemeContainer {
  Color backgroundColor;
  Color appBarColor;
  Color textHeadingColor;
  Color textSubheadingColor;
  Color iconColor;
  Color indicatorColor;
  Color expansionTileHighlight;
  Color accentColor;
  Color floatingColor;
  Color cardAccent;
  Color upvoteColor;
  Color downvoteColor;
  Color iconColorLite;
  Color buttonColor;
  Color buttonContentColor;
  Color bottomNavyBarColor;
  Color bottomNavyBarIndicatorColor;
  Color flatButtonOutlineColor;
  Color cardBgColor;
  ThemeContainer(
      {required this.backgroundColor,
      required this.appBarColor,
      required this.textHeadingColor,
      required this.textSubheadingColor,
      required this.iconColor,
      required this.indicatorColor,
      required this.expansionTileHighlight,
      required this.accentColor,
      required this.cardAccent,
      required this.floatingColor,
      required this.downvoteColor,
      required this.cardBgColor,
      required this.flatButtonOutlineColor,
      required this.upvoteColor,
      required this.buttonColor,
      required this.buttonContentColor,
      required this.bottomNavyBarColor,
      required this.bottomNavyBarIndicatorColor,
      required this.iconColorLite});
}

ThemeContainer lightTheme = ThemeContainer(
  backgroundColor: Colors.white,
  appBarColor: Colors.transparent,
  textHeadingColor: Colors.black,
  textSubheadingColor: Colors.black.withAlpha(158),
  iconColor: Colors.black,
  indicatorColor: Colors.black,
  expansionTileHighlight: Colors.black,
  floatingColor: Colors.black,
  accentColor: Colors.black,
  upvoteColor: Colors.green,
  downvoteColor: Colors.red,
  iconColorLite: Colors.black.withAlpha(100),
  cardAccent: Colors.black.withAlpha(3),
  cardBgColor: Colors.white,
  flatButtonOutlineColor: Colors.black.withAlpha(30),
  buttonColor: Colors.black,
  buttonContentColor: Colors.white,
  bottomNavyBarColor: Colors.white,
  bottomNavyBarIndicatorColor: Colors.black.withAlpha(50),
);
ThemeContainer darkTheme = ThemeContainer(
  backgroundColor: Color.fromRGBO(36, 36, 36, 1),
  appBarColor: Color.fromRGBO(33, 33, 33, 1),
  textHeadingColor: Colors.white.withAlpha(200),
  textSubheadingColor: Colors.white.withAlpha(158),
  iconColor: Colors.white.withAlpha(200),
  flatButtonOutlineColor: Colors.white.withAlpha(30),
  iconColorLite: Colors.white.withAlpha(100),
  indicatorColor: Colors.white,
  expansionTileHighlight: Colors.black,
  accentColor: Colors.black,
  floatingColor: Colors.black,
  cardAccent: Colors.white.withAlpha(3),
  cardBgColor: Colors.white.withAlpha(3),
  upvoteColor: Color.fromRGBO(7, 143, 18, 1),
  downvoteColor: Color.fromRGBO(143, 12, 7, 1),
  buttonColor: Colors.black,
  buttonContentColor: Colors.white,
  bottomNavyBarColor: Color.fromRGBO(48, 48, 48, 1),
  bottomNavyBarIndicatorColor: Colors.black.withAlpha(100),
);

ThemeContainer theme = lightTheme;

Future getTheme() async {
  return dataContainer.generalData.darkMode;
}

void swapTheme(darkOn) {
  if (darkOn) {
    theme = darkTheme;
  } else {
    theme = lightTheme;
  }
}
