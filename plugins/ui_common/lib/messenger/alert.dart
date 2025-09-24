part of ui_common;

Future<T> _uicAlert<T>(UICAlert alert, BuildContext context) async {
  final theme = Theme.of(context);

  if(alert.useMaterial == false && (theme.platform == TargetPlatform.iOS || theme.platform == TargetPlatform.macOS)) {
    return await showCupertinoDialog(
      barrierDismissible: alert.dismissable,
      context: context,
      builder: (_) {
        return PopScope(
          canPop: alert.dismissable,
          child: _UICCupertinoAlert(alert: alert),
        );
      }
    );
  } else {
    return await showDialog(
      barrierDismissible: alert.dismissable,
      context: context,
      builder: (_) {
        if(alert.blank) return alert;
        return PopScope(
          canPop: alert.dismissable,
          child: _UICMaterialAlert(alert: alert),
        );
      }
    );
  }
}

class _UICCupertinoAlert extends StatelessWidget {
  final UICAlert alert;

  const _UICCupertinoAlert({
    required this.alert
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoAlertDialog(
      title: Padding(
        padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
        child: Text(alert.title, textAlign: TextAlign.center),
      ),
      content: SingleChildScrollView(
        child: alert
      ),
      actions: alert.actions
    );
  }
}

class _UICMaterialAlert extends StatelessWidget {
  final UICAlert alert;

  const _UICMaterialAlert({
    required this.alert
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        margin: EdgeInsets.all(theme.defaultWhiteSpace * 2),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
        color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
      
        width: alert.materialWidth,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: theme.brightness == Brightness.light
              ? alert.getBackgroundColor(context).withValues(alpha: .7)
              : alert.getBackgroundColor(context).withValues(alpha: .7),
            elevation: alert.elevation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(theme.defaultWhiteSpace * 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(alert.title,
                          textAlign: alert.closeAction != null
                            ? TextAlign.left
                            : TextAlign.center,
                          style: theme.textTheme.titleMedium
                        )
                      ),
                      if(alert.closeAction != null) IconButtonTheme(
                        data: IconButtonThemeData(
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              theme.brightness == Brightness.light
                              ? Colors.white.withValues(alpha: .2)
                              : Colors.black.withValues(alpha: .2)
                            )
                          )
                        ),
                        child: IconButton(
                          onPressed: alert.closeAction!,
                          icon: Icon(Icons.close_rounded)
                        ),
                      )
                    ],
                  ),
                ),
            
                Flexible(
                  child: DefaultTextStyle.merge(
                    textAlign: TextAlign.center, // TextAlign.center,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 2),
                        child: alert,
                      )
                    ),
                  ),
                ),
            
                Padding(
                  padding: EdgeInsets.all(theme.defaultWhiteSpace * 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // children: [
                    //   ElevatedButton(onPressed: () {
                    //     print("test");
                    //   }, child: Container(child: Text("test")))
                    // ],
                    children: [
                      for(final action in alert.actions)
                        if(action != alert.actions.last) Row(
                          children: [
                            action,
                            UICSpacer(),
                          ],
                        )
                        else action
                      ]
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

abstract class UICAlert<T> extends StatelessWidget {
  UICMessengerState? get _messenger => UICMessenger.of(UICAppState._rootNavigatorKey.currentContext!);

  String    get title;
  double?   get materialWidth => 300;
  bool      get dismissable   => false;
  bool      get useMaterial   => false;
  bool      get abortable     => true;
  String    get buttonText    => 'Ok'.i18n;
  List<Widget> get actions    => [];
  bool      get backdrop      => false; /// Material only
  double    get elevation     => 8;
  Function()? get closeAction => null;
  bool      get blank         => false;
  
  Color getBackgroundColor (context) => Theme.of(context).colorScheme.surface;

  RoundedRectangleBorder get shape => RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0))
  );

  UICAlert({super.key});

  void pop ([T? value]) => _messenger?.pop<T?>(value);

}

class UICSimpleAlert extends UICAlert<void> {
  @override
  get title => _title;

  @override
  get useMaterial => _useMaterial;

  @override
  get actions => [
    UICAlertAction(
      text: "Ok".i18n,
      onPressed: pop,
    )
  ];

  final Widget child;
  final String _title;
  final bool _useMaterial;

  UICSimpleAlert({
    super.key,
    required this.child,
    required String title,
    bool useMaterial = false
  }): _title = title, _useMaterial = useMaterial;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class UICSimpleOkAlert extends UICAlert<bool> {
  @override
  get title => _title;

  @override
  get actions => [
    UICAlertAction(
      text: "Ok".i18n,
      onPressed: () => pop(true),
    )
  ];

  final Widget child;
  final String _title;

  UICSimpleOkAlert({
    super.key,
    required this.child,
    required String title
  }): _title = title;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class UICSimpleQuestionAlert extends UICAlert<bool> {
  @override
  get title => _title;

  @override
  get actions => [
    UICAlertAction(
      text: "Nein".i18n,
      onPressed: () => pop(false),
      isDestructiveAction: true
    ),
    UICAlertAction(
      text: "Ja".i18n,
      onPressed: () => pop(true),
    )
  ];

  final Widget child;
  final String _title;

  UICSimpleQuestionAlert({
    super.key,
    required this.child,
    required String title
  }): _title = title;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class UICSimpleConfirmationAlert extends UICAlert<bool> {
  @override
  get title => _title;

  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      onPressed: () => pop(false),
      isDestructiveAction: true
    ),
    UICAlertAction(
      text: "Ok".i18n,
      onPressed: () => pop(true)
    )
  ];

  final Widget child;
  final String _title;

  UICSimpleConfirmationAlert({
    super.key,
    required this.child,
    required String title
  }): _title = title;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class UICSimpleProceedAlert extends UICAlert<bool> {
  @override
  get title => _title;

  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      onPressed: () => pop(false),
      isDestructiveAction: true
    ),
    UICAlertAction(
      text: "Weiter".i18n,
      onPressed: () => pop(true)
    )
  ];

  final Widget child;
  final String _title;

  UICSimpleProceedAlert({
    super.key,
    required this.child,
    required String title
  }): _title = title;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class UICBarrierAlert extends UICAlert<void> {
  final bool _abortable;
  final OverlayEntry? entry;
  final Function()? onAbort;

  @override
  get title => _title;

  @override
  get abortable => _abortable;

  final String _title;
  final Widget child;

  @override
  get materialWidth => 220;

  @override
  get actions => [
    if(abortable) SizedBox(
      width: 160,
      child: UICAlertAction(
        isDestructiveAction: true,
        text: "Abbrechen".i18n,
        onPressed: () {
          onAbort?.call();
        }
      ),
    )
  ];

  // @override
  // get closeAction => () {
  //   onAbort?.call();
  // };

  UICBarrierAlert({
    super.key,
    required String title,
    required this.child,
    bool abortable = false,
    this.entry,
    this.onAbort
  }): _title = title, _abortable = abortable;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: const Center(
            child: UICProgressIndicator(),
          ),
        ),
        child
      ]),
    );
  }
}

/// A dialog that allows the user to select a time.
class UICTimePickerAlert extends UICAlert<DateTime> {
  final List<DateTime> _time;

  @override
  get dismissable => true;

  UICTimePickerAlert({
    super.key,
    required DateTime time,
  }) : _time = [time];

  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      onPressed: () => pop(null),
      isDestructiveAction: true
    ),
    UICAlertAction(
      text: "Fertig".i18n,
      onPressed: () => pop(_time.last)
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      child: CupertinoDatePicker(
        initialDateTime: _time.first,
        mode: CupertinoDatePickerMode.time,
        onDateTimeChanged: (DateTime newDateTime) {
          _time.add(newDateTime);
        },
        use24hFormat: true,
        minuteInterval: 1,
      ),
    );
  }

  @override
  String get title => "Schaltzeit wählen".i18n;
}


class UICMaterialTimePickerAlert extends UICAlert<TimeOfDay> {

  final DateTime time;

  @override
  get dismissable => true;

  @override
  get blank => true;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 600;

  UICMaterialTimePickerAlert({
    super.key,
    required this.time,
  });

  // @override
  // get actions => [
  //   UICAlertAction(
  //     text: "Abbrechen".i18n,
  //     onPressed: () => pop(null),
  //     isDestructiveAction: true
  //   ),
  //   // UICAlertAction(
  //   //   text: "Fertig".i18n,
  //   //   onPressed: () => pop(time)
  //   // )
  // ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 600,
      child: TimePickerDialog(
        initialTime: TimeOfDay.fromDateTime(time),
      ),
    );
  }

  @override
  String get title => "Schaltzeit wählen".i18n;


}
