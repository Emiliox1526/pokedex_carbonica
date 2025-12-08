import 'package:flutter/material.dart';

/// Application theme configuration.
///
/// Defines the Material 3 theme used throughout the app.
class AppTheme {
  /// Creates a Material 3 theme with the specified color seed.
  static ThemeData getTheme({Color seedColor = Colors.red}) {
    return ThemeData(
      colorSchemeSeed: seedColor,
      useMaterial3: true,
    );
  }

  /// Default theme for the application.
  static ThemeData get defaultTheme => getTheme();
}
