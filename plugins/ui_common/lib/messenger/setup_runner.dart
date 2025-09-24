part of ui_common;

abstract class UICSetupRunnerData {
  Widget Function(String, dynamic) step;
  final String title;
  final List<SingleChildStatelessWidget> providers;

  UICSetupRunnerData({
    required this.step,
    required this.title,
    required this.providers,
  });
}

class UICSetupRunnerAlert<T extends UICSetupRunnerData> extends UICAlert<T> {
  final T setupData;
  final bool _dismissable;

  UICSetupRunnerAlert({
    super.key,
    required this.setupData,
    dismissable = false,
  }): _dismissable = dismissable;

  @override
  get dismissable => _dismissable;  

  @override
  get title => setupData.title;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 460;

  @override
  get backdrop => true;

  @override
  Widget build(BuildContext context) {
    return UICSetupRunner<T>(
      setupData: setupData,
    );
  }
}

class UICSetupRunner<T extends UICSetupRunnerData> extends StatefulWidget {
  final T setupData;

  const UICSetupRunner({
    required this.setupData,
  });

  @override
  State<UICSetupRunner> createState() => _UICSetupRunnerState();
}

class _UICSetupRunnerState<T extends UICSetupRunnerData> extends State<UICSetupRunner> {
  @override
  Widget build (BuildContext context) {
    return MultiProvider(
      providers: widget.setupData.providers,
      builder: (context, _) {
        return Navigator(
          onGenerateRoute: (RouteSettings settings) {
            return SlidingPageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => widget.setupData.step(settings.name ?? "", widget.setupData),
              settings: settings
            );
          },
        );
      }
    );
  }
}