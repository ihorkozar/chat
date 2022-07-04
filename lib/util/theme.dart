import 'package:chat/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const appBarTheme = AppBarTheme(
    centerTitle: false, elevation: 0, backgroundColor: Colors.white);

final tabBarTheme = TabBarTheme(
    indicatorSize: TabBarIndicatorSize.label,
    unselectedLabelColor: Colors.black54,
    indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50), color: appColor));

final dividerTheme =
const DividerThemeData().copyWith(thickness: 1.2, indent: 75);

ThemeData lightTheme(BuildContext context) => ThemeData.light().copyWith(
    primaryColor: appColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: appBarTheme,
    tabBarTheme: tabBarTheme,
    dividerTheme: dividerTheme,
    iconTheme: const IconThemeData(color: iconLight),
    textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
        .apply(displayColor: Colors.black),
    visualDensity: VisualDensity.adaptivePlatformDensity);

ThemeData darkTheme(BuildContext context) => ThemeData.dark().copyWith(
    primaryColor: appColor,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: appBarTheme.copyWith(backgroundColor: appBarDark),
    tabBarTheme: tabBarTheme.copyWith(unselectedLabelColor: Colors.white),
    dividerTheme: dividerTheme.copyWith(color: bubbleDark),
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: GoogleFonts.comfortaaTextTheme(Theme.of(context).textTheme)
        .apply(displayColor: Colors.white),
    visualDensity: VisualDensity.adaptivePlatformDensity);

bool isLightTheme(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.light;
}