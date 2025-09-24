part of '../module.dart';

// NOTE: navigatorContainerBuilder moved to module.dart, see instructions.

class XCFDrawer extends StatefulWidget {
  static const path = '${XCFHome.path}/drawer';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFDrawer(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFDrawer({
    super.key,
  });

  @override
  State<XCFDrawer> createState() => _XCFDrawerState();
}

class _XCFDrawerState extends State<XCFDrawer> {
  late final xcf = Provider.of<XCFProtocol>(context, listen: false);

  bool loading = true;
  List<int>? busVersion;
  String? version;
  String? articleId;
  String? name;
  String? level;
  double? temperature;
  bool? breakRelais;
  bool? fe1;
  bool? maintenanceRelais;
  bool? endPositionRelais;
  bool? vdcIn;
  Map<String, XCFFault> faults = {};
  List<XCFParameterInfo> parameters = [];
  Timer? polling;

  @override
  initState() {
    super.initState();
    unawaited(asyncInit());
  }

  asyncInit () async {
    polling = Timer.periodic(const Duration(seconds: 5), (_) async {
      busVersion = await xcf.getBusVersion();
      final getVersion = await xcf.getVersion();
      articleId = getVersion?.$1;
      version = getVersion?.$2;
      name = await xcf.getName();
      temperature = await xcf.getTemperature();

      breakRelais = await xcf.queryBreakRelais();
      fe1 = await xcf.queryFE1();
      maintenanceRelais = await xcf.queryMaintenanceRelais();
      endPositionRelais = await xcf.queryEndPositionTopRelais();
      vdcIn = await xcf.queryVDCIn();

      setState(() {
        loading = false;
      });

    });

    // faults = await xcf.getFaultInfos() ?? {};
    await loadParameters();
  }
  
  Future<void> loadParameters () async {
    xcf.loadParameterDefinitions(await DefaultAssetBundle.of(context)
      .loadString("assets/xcf/xcf_parameters.json"));
      
    await xcf.loadAllParameters(
      userRole: XCFUserType.Torhersteller,
    );
  }

  @override
  dispose() {
    super.dispose();
    polling?.cancel();
    polling = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyMediumMuted = theme.bodyMediumMuted;

    return UICDrawer(
      trailing: UICDrawerTile(
        leading: const Icon(Icons.exit_to_app_rounded),
        title: Text('Konfiguration beenden'.i18n),
        onPressed: (_) => xcf.endpoint.close(),
      ),

      children: [
        UICInfo(
          style: UICColorScheme.variant,
          margin: EdgeInsets.all(theme.defaultWhiteSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(loading) Center(
                child: UICProgressIndicator.small()
              ),
              if(!loading) Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name?.toUpperCase() ?? ''.i18n, style: theme.textTheme.titleMedium),
                  Expanded(child: Text("v.${version ?? '-'}", style: bodyMediumMuted, textAlign: TextAlign.right))
                ],
              ),
              
              if(!loading) const Divider(),
              
              if(!loading) Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Artikelnummer".i18n, style: bodyMediumMuted),
                  Text(articleId ?? ''.i18n, style: bodyMediumMuted),
                ]
              ),

              if(!loading) Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bus-Version".i18n, style: bodyMediumMuted),
                  Text(busVersion?.join('.') ?? '-'.i18n, style: bodyMediumMuted),
                ]
              ),

              if(!loading) Consumer<XCFProtocol>(
                builder: (context, xcf, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Zusatzkarte".i18n, style: bodyMediumMuted),
                      // FIXME: Enum? Hint 800 is the parameter ID for "Zusatzkarte"
                      // 0 - none
                      // 1 - XM-30
                      // 2 - XM-40
                      Text((int.tryParse(xcf.parameters["800"]?.value ?? "0") ?? 0) > 0 ? "Erkannt".i18n : "N/A".i18n),
                    ],
                  );
                }
              ),

              if(!loading) const Divider(),

              if(!loading) Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Text("Temperatur".i18n, style: theme.bodyMediumMuted)),
                      const UICSpacer(),
                      Text(temperature?.toString() ?? "N/A"),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: Text("V DC In".i18n, style: theme.bodyMediumMuted)),
                      const UICSpacer(),
                      if(vdcIn == true) Icon(
                        Icons.check_box_rounded,
                        color: theme.colorScheme.successVariant.primary
                      ) else Icon(
                        Icons.error_rounded,
                        color: theme.colorScheme.errorVariant.primary
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: Text("RS485".i18n, style: theme.bodyMediumMuted)),
                      const UICSpacer(),
                      if(faults["750"] != null) Icon(
                        Icons.error_rounded,
                        color: theme.colorScheme.errorVariant.primary,
                      ) else Icon(
                        Icons.check_box_rounded,
                        color: theme.colorScheme.successVariant.primary
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: Text("Bremse".i18n, style: theme.bodyMediumMuted)),
                      const UICSpacer(),

                      if(breakRelais == true) Icon(
                        Icons.check_box_rounded,
                        color: theme.colorScheme.successVariant.primary,
                      ) else Icon(
                        Icons.error_rounded,
                        color: theme.colorScheme.errorVariant.primary,
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: Text("FE1 Auf".i18n, style: theme.bodyMediumMuted)),
                      const UICSpacer(),
                      if(fe1 == true) Icon(
                        Icons.check_box_rounded,
                        color: theme.colorScheme.successVariant.primary,
                      ) else Icon(
                        Icons.error_rounded,
                        color: theme.colorScheme.errorVariant.primary,
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(child: Text("Wartung".i18n, style: theme.bodyMediumMuted)),
                      const UICSpacer(),
                      if(maintenanceRelais == true) Icon(
                        Icons.check_box_rounded,
                        color: theme.colorScheme.successVariant.primary,
                      ) else Icon(
                        Icons.error_rounded,
                        color: theme.colorScheme.errorVariant.primary,
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(child: Text("Endlage oben".i18n, style: theme.bodyMediumMuted)),
                      const UICSpacer(),
                      if(endPositionRelais == true) Icon(
                        Icons.check_box_rounded,
                        color: theme.colorScheme.successVariant.primary,
                      ) else Icon(
                        Icons.indeterminate_check_box_rounded,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Text("Entwickler".i18n, style: theme.bodyMediumMuted)
                      ),
                      const UICSpacer(),
                      Icon(Icons.check_box_rounded, color: theme.colorScheme.successVariant.primary),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),

        UICDrawerTile(
          leading: const Icon(Icons.build_circle_rounded),
          title: Text('Inbetriebnahme'.i18n),
          onPressed: (_) => XCFSetupWizard.go(context),
        ),
        
        UICDrawerTile(
          leading: const Icon(Icons.speed_rounded),
          title: Text('Schließgeschwindigkeits-Überwachung'.i18n),
          onPressed: (_) => XCFMonitorView.go(context),
        ),
        
        UICDrawerTile(
          leading: const Icon(Icons.home_repair_service_rounded),
          title: Text('Wartung'.i18n),
          onPressed: (_) => XCFMaintenanceView.go(context),
        ),
        
        UICDrawerTile(
          leading: const Icon(Icons.precision_manufacturing_rounded),
          title: Text('Hersteller'.i18n),
          onPressed: (_) => XCFManufacturerView.go(context),
        ),
        
        UICDrawerTile(
          leading: const Icon(Icons.picture_as_pdf_rounded),
          title: Text('Bedienungsanleitung'.i18n),
          onPressed: (_) {},
        ),

        UICDrawerTile(
          leading: const Icon(Icons.code_rounded),
          title: Text('Entwickler'.i18n),
          onPressed: (_) => XCFDeveloperView.go(context),
        ),
      ],
    );
  }
}
