// lib/theme/app_color_scheme.dart

import 'package:flutter/material.dart';

class AppColorScheme {
  // COLORES ESTÁNDAR (de Material Design)
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;
  final Color background;
  final Color onBackground;
  final Color error;
  final Color onError;

  // TUS COLORES CORPORATIVOS
  final Color iconHome;
  final Color rojoBase;
  final Color verdeBase;

  // CONSTRUCTOR
  const AppColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
    required this.background,
    required this.onBackground,
    required this.error,
    required this.onError,
    required this.iconHome,
    required this.rojoBase,
    required this.verdeBase,
  });

  // COLORES CORPORATIVOS CONSTANTES
  static const Color _iconHomeColor = Color(0xFF1464F6);
  static const Color _rojoBaseColor = Color(0xFFF44336);
  static const Color _verdeBaseColor = Color(0xFF004300);

  // ✅ TU PROPIO fromSeed!
  factory AppColorScheme.fromSeed({
    required Color seedColor,
    required Brightness brightness,
  }) {
    // Generar ColorScheme base
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return AppColorScheme(
      // Colores estándar del ColorScheme base
      primary: baseColorScheme.primary,
      onPrimary: baseColorScheme.onPrimary,
      secondary: baseColorScheme.secondary,
      onSecondary: baseColorScheme.onSecondary,
      surface: baseColorScheme.surface,
      onSurface: baseColorScheme.onSurface,
      background: baseColorScheme.background,
      onBackground: baseColorScheme.onBackground,
      error: baseColorScheme.error,
      onError: baseColorScheme.onError,

      // TUS COLORES CORPORATIVOS (fijos)
      iconHome: _iconHomeColor,
      rojoBase: _rojoBaseColor,
      verdeBase: _verdeBaseColor,
    );
  }

  // Factory para tema oscuro
  factory AppColorScheme.fromSeedDark({
    required Color seedColor,
  }) {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return AppColorScheme(
      primary: baseColorScheme.primary,
      onPrimary: baseColorScheme.onPrimary,
      secondary: baseColorScheme.secondary,
      onSecondary: baseColorScheme.onSecondary,
      surface: baseColorScheme.surface,
      onSurface: baseColorScheme.onSurface,
      background: baseColorScheme.background,
      onBackground: baseColorScheme.onBackground,
      error: baseColorScheme.error,
      onError: baseColorScheme.onError,

      // Colores corporativos (adaptados para tema oscuro si necesitas)
      iconHome: _iconHomeColor,
      rojoBase: _rojoBaseColor,
      verdeBase: _verdeBaseColor,
    );
  }

  // Método para convertir a ColorScheme estándar (para ThemeData)
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      background: background,
      onBackground: onBackground,
      error: error,
      onError: onError,
    );
  }

  // VARIANTES ÚTILES
  Color get iconHomeLight => iconHome.withOpacity(0.1);
  Color get iconHomeDark => iconHome.withOpacity(0.8);

  Color get rojoBaseLight => rojoBase.withOpacity(0.1);
  Color get rojoBaseDark => rojoBase.withOpacity(0.8);

  Color get verdeBaseLight => verdeBase.withOpacity(0.1);
  Color get verdeBaseDark => verdeBase.withOpacity(0.8);

  // COLORES PREDEFINIDOS ÚTILES
  static const Color naranjaCorporativo = Color(0xFFFF9F00);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color grisOscuro = Color(0xFF424242);
}