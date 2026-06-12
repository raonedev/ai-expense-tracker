import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

// Provides the current ThemeMode (light, dark, or system default)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system; // Follows the device configuration out of the box
});