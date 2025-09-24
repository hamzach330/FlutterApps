part of ui_common;

class UICNavigationObserver extends NavigatorObserver {
  final GlobalKey<NavigatorState> navigatorKey;
  final Function(GlobalKey<NavigatorState>, Route<dynamic>?, Route<dynamic>?)? onReplace;
  final Function(GlobalKey<NavigatorState>, Route<dynamic>, Route<dynamic>?)?  onPush;
  final Function(GlobalKey<NavigatorState>, Route<dynamic>, Route<dynamic>?)?  onPop;

  UICNavigationObserver({
    required this.navigatorKey,
    this.onReplace,
    this.onPush,
    this.onPop
  });

  @override
  void didReplace({ Route<dynamic>? newRoute, Route<dynamic>? oldRoute }) {
    if(onReplace != null) onReplace!(navigatorKey, newRoute, oldRoute);
  }

  @override
  void didPush (Route<dynamic> route, Route<dynamic>? previousRoute) {
    if(onPush != null) onPush!(navigatorKey, route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> previousRoute, Route<dynamic>? route) {
    if(onPop != null) onPop!(navigatorKey, previousRoute, route);
  }
}