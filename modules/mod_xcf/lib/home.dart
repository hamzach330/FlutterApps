part of 'module.dart';

class XCFHome extends StatefulWidget {
  static const path = '/xcf';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFHome(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFHome({super.key});

  @override
  State<XCFHome> createState() => _XCFHomeState();
}

class _XCFHomeState extends State<XCFHome> {


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyMediumMuted = theme.bodyMediumMuted;

    return Container();

    // return UICScaffold(
    //   initialRoute: XCFSetupWizard.route,
    // );
  }
}
