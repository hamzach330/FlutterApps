part of '../module.dart';

class XCFReportAlert extends UICAlert<void> {
  static open(BuildContext context) => UICMessenger.of(context).alert(XCFReportAlert(
    xcf: Provider.of<XCFProtocol>(context, listen: false),
  ));

  final XCFProtocol xcf;
  // final bool extendedSettings;
  
  XCFReportAlert({
    super.key,
    required this.xcf,
    // required this.extendedSettings
  });
  
  @override
  get title => "Wartungsbericht".i18n;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 800;

  @override
  get backdrop => true;

  @override
  get dismissable => true;

  @override
  get closeAction => pop;
  
  @override
  Widget build(BuildContext context) {
    return _XCFReportAlert(xcf: xcf);
  }
}
class _XCFReportAlert extends StatefulWidget {
  final XCFProtocol xcf;

  const _XCFReportAlert({
    required this.xcf,
  });

  @override
  State<_XCFReportAlert> createState() => _XCFReportAlertState();
}

class _XCFReportAlertState extends State<_XCFReportAlert> {
  List<XCFFault>? faults;

  @override
  initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    faults = (await widget.xcf.getFaultInfos())?.sorted((a, b) => a.index.compareTo(b.index));
    setState(() {});
  }

  @override
  Widget build (BuildContext context) {
    final theme = Theme.of(context);
    return UICConstrainedColumn(
      maxWidth: 800,
      children: [
        Text("Fehlerspeicher".i18n, textAlign: TextAlign.start, style: theme.textTheme.titleMedium),
        const UICSpacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          SizedBox(width: 80, child: Text("Index".i18n, textAlign: TextAlign.start,  style: theme.textTheme.titleSmall)),
          const UICSpacer(),
          SizedBox(width: 80, child: Text("Fehlcode".i18n, textAlign: TextAlign.start,  style: theme.textTheme.titleSmall)),
          const UICSpacer(),
          SizedBox(width: 80, child: Text("Zyklus".i18n, textAlign: TextAlign.start,  style: theme.textTheme.titleSmall)),
          const UICSpacer(),
          Expanded(child: Text("Beschreibung".i18n, textAlign: TextAlign.start,  style: theme.textTheme.titleSmall)),
          const UICSpacer(),
          SizedBox(width: 80, child: Text("Ursache".i18n, textAlign: TextAlign.start,  style: theme.textTheme.titleSmall)),
          const UICSpacer(),
          SizedBox(width: 80, child: Text("Frezquenz".i18n, textAlign: TextAlign.start,  style: theme.textTheme.titleSmall)),
          ],
        ),
        ...faults?.map((fault) {
          int index = faults!.indexOf(fault);
          return Container(
            color: index % 2 == 0 ? Colors.transparent : theme.colorScheme.surfaceContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 80, child: Text(fault.index.toString(), textAlign: TextAlign.start)),
                const UICSpacer(),
                SizedBox(width: 80, child: Text(fault.code, textAlign: TextAlign.start)),
                const UICSpacer(),
                SizedBox(width: 80, child: Text(fault.cycleCount.toString(), textAlign: TextAlign.start)),
                const UICSpacer(),
                if (_xcfFaultCodes.containsKey(fault.code))
                  Expanded(child: Text(_xcfFaultCodes[fault.code]!, textAlign: TextAlign.start))
                else 
                  Expanded(child: Text("-".i18n, textAlign: TextAlign.start)),
                const UICSpacer(),
                SizedBox(width: 80, child: Text(fault.cause.toString(), textAlign: TextAlign.start)),
                const UICSpacer(),
                SizedBox(width: 80, child: Text(fault.frequency.toString(), textAlign: TextAlign.start)),
              ],
            ),
          );
        }).toList() ?? [],
      ],
    );
  } 
}
