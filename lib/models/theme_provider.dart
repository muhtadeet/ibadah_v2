import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define available colors
final predefinedColors = {
  'Purple': Colors.deepPurpleAccent,
  'Blue': Colors.blueAccent,
  'Green': Colors.greenAccent,
  'Red': Colors.redAccent,
};

// Provider for color scheme
final colorProvider = StateProvider<Color>((ref) => predefinedColors['Purple']!);

enum ThemeModeOption { light, dark, system }

// Provider for managing theme mode
final themeModeProvider = StateProvider<ThemeModeOption>((ref) {
  return ThemeModeOption.system; // Default to system theme
});
