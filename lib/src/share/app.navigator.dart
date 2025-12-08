import 'package:flutter/cupertino.dart';
import '../page/home/home2.page.dart';
import 'app_routes.dart';

class AppNavigator {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static Future<T?> pushReplacementNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, T>(routeName, arguments: arguments);
  }

  // Método especial para navegación global (login)
  static void logout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}