import 'package:flutter/cupertino.dart';

class HomeNavigatorObserver extends NavigatorObserver {
  static String currentRoute = '';

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute = route.settings.name ?? '';
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute = previousRoute?.settings.name ?? '';
  }
}
