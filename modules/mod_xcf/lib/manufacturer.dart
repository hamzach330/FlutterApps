part of 'module.dart';

class XCFManufacturerView extends StatefulWidget {
  static const path = '${XCFHome.path}/manufacturer';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => const NoTransitionPage(
      child: XCFManufacturerView(),
    ),
  );

  static go(BuildContext context) {
    context.push(path);
  }

  const XCFManufacturerView({super.key});

  @override
  State<XCFManufacturerView> createState() => _XCFManufacturerViewState();
}

class _XCFManufacturerViewState extends State<XCFManufacturerView> {
  late final xcf = Provider.of<XCFProtocol>(context, listen: false);
  final formKey = GlobalKey<FormState>();
  String projectName = "";
  String projectLocation = "";
  String projectId = "";
  String projectCompany = "";
  String projectTechnician = "";
  String street = "";
  String postcode = "";
  String city = "";
  String country = "";
  String comment1 = "";
  String comment2 = "";
  String comment3 = "";


  XCFCompanyInfo? companyInfo;

  @override
  initState() {
    super.initState();
    unawaited(getCompanyInfo());
  }

  Future<void> getCompanyInfo () async {
    companyInfo = await xcf.getCompanyInfo();
    setState(() {
      projectName = companyInfo?.projectName ?? "";
      projectLocation = companyInfo?.projectLocation ?? "";
      projectId = companyInfo?.projectId ?? "";
      projectCompany = companyInfo?.companyName ?? "";
      projectTechnician = companyInfo?.technicianName ?? "";

    });
  }

  Future<void> saveCompanyInfo () async {
    await xcf.setCompanyInfo(XCFCompanyInfo(
      companyName: projectCompany,
      projectId: projectId,
      technicianName: projectTechnician,
      projectLocation: projectLocation,
      projectName: projectName,
      city: city,
      country: country,
      postcode: postcode,
      street: street,
      comment1: comment1,
      comment2: comment2,
      comment3: comment3,
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    return LayoutBuilder(
      builder: (context, constraints) {
        return UICPage(
          //title: "Hersteller".i18n,
          //elevation: 0,
          //menu: true,
          slivers: [
            //Todo FIXME : Empty Header
            UICPinnedHeader(
              leading: UICTitle("Hersteller".i18n)
            ),
            UICConstrainedSliverList(
              maxWidth: 600,
              children: [
                UICGridTile(
                  elevation: 0,
                  borderColor: Colors.transparent,
                  bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace  * 1),
                  // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
                  title: UICGridTileTitle(
                    backgroundColor: Colors.transparent,
                    title: Text("Systemeinstellungen".i18n, style: subtitle),
                  ),
    
    
                  body: Container()
                ),
                UICGridTile(
                  elevation: 1,
                  borderColor: theme.colorScheme.errorVariant.primary,
                  bodyPadding: EdgeInsets.all(theme.defaultWhiteSpace  * 1),
                  // margin: EdgeInsets.only(top: theme.defaultWhiteSpace * 2),
                  title: UICGridTileTitle(
                    backgroundColor: theme.colorScheme.errorVariant.primaryContainer,
                    foregroundColor: theme.colorScheme.errorVariant.onPrimaryContainer,
                    title: Text("Werkseinstellungen".i18n, style: subtitle),
                  ),
    
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Hinweis: Durch Zurücksetzen auf die Werkseinstellungen wird das Passwort auf das Standard-Passwort zurückgesetzt!".i18n, textAlign: TextAlign.center),
                      const UICSpacer(),
                      UICElevatedButton(
                        style: UICColorScheme.error,
                        onPressed: () async {
                          final answer = await UICMessenger.of(context).alert(UICSimpleConfirmationAlert(
                            title: "Werkseinstellungen wiederherstellen".i18n,
                            child: Text("Sind Sie sicher, dass Sie die Werkseinstellungen wiederherstellen möchten?".i18n),
                          ));

                          if(answer == true) {
                            // await xcf.resetToFactory();
                          }
                        },
                        child: Text("Werkseinstellungen wiederherstellen".i18n),
                      ),
                    ],
                  )
                )
                
              ]
            ),
          ]
        );
      }
    );
  }
}
