part of 'module.dart';

class XCFMaintenanceView extends StatefulWidget {
  static const path = '${XCFHome.path}/maintenance';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFMaintenanceView(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFMaintenanceView({super.key});

  @override
  State<XCFMaintenanceView> createState() => _XCFMaintenanceViewState();
}

class _XCFMaintenanceViewState extends State<XCFMaintenanceView> {
  late final XCFProtocol xcf = Provider.of<XCFProtocol>(context, listen: false);
  late final messenger = UICMessenger.of(context);

  final maintenanceIntervalTextController = TextEditingController(text: "12");
  final nextMaintenanceTextController = TextEditingController(text: "8");
  final operationHoursTextController = TextEditingController(text: "8");
  final operationCyclesTextController = TextEditingController(text: "8");
  

  List<XCFFault>? faults;
  bool loading = true;



  @override
  initState() {
    super.initState();
    unawaited(asyncInit());
  }  

  asyncInit() async {
    await xcf.getBusVersion();
    await xcf.getVersion();
    await xcf.getName();
    await xcf.getLevel();
  }

  // Future<void> loadParameters () async {
  //   setState(() {
  //     parameters.clear();
  //     loading = true;
  //   });

  //   final parametersTable = jsonDecode(await DefaultAssetBundle.of(context).loadString("assets/xcf/xcf_parameters.json"))
  //     .firstWhere((p) => p["type"] == "table")["data"]
  //     .map((p) => XCFParameterInfo.fromJson(p)).toList()?.cast<XCFParameterInfo>();
    
  //   final params = await xcf.getAllParameters(parametersTable,
  //     userRole: XCFUserType.Torhersteller,
  //   );

  //   setState(() {
  //     parameters = params;
  //     loading = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);
    return Consumer<XCFProtocol>(
      builder: (context, xcf, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final xAxisCount = min(2, max(1, (constraints.maxWidth ~/ 450)));
            return UICPage(
              //pop: () => context.pop(),
              //title: "Wartung".i18n,
              //elevation: 0,
              //menu: true,
              slivers: [
                //Todo FIXME : Empty Header
              UICPinnedHeader(
                leading: UICTitle("Wartung".i18n),
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
                        title: Text("Wartungsintervall".i18n, style: subtitle),
                      ),
        
        
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Wartungsintervall".i18n, textAlign: TextAlign.left)),
                              SizedBox(
                                width: 70,
                                child: UICTextInput(controller: maintenanceIntervalTextController),
                              ),
                              const UICSpacer(),
                              SizedBox(
                                width: 70,
                                child: Align(alignment: Alignment.centerRight, child: Text("Monate".i18n, style: theme.bodySmallMuted))
                              ),
                            ]
                          ),
                          
                          const UICSpacer(),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Verbleibend".i18n, textAlign: TextAlign.left)),
                              SizedBox(
                                width: 70,
                                child: UICTextInput(controller: nextMaintenanceTextController),
                              ),
                              const UICSpacer(),
                              SizedBox(
                                width: 70,
                                child: Align(alignment: Alignment.centerRight, child: Text("Monate".i18n, style: theme.bodySmallMuted))
                              ),
                            ]
                          ),
                          
                          const UICSpacer(),
            
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Betriebsstunden".i18n, textAlign: TextAlign.left)),
                              SizedBox(
                                width: 70,
                                child: UICTextInput(controller: operationHoursTextController),
                              ),
                              const UICSpacer(),
                              SizedBox(
                                width: 70,
                                child: Align(alignment: Alignment.centerRight, child: Text("Stunden".i18n, style: theme.bodySmallMuted))
                              ),
                            ]
                          ),
            
                          const UICSpacer(),
            
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Zyklen".i18n, textAlign: TextAlign.left)),
                              SizedBox(
                                width: 70,
                                child: UICTextInput(controller: operationCyclesTextController),
                              ),
                              const UICSpacer(),
                              SizedBox(
                                width: 70,
                                child: Align(alignment: Alignment.centerRight, child: Text("St".i18n, style: theme.bodySmallMuted))
                              ),
                            ]
                          ),
            
                          const UICSpacer(),
                          
                          const Divider(),
        
                          const UICSpacer(),
        
                          UICElevatedButton(
                            onPressed: () async {
                              final result = await UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
                                title: "Wartungsintervall zurücksetzen".i18n,
                                child: Text("Sind Sie sicher, dass Sie das Wartungsintervall zurücksetzen möchten?".i18n),
                              ));

                              if(result == true) {

                              }
                            },
                            leading: const Icon(Icons.restore_rounded),
                            child: Text("Wartungsintervall zurücksetzen".i18n)
                          ),
                          
                          const UICSpacer(),
        
                          UICElevatedButton(
                            onPressed: () async {
                              final result = await UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
                                title: "Zyklen zurücksetzen".i18n,
                                child: Text("Sind Sie sicher, dass Sie den Zyklenzähler zurücksetzen möchten?".i18n),
                              ));

                              if(result == true) {

                              }
                            },
                            leading: const Icon(Icons.restore_rounded),
                            child: Text("Zyklen zurücksetzen".i18n)
                          ),
                        ],
                      ),
                    ),
                    
                    UICGridTile(
                      elevation: 0,
                      borderColor: Colors.transparent,
                      bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace  * 1),
                      // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
                      title: UICGridTileTitle(
                        backgroundColor: Colors.transparent,
                        title: Text("Wartung durchführen".i18n, style: subtitle),
                      ),
                      body: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Messung Schließgeschwindigkeit".i18n, textAlign: TextAlign.left)),
                              UICSwitch(value: true, onChanged: () {}),
                            ]
                          ),
        
                          const UICSpacer(),
        
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Fehlerspeicher Ausgabe".i18n, textAlign: TextAlign.left)),
                              UICSwitch(value: true, onChanged: () {}),
                            ]
                          ),
        
                          const UICSpacer(),
        
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Relaistest".i18n, textAlign: TextAlign.left)),
                              UICSwitch(value: true, onChanged: () {}),
                            ]
                          ),
        
                          const UICSpacer(),
        
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Bremsentest".i18n, textAlign: TextAlign.left)),
                              UICSwitch(value: true, onChanged: () {}),
                            ]
                          ),
        
                          const UICSpacer(),
                          const Divider(),
                          const UICSpacer(),
        
                          UICElevatedButton(
                            onPressed: () async {
                              XCFReportAlert.open(context);
                            },
                            leading: const Icon(Icons.picture_as_pdf_rounded),
                            child: Text("PDF Wartungsprotokoll erzeugen".i18n)
                          ),
        
                          const UICSpacer(),
        
                          UICElevatedButton(
                            onPressed: () {},
                            leading: const Icon(Icons.table_view_rounded),
                            child: Text("CSV Wartungsprotokoll erzeugen".i18n)
                          ),
        
                          const UICSpacer(),

                          const Divider(),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text("Wartungsintervall zurücksetzen".i18n, textAlign: TextAlign.left)),
                              UICSwitch(value: true, onChanged: () {}),
                            ]
                          ),
        
                        ],
                      ),
                    ),
                  ]
                ),
              ]
            );
          }
        );
      }
    );
  }
}
