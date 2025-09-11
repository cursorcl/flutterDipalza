// lib/theme/app_colors_widget.dart

import 'package:flutter/material.dart';
import 'app_color_scheme.dart';

/// Widget para proporcionar acceso a los colores corporativos
/// en toda la aplicación usando InheritedWidget
class AppColors extends InheritedWidget {
  final AppColorScheme colorScheme;

  const AppColors({
    Key? key,
    required this.colorScheme,
    required Widget child,
  }) : super(key: key, child: child);

  /// Método para acceder a los colores desde cualquier widget
  ///
  /// Uso: final colors = AppColors.of(context);
  static AppColorScheme of(BuildContext context) {
    final AppColors? result = context.dependOnInheritedWidgetOfExactType<AppColors>();
    assert(result != null, 'No AppColors found in context');
    return result!.colorScheme;
  }

  /// Método opcional para acceso sin dependencia (no se reconstruye)
  ///
  /// Uso: final colors = AppColors.read(context);
  static AppColorScheme read(BuildContext context) {
    final AppColors? result = context.getInheritedWidgetOfExactType<AppColors>();
    assert(result != null, 'No AppColors found in context');
    return result!.colorScheme;
  }

  @override
  bool updateShouldNotify(AppColors oldWidget) {
    return colorScheme != oldWidget.colorScheme;
  }
}

/// Extension para acceso más fácil desde BuildContext
extension AppColorsExtension on BuildContext {
  /// Acceso directo a los colores corporativos
  ///
  /// Uso: context.appColors.iconHome
  AppColorScheme get appColors => AppColors.of(this);

  /// Acceso de solo lectura (no se reconstruye)
  ///
  /// Uso: context.readAppColors.iconHome
  AppColorScheme get readAppColors => AppColors.read(this);
}