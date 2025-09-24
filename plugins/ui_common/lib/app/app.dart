part of ui_common;

abstract class UICModule {
  GlobalKey<NavigatorState>? navigatorState;
  List<RouteBase> get routes;
  Provider get provider;
}


class UICApp extends StatefulWidget with WidgetsBindingObserver {
  final List<Locale> supportedLocales;
  final String appTitle;

  final List<SingleChildStatelessWidget> _providers;
  final List<RouteBase> routes;
  final Map<String, RouteBuilderDef> endDrawerRoutes;
  final Map<String, RouteBuilderDef> contentRoutes;
  final List<UICModule> modules;
  /// Called one frame after app initialization.
  /// Context of the root navigator, meaning you can access all app-wide state.
  final Future<void> Function(BuildContext) postInit;

  const UICApp({
    required this.supportedLocales,
    required this.appTitle,
    required List<SingleChildStatelessWidget> providers,
    required this.routes,
    required this.endDrawerRoutes,
    required this.contentRoutes,
    required this.modules,
    required this.postInit,
  }) : _providers = providers;

  @override
  State<UICApp> createState() => UICAppState();

  static UICAppState of (BuildContext context) {
    final result = context.findAncestorStateOfType<UICAppState>();
    if(result == null) throw("UICAppState not found");
    return result;
  }
}


class UICAppState extends State<UICApp> {
  List<SingleChildStatelessWidget> _providers = [];
  List<RouteBase> _routes = [];

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: '_rootNavigatorKey');

  NavigatorState? get navigator => _rootNavigatorKey.currentState;

  @override
  initState() {
    super.initState();
    _providers = widget._providers;
    _routes = widget.routes;

    for(final module in widget.modules) {
      _providers.add(module.provider);
      _routes.addAll(module.routes);
      module.navigatorState = _rootNavigatorKey;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.postInit(_rootNavigatorKey.currentContext!);
    });
  }

  late final _router = GoRouter(
    initialLocation: "/",
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        builder: (context, state, navShell) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              _rootNavigatorKey.currentContext?.go("/");
            },
            child: UICScaffold(
              primaryBody: navShell,
            ),
          );
        },
        routes: _routes,
      ),
    ]
  );

  @override
  Widget build(BuildContext context) {
    return I18n(
      autoSaveLocale: true,
      initialLocale: I18n.locale,
      supportedLocales: widget.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: PossiblyEmptyMultiProvider(
        providers: _providers,
        builder: (context) => UICMessenger(
          child: MaterialApp.router(
            locale: I18n.locale,
            localizationsDelegates: I18n.localizationsDelegates,
            routerConfig: _router,
            supportedLocales: widget.supportedLocales,
            title: "Becker Tool",
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
          ),
        ),
      ),
    );
  }
}

class PossiblyEmptyMultiProvider extends StatelessWidget {
  final List<SingleChildStatelessWidget> providers;
  final Widget Function(BuildContext) builder;

  PossiblyEmptyMultiProvider({
    super.key,
    required this.providers,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if(providers.isEmpty) {
      return builder(context);
    } else {
      return MultiProvider(
        providers: providers,
        builder: (context, _) => builder(context),
      );
    }
  }
}
