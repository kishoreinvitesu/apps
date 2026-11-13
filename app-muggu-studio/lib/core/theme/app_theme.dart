import 'package:material_ui/material_ui.dart';

abstract final class MugguColors {
  static const deepMaroon = Color(0xFF862B37);
  static const warmCream = Color(0xFFFFF5E8);
  static const turmericGold = Color(0xFFD8A13B);
  static const leafGreen = Color(0xFF55775D);
  static const darkBrown = Color(0xFF3C342E);
  static const softRose = Color(0xFFF2E3DF);
}

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: MugguColors.deepMaroon,
          brightness: Brightness.light,
        ).copyWith(
          primary: MugguColors.deepMaroon,
          onPrimary: MugguColors.warmCream,
          secondary: MugguColors.turmericGold,
          onSecondary: MugguColors.darkBrown,
          tertiary: MugguColors.leafGreen,
          surface: MugguColors.warmCream,
          onSurface: MugguColors.darkBrown,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MugguColors.warmCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: MugguColors.warmCream,
        foregroundColor: MugguColors.darkBrown,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: MugguColors.warmCream,
        indicatorColor: MugguColors.softRose,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: MugguColors.darkBrown.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }
}
