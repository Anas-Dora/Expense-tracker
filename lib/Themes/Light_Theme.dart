// ignore_for_file: file_names

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue.shade800,
    scaffoldBackgroundColor: Colors.white, // Hintergrund hell
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white, // AppBar Text in weiß
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Colors.blue.shade800),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.blue.shade800),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade800),
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.blue.shade50),
      ),
    ),
  );
}

ThemeData blueLightTheme() {
  return FlexThemeData.light(
    scheme: FlexScheme.shadBlue,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    useMaterial3: true,
  );
}
