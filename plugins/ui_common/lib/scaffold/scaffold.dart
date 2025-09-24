part of ui_common;

class UICScaffold extends StatefulWidget{
  final Widget? appBar;
  final Widget? footer;
  final Widget? primaryBody;
  final Widget? secondaryBody;
  final Widget? drawer;
  final Widget? sidebar;
  final String initialRoute;
  final StatefulNavigationShell? navigationShell;

  UICScaffold({
    this.drawer,
    this.appBar,
    this.footer,
    this.sidebar,
    this.initialRoute = "/",
    super.key,
    this.primaryBody,
    this.secondaryBody,
    this.navigationShell,
  });

  @override
  State<UICScaffold> createState() => UICScaffoldState();

  static UICScaffoldState of(BuildContext context) {
    final result = context.findAncestorStateOfType<UICScaffoldState>();
    if(result == null) throw();
    return result;
  }
}

class UICScaffoldState extends State<UICScaffold> {
  late final mainController = UICApp.of(context);
  late final state          = GoRouterState.of(context);
  final _endDrawerNavigator = GlobalKey<NavigatorState>();
  final _contentNavigator   = GlobalKey<NavigatorState>();
  final _scaffoldKey        = GlobalKey<ScaffoldState>();
  bool _showDrawer          = true;
  bool _showSecondaryBody   = false;

  NavigatorState? get contentNavigator   => _contentNavigator.currentState;
  bool            get drawerVisible      => _showDrawer;

  Size _size = Size.zero;
  double _maxWidth = 0;
  double _maxHeight = 0;
  
  final _breakPointS  = 600;
  final _breakPointM  = 840;
  final _breakPointL  = 1200;
  final _breakPointXL = 1600;

  bool get breakPointS       => _maxWidth < _breakPointS;
  bool get breakPointM       => _maxWidth < _breakPointM && !breakPointS;
  bool get breakPointL       => _maxWidth < _breakPointL && !breakPointS && !breakPointM;
  bool get breakPointXL      => _maxWidth < _breakPointXL && !breakPointS && !breakPointM && !breakPointL;
  bool get breakPointMLXLXXL => !breakPointS;
  bool get breakPointLXLXXL  => !breakPointS && !breakPointM;
  bool get breakPointXLXXL   => !breakPointS && !breakPointM && !breakPointL;
  bool get breakPointXXL     => !breakPointS && !breakPointM && !breakPointL && !breakPointXL;

  bool get breakPointSM      => breakPointS || breakPointM;
  bool get breakPointML      => breakPointM || breakPointL;
  bool get breakPointSML     => breakPointS || breakPointM || breakPointL;
  bool get breakPointSMLXL   => breakPointS || breakPointM || breakPointL || breakPointXL;

  @override
  initState () {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.navigationShell?.goBranch(0, initialLocation: false);
    });
  }

  void openDrawer () {
    _showDrawer = true;
    _scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer () {
    _showDrawer = false;
    _scaffoldKey.currentState?.closeDrawer();
  }

  void showSecondaryBody () {
    _showSecondaryBody = true;
    widget.navigationShell?.goBranch(1, initialLocation: false);
  }

  void hideSecondaryBody () {
    _showSecondaryBody = false;
    widget.navigationShell?.goBranch(1, initialLocation: true);
    widget.navigationShell?.goBranch(0, initialLocation: false);
  }

  void activatePrimary () {
    _showSecondaryBody = false;
    widget.navigationShell?.goBranch(0, initialLocation: false);
  }

  void sendSecondaryToBackground () {
    setState(() {
      _showSecondaryBody = false;
    });
  }

  void goSecondary ({
    required String path,
    bool push = true,
  }) {
    final topRoute = GoRouterState.of(context).uri.toString();
    if(topRoute == path) return;
    showSecondaryBody();
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.sizeOf(context);
    _maxWidth = _size.width;
    _maxHeight = _size.height;
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: false,
      primary: false,
      drawerEnableOpenDragGesture: false, // theme.platform == TargetPlatform.iOS || theme.platform == TargetPlatform.android,
      resizeToAvoidBottomInset: false,
        
      drawer: widget.drawer != null && breakPointSML
        ? widget.drawer
        : null,
      
      body: Stack(
        children: [
          Row(
            children: [
    
              if(widget.drawer != null && breakPointL && widget.sidebar != null) widget.sidebar!,
    
              if(widget.drawer != null && (breakPointXLXXL || breakPointL && widget.sidebar == null)) SizedBox(
                width: 300,
                child: widget.drawer!,
              ),
    
              Expanded(
                child: widget.primaryBody ?? widget.navigationShell ?? Container()
              ),
    
              if(breakPointLXLXXL && widget.secondaryBody != null) _AnimatedSecondaryBody(
                secondaryBody: widget.secondaryBody,
                showSecondaryBody: _showSecondaryBody,
                maxWidth: 420,
                // maxWidth: breakPointSML ? 400 : 550,
                breakPointLXLXXL: breakPointLXLXXL,
              ),
            ],
          ),
          
          if(breakPointSM) Positioned(
            top: 0,
            left: 0,
            width: _maxWidth,
            bottom: 0,
            child: _AnimatedSecondaryBody(
              secondaryBody: widget.secondaryBody,
              showSecondaryBody: _showSecondaryBody,
              maxWidth: _maxWidth,
              breakPointLXLXXL: breakPointLXLXXL,
            ),
          ),
        ],
      ),
    
      bottomNavigationBar: breakPointLXLXXL ? null : widget.footer
    );
  }
}

class UICAppBar extends StatefulWidget {
  final String title;
  final Widget? ending;

  const UICAppBar({
    super.key,
    required this.title,
    this.ending
  });

  @override
  State<UICAppBar> createState() => _UICAppBarState();
}

class _UICAppBarState extends State<UICAppBar> {
  late final scaffolProvider = UICScaffold.of(context);

  final GlobalKey<TooltipState> tipViewMode  = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: Text(widget.title, style: theme.textTheme.titleLarge, overflow: TextOverflow.ellipsis),
        ),
        
        if(widget.ending != null) widget.ending!
      ],
    );
  }
}

class _AnimatedSecondaryBody extends StatelessWidget {
  final Widget? secondaryBody;
  final bool showSecondaryBody;
  final double maxWidth;
  final bool breakPointLXLXXL;

  const _AnimatedSecondaryBody({
    Key? key,
    required this.secondaryBody,
    required this.showSecondaryBody,
    required this.maxWidth,
    required this.breakPointLXLXXL,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.decelerate,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      child: showSecondaryBody
          ? SizedBox(
              key: ValueKey(true),
              width: maxWidth,
              child: secondaryBody!,
            )
          : SizedBox.shrink(key: ValueKey(false)),
    );
  }
}