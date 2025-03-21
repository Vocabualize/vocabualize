import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabualize/config/themes/dark_palette.dart';
import 'package:vocabualize/config/themes/light_palette.dart';
import 'package:vocabualize/src/common/domain/extensions/iterable_extensions.dart';

class ThemeConfig {
  static ThemeData light(BuildContext context) {
    return _theme(
      context,
      LightPalette.primary,
      LightPalette.onPrimay,
      LightPalette.secondary,
      LightPalette.onSecondary,
      LightPalette.background,
      LightPalette.onBackground,
      LightPalette.surface,
      LightPalette.onSurface,
      LightPalette.hint,
      LightPalette.border,
      LightPalette.error,
    );
  }

  static ThemeData dark(BuildContext context) {
    return _theme(
      context,
      DarkPalette.primary,
      DarkPalette.onPrimary,
      DarkPalette.secondary,
      DarkPalette.onSecondary,
      DarkPalette.background,
      DarkPalette.onBackground,
      DarkPalette.surface,
      DarkPalette.onSurface,
      DarkPalette.hint,
      DarkPalette.border,
      DarkPalette.error,
    );
  }

  static ThemeData _theme(
      BuildContext context,
      Color primary,
      Color onPrimary,
      Color secondary,
      Color onSecondary,
      Color background,
      Color onBackground,
      Color surface,
      Color onSurface,
      Color hint,
      Color border,
      Color error) {
    //
    return ThemeData(
      //
      ///* Page transistions to support predictive back gestures
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      //
      ///* Colors
      primaryColor: primary,
      //primarySwatch: customSwatch(primaryColor.value),
      //accentColor: secondaryColor,
      focusColor: secondary,
      cardColor: surface,
      canvasColor: surface,
      disabledColor: secondary.withOpacity(0.2),
      //backgroundColor: background,
      scaffoldBackgroundColor: background,
      //errorColor: error,
      hintColor: hint,
      dividerColor: hint,
      //buttonColor: secondaryColor,
      hoverColor: primary,
      indicatorColor: secondary,
      //bottomAppBarColor: primary,
      dialogBackgroundColor: surface,

      ///* ColorScheme
      colorScheme: ColorScheme(
        primary: primary,
        //primaryVariant: borderColor,
        onPrimary: onPrimary,
        secondary: secondary,
        //secondaryVariant: secondaryColor,
        onSecondary: onSecondary,
        surface: surface,
        onSurface: onSurface,
        background: background,
        onBackground: onBackground,
        error: error,
        onError: onPrimary,
        brightness: Brightness.light,
      ),

      splashColor: surface.withOpacity(0.5),

      visualDensity: VisualDensity.adaptivePlatformDensity,

      useMaterial3: true,

      ///* AppBar
      appBarTheme: AppBarTheme(color: background, elevation: 0, centerTitle: true),

      ///* Switch
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected) ? primary : surface),
        thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected) ? onPrimary : onSurface),
      ),

      ///* Icons
      iconTheme: IconThemeData(color: onBackground),

      ///* ListTile
      //listTileTheme: ListTileThemeData(iconColor: onBackground, selectedTileColor: surface, textColor: hint),

      ///* ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return onPrimary.withOpacity(0.6);
            }
            if (states.containsAny([
              WidgetState.pressed,
              WidgetState.hovered,
            ])) {
              return onPrimary.withOpacity(0.6);
            }
            return onPrimary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return hint;
            }
            if (states.containsAny([
              WidgetState.pressed,
              WidgetState.hovered,
            ])) {
              return primary.withOpacity(0.6);
            }
            return primary;
          }),
          padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(32, 12, 32, 12)),
          textStyle: WidgetStateProperty.all<TextStyle>(
            GoogleFonts.poppins(
              color: onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: WidgetStateProperty.all<double>(0),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),

      ///* OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color>((state) {
            return state.contains(WidgetState.disabled) ? hint : onSurface;
          }),
          padding: WidgetStateProperty.all<EdgeInsets>(const EdgeInsets.fromLTRB(32, 12, 32, 12)),
          textStyle: WidgetStateProperty.resolveWith<TextStyle>((state) {
            final color = state.contains(WidgetState.disabled) ? hint : onSurface;
            return GoogleFonts.poppins(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            );
          }),
          elevation: WidgetStateProperty.all<double>(0),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ).copyWith(
          side: WidgetStateProperty.resolveWith<BorderSide>((state) {
            if (state.contains(WidgetState.disabled)) {
              return BorderSide(width: 2, color: hint);
            }
            return BorderSide(width: 2, color: primary);
          }),
        ),
      ),

      ///* Dialog
      dialogTheme: DialogTheme(
        elevation: 8,
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      ///* Text-Themes
      textTheme: TextTheme(
        titleSmall: GoogleFonts.poppins(color: Colors.blue[300]),
        titleMedium: GoogleFonts.poppins(
          color: onBackground, // color: onPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          color: onBackground, // color: onPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        // e.g. Card info, practice progress
        displaySmall: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 12,
        ),
        // e.g. practice source and target
        displayMedium: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 16,
          height: 1.5,
        ),
        displayLarge: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodySmall: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 12,
          height: 1.5,
        ),
        // e.g. ListTile subtitle
        bodyMedium: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 16,
          height: 1.5,
        ),
        // e.g. TextField
        bodyLarge: GoogleFonts.poppins(
          color: onBackground,
          fontSize: 16,
        ),
        labelSmall: GoogleFonts.poppins(
          color: onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: GoogleFonts.poppins(
          color: onPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        labelLarge: GoogleFonts.poppins(
          color: onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),

      ///* TextField-Themes etc.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: hint,
        selectionHandleColor: primary.withOpacity(0.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: hint),
        labelStyle: TextStyle(color: onBackground),
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: false,
        contentPadding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: onBackground, width: 2),
            borderRadius: BorderRadius.circular(16)),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hint, width: 2), borderRadius: BorderRadius.circular(16)),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: onBackground, width: 2),
            borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primary, width: 2),
            borderRadius: BorderRadius.circular(16)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: error, width: 2),
            borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ///* Color to ColorSwatch
  customSwatch(color) {
    return MaterialColor(
      color,
      <int, Color>{
        50: Color(color),
        100: Color(color),
        200: Color(color),
        300: Color(color),
        400: Color(color),
        500: Color(color),
        600: Color(color),
        700: Color(color),
        800: Color(color),
        900: Color(color),
      },
    );
  }
}
