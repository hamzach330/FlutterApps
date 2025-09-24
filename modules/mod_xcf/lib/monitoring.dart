part of 'module.dart';

class XCFMonitorView extends StatefulWidget {
  static const path = '${XCFHome.path}/monitoring';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFMonitorView(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFMonitorView({super.key});

  @override
  State<XCFMonitorView> createState() => _XCFMonitorViewState();
}

class _XCFMonitorViewState extends State<XCFMonitorView> {
  @override
  initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return LayoutBuilder(
      builder: (context, constraints) {
        final xAxisCount = min(2, max(1, (constraints.maxWidth ~/ 450)));
        return UICPage(
          //title: "Schließgeschwindigkeitsüberwachung".i18n,
          //elevation: 0,
          //menu: true,
          slivers: [
            //Todo FIXME : Empty Header
            UICPinnedHeader(
              leading: UICTitle("Schließgeschwindigkeitsüberwachung".i18n)
            ),
            SliverUICDynamicHeightGridView.children(
              crossAxisCount: xAxisCount,
              dividers: true,
              children: [
                UICGridTile(
                  elevation: 0,
                  borderColor: Colors.transparent,
                  bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace  * 1),
                  // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
                  title: UICGridTileTitle(
                    backgroundColor: Colors.transparent,
                    title: Text("Automatische Kalibrierung".i18n, style: subtitle),
                  ),
        
        
                  body: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("Zulässige Überschreitung".i18n, textAlign: TextAlign.left)),
                          SizedBox(
                            width: 70,
                            child: UICTextInput(controller: TextEditingController(text: "25")),
                          ),
                          const UICSpacer(),
                          SizedBox(
                            width: 35,
                            child: Align(alignment: Alignment.centerRight, child: Text("%".i18n, style: theme.bodySmallMuted))
                          ),
                        ]
                      ),

                      const UICSpacer(),

                      UICBigMove(
                        onUp: () {},
                        onStop: () {},
                        onDown: () {},
                      ),
                    ],
                  )
                ),
                UICGridTile(
                  elevation: 0,
                  borderColor: Colors.transparent,
                  bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace  * 1),
                  // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
                  title: UICGridTileTitle(
                    backgroundColor: Colors.transparent,
                    title: Text("Expertenmodus".i18n, style: subtitle),
                  ),
                  body: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("Behanghöhe".i18n, textAlign: TextAlign.left)),
                          SizedBox(
                            width: 70,
                            child: UICTextInput(controller: TextEditingController(text: "25")),
                          ),
                          const UICSpacer(),
                          SizedBox(
                            width: 70,
                            child: Align(alignment: Alignment.centerRight, child: Text("mm".i18n, style: theme.bodySmallMuted))
                          ),
                        ]
                      ),
                      
                      const UICSpacer(),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("Wickelwellen-Ø".i18n, textAlign: TextAlign.left)),
                          SizedBox(
                            width: 70,
                            child: UICTextInput(controller: TextEditingController(text: "90")),
                          ),
                          const UICSpacer(),
                          SizedBox(
                            width: 70,
                            child: Align(alignment: Alignment.centerRight, child: Text("mm".i18n, style: theme.bodySmallMuted))
                          ),
                        ]
                      ),
                      
                      const UICSpacer(),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("Behangstärke".i18n, textAlign: TextAlign.left)),
                          SizedBox(
                            width: 70,
                            child: UICTextInput(controller: TextEditingController(text: "0,8")),
                          ),
                          const UICSpacer(),
                          SizedBox(
                            width: 70,
                            child: Align(alignment: Alignment.centerRight, child: Text("mm".i18n, style: theme.bodySmallMuted))
                          ),
                        ]
                      ),
        
                      const UICSpacer(),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("Abrollgeschwindigkeit".i18n, textAlign: TextAlign.left)),
                          SizedBox(
                            width: 70,
                            child: UICTextInput(controller: TextEditingController(text: "0,1")),
                          ),
                          const UICSpacer(),
                          SizedBox(
                            width: 70,
                            child: Align(alignment: Alignment.centerRight, child: Text("m/s".i18n, style: theme.bodySmallMuted))
                          ),
                        ]
                      ),
        
                      const UICSpacer(),

                      Row(
                        children: [
                          Expanded(
                            child: Container(),
                          ),
                      
                          UICElevatedButton(
                            onPressed: () async {
                              late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);
                              await xcf.calibrate();
                            },
                            leading: const Icon(Icons.compass_calibration_rounded),
                            child: Text("Kalibrieren".i18n),
                          )
                        ]
                      ),

                      const UICSpacer(),
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(child: Text("Grenzwert".i18n, textAlign: TextAlign.left)),
                          SizedBox(
                            width: 70,
                            child: UICTextInput(controller: TextEditingController(text: "0,1")),
                          ),
                          const UICSpacer(),
                          SizedBox(
                            width: 70,
                            child: Align(alignment: Alignment.centerRight, child: Text("m/s".i18n, style: theme.bodySmallMuted))
                          ),
                        ]
                      ),
                    ],
                  )
                ),
              ]
            ),
          ]
        );
      }
    );
  }
}
