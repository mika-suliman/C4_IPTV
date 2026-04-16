import 'package:flutter/material.dart';

class AppThemes {
  // Refined teal accent color
  static const Color _primaryColor = Color(0xFF64FFDA);
  static const Color _primaryDark = Color(0xFF00BFA5);

  // Sky Blue palette
  static const Color _skyBluePrimary = Color(0xFF4A90D9);
  static const Color _skyBlueAccent = Color(0xFF2E7BC6);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: _primaryDark,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFB2DFDB),
      onPrimaryContainer: const Color(0xFF00332C),
      secondary: const Color(0xFF4DB6AC),
      onSecondary: Colors.white,
      surface: const Color(0xFFF5F5F5),
      onSurface: const Color(0xFF1C1C1C),
      onSurfaceVariant: const Color(0xFF5F5F5F),
      outline: const Color(0xFFD0D0D0),
      surfaceContainerHighest: const Color(0xFFE8E8E8),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primaryColor,
      onPrimary: const Color(0xFF003731),
      primaryContainer: const Color(0xFF004D40),
      onPrimaryContainer: _primaryColor,
      secondary: const Color(0xFF4DB6AC),
      onSecondary: const Color(0xFF003731),
      surface: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFE0E0E0),
      onSurfaceVariant: const Color(0xFF9E9E9E),
      outline: const Color(0xFF333333),
      surfaceContainerHighest: const Color(0xFF2C2C2C),
      surfaceContainerHigh: const Color(0xFF252525),
      surfaceContainer: const Color(0xFF212121),
      surfaceContainerLow: const Color(0xFF1A1A1A),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF1E1E1E),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFF1A1A1A),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1A1A1A),
      indicatorColor: const Color(0xFF004D40),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: Color(0xFF64FFDA),
      unselectedItemColor: Color(0xFF9E9E9E),
    ),
    dividerColor: const Color(0xFF333333),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFF252525),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: const Color(0xFF252525),
      selectedColor: const Color(0xFF004D40),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E1E1E),
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static final ThemeData skyBlueTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _skyBluePrimary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD0E8F9),
      onPrimaryContainer: const Color(0xFF0A3A6B),
      secondary: _skyBlueAccent,
      onSecondary: Colors.white,
      tertiary: const Color(0xFF5BA3E0),
      surface: const Color(0xFFF0F7FC),
      onSurface: const Color(0xFF1A2B3D),
      onSurfaceVariant: const Color(0xFF546E84),
      outline: const Color(0xFFB8D4EA),
      surfaceContainerHighest: const Color(0xFFDCEDF8),
      surfaceContainerHigh: const Color(0xFFE4F1FA),
      surfaceContainer: const Color(0xFFEAF4FC),
      surfaceContainerLow: const Color(0xFFF0F7FC),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5FAFF),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shadowColor: const Color(0xFF4A90D9).withValues(alpha: 0.15),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Color(0xFFE8F4FD),
      foregroundColor: Color(0xFF1A2B3D),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFE8F4FD),
      indicatorColor: const Color(0xFFD0E8F9),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFE8F4FD),
      selectedItemColor: Color(0xFF2E7BC6),
      unselectedItemColor: Color(0xFF8BADC4),
    ),
    dividerColor: const Color(0xFFB8D4EA),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: const Color(0xFFE4F1FA),
      selectedColor: const Color(0xFFD0E8F9),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  /// Get theme by name string
  static ThemeData getThemeByName(String name) {
    switch (name) {
      case 'light':
        return lightTheme;
      case 'dark':
        return darkTheme;
      case 'skyBlue':
        return skyBlueTheme;
      default:
        return darkTheme;
    }
  }

  /// Check if a theme name represents a dark theme
  static bool isDarkTheme(String name) {
    return name == 'dark';
  }
}
