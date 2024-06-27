import 'package:flutter/material.dart';

class AppTheme {
  // Define colors
  static const Color lightBackground = Color(0xFFE6E6FA);
  static const Color successColor = Color(0xFF9FD356);
  static const Color alertColor = Color(0xFFE6E600);
  static const Color infoColor = Color(0xFF3C91E6);
  static const Color dangerColor = Color(0xFFBA2D0B);
  static const Color accentColor = Color(0xFFC76634);
  static const Color primaryColor = Color(0xFF3F2E56);

  // Define text styles
  static const TextStyle textSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle textSmallBold = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textSmallUnderlined = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    height: 1.5,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.underline,
  );

  static const TextStyle textMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle textBold = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle textUnderlinedBold = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    height: 1.5,
    fontWeight: FontWeight.w600,
    decoration: TextDecoration.underline,
  );

  static const TextStyle textInputs = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 23.0,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 26.0,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleBig = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 29.0,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleDeco = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 32.0,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Playfair Display',
    fontSize: 55.0,
    height: 1.27,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 44.0,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 35.0,
    height: 1.34,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28.0,
    height: 1.3,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 21.0,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    height: 1.28,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 35.0,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    textTheme: const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        disabledForegroundColor: Colors.grey,
        disabledBackgroundColor: Colors.grey[300],
        shadowColor: Colors.black,
        surfaceTintColor: lightBackground,
        overlayColor: primaryColor.withOpacity(0.1),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: lightBackground,
      border: OutlineInputBorder(),
    ),
  );
}
