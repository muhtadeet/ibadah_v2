import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define available colors
final predefinedColors = {
  'Purple': Colors.deepPurpleAccent,
  'Blue': Colors.blueAccent,
  'Green': Colors.greenAccent,
  'Red': Colors.redAccent,
};

// Define the theme mode options
enum ThemeModeOption { light, dark, system }

// Provider for color scheme
final colorProvider = StateNotifierProvider<ColorNotifier, Color>((ref) => ColorNotifier());

// Provider for managing theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeModeOption>((ref) => ThemeModeNotifier());

class ColorNotifier extends StateNotifier<Color> {
  ColorNotifier() : super(predefinedColors['Purple']!) {
    _loadColor();
  }

  Future<void> _loadColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? colorName = prefs.getString('selectedColor');
    if (colorName != null && predefinedColors.containsKey(colorName)) {
      state = predefinedColors[colorName]!;
    }
  }

  Future<void> setColor(String colorName) async {
    if (predefinedColors.containsKey(colorName)) {
      state = predefinedColors[colorName]!;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedColor', colorName);
    }
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeModeOption> {
  ThemeModeNotifier() : super(ThemeModeOption.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeMode = prefs.getString('themeMode');
    if (themeMode == 'light') {
      state = ThemeModeOption.light;
    } else if (themeMode == 'dark') {
      state = ThemeModeOption.dark;
    } else {
      state = ThemeModeOption.system;
    }
  }

  Future<void> setThemeMode(ThemeModeOption mode) async {
    state = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }
}
