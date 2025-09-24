part of ui_common;

@deprecated
class UICEndDrawer extends StatelessWidget {
  final String initialRoute;

  const UICEndDrawer({
    super.key,
    this.initialRoute = "/"
  });

  @override
  Widget build(BuildContext context) {
    final DrawerThemeData drawerTheme = DrawerTheme.of(context);
    final scaffoldController = UICScaffold.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool willPop, dynamic result) {
        if (scaffoldController._endDrawerNavigator.currentState?.canPop() == true) {
          scaffoldController._endDrawerNavigator.currentState?.pop(result);
        } else {
          scaffoldController.hideSecondaryBody();
        }
      },
      child: Navigator(
        key: scaffoldController._endDrawerNavigator,
        initialRoute: initialRoute,
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) => Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: drawerTheme.elevation ?? 2,
            shadowColor: drawerTheme.shadowColor ?? const Color.fromARGB(0, 46, 37, 37),
            surfaceTintColor: drawerTheme.surfaceTintColor ?? Theme.of(context).colorScheme.surfaceTint,
            child: Container()
          ),
        ),
      ),
    );
  }
}
