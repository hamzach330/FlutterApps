part of '../module.dart';

class CPNodeSessionInfo extends StatelessWidget {
  static const pathName = 'rssi_graph';
  static const path = '${CPNodeAdminView.basePath}/:id/$pathName';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: const CPNodeSessionInfo(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }

  const CPNodeSessionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return UICPage(
      // backgroundColor: theme.colorScheme.surfaceContainerLow,
      // pop: () => context.pop(),
      // close: (context) {},
      // title: "Betriebsart".i18n,
      slivers: [
        //Todo FIXME : Empty Header
        UICPinnedHeader(leading: UICTitle("Betriebsart".i18n)),
        Consumer<CentronicPlusNode>(
          builder: (context, node, _) {
            return UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                const CPNodeInfo(readOnly: true),
                const UICSpacer(),
                if (!node.isBatteryPowered) RssiGraphWidget(),
                const UICSpacer(),
              ]
            );
          }
        ),
      ],
    );
  }
}

class RssiGraphWidget extends StatefulWidget {
  const RssiGraphWidget({super.key});

  @override
  State<RssiGraphWidget> createState() => _RssiGraphWidgetState();
}

class _RssiGraphWidgetState extends State<RssiGraphWidget> {

  late final CentronicPlusNode node = context.read<CentronicPlusNode>();
  late final CentronicPlus centronicPlus = context.read<CentronicPlus>();
  
  final List<GraphEntry<int>> _localEntries = [];
  final List<GraphEntry<int>> _remoteEntries = [];

  final GlobalKey<WidgetToImageState> widgetImageKey = GlobalKey();

  AsyncPeriodicTimer? rssiTimer;
  int remoteRssi = 0;
  int localRssi = 0;


  @override
  void initState() {
    super.initState();
    startReadRssi();
  }

  @override
  void dispose() {
    stopReadRssi();
    super.dispose();
  }

  void startReadRssi() {
    rssiTimer?.cancel();
    rssiTimer = AsyncPeriodicTimer(const Duration(milliseconds: 2000), () async {
      if (!node.isBatteryPowered) {
        try {
          remoteRssi = await node.readRssi();
          localRssi = centronicPlus.rssi;
          _addRssiValue(localRssi, remoteRssi);
        } catch (e) {
          dev.log("Error reading RSSI: $e", name: "RssiGraphWidgetNew");
        }
      }
    })..start();
  }

  void stopReadRssi() {
    rssiTimer?.cancel();
    rssiTimer = null;
  }


  void _addRssiValue(int local, int remote) {
    setState(() {
      final now = DateTime.now();
      _localEntries.add(GraphEntry(timestamp: now, value: local));
      _remoteEntries.add(GraphEntry(timestamp: now, value: remote));

      if (_localEntries.length > 100) _localEntries.removeAt(0);
      if (_remoteEntries.length > 100) _remoteEntries.removeAt(0);
    });
  }

  void _copyDataAsCsv() async {
    final messenger = UICMessenger.of(context);

    if (_localEntries.isEmpty || _remoteEntries.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('timestamp,local,remote');

    for (var i = 0; i < _localEntries.length; i++) {
      final t = _localEntries[i].timestamp.toIso8601String();
      final local = _localEntries[i].value;
      final remote = _remoteEntries[i].value;
      buffer.writeln('$t,$local,$remote');
    }

    final now = DateTime.now();
    final fileName =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${node.mac}';
    final directory = await getApplicationDocumentsDirectory();
    // Ensure the directory exists
    final rssiLogDir = Directory('${directory.path}/rssi_log');
    if (!await rssiLogDir.exists()) {
      await rssiLogDir.create(recursive: true);
    }
    final filePath = '${directory.path}/rssi_log/$fileName.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());
    await widgetImageKey.currentState?.exportImageToFile(fileName: "$fileName.png");

    await Clipboard.setData(ClipboardData(text: "${directory.path}"));
    
    messenger.addMessage(InfoMessage(
      "Datei gespeichert: $fileName".i18n,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final graphTheme = GraphTheme.fromBrightness(brightness, padding: const EdgeInsets.only(
      left: 30,
      right: 0,
      top: 0,
      bottom: 0,
    ));

    final series = [
      GraphSeries<int>(
        label: 'Lokal'.i18n,
        color: brightness == Brightness.light ? Colors.blueAccent : Colors.blue,
        entries: List.of(_localEntries),
      ),
      GraphSeries<int>(
        label: 'Entfernt'.i18n,
        color: brightness == Brightness.light ? Colors.redAccent : Colors.red,
        entries: List.of(_remoteEntries),
      ),
    ];

    return WidgetToImage(
      key: widgetImageKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Timeouts: ${node.timeoutCount}".i18n),

          const UICSpacer(),

          Text("Zuletzt gesehen: ${DateFormat('dd.MM.yyyy HH:mm:ss').format(node.lastSeen)}".i18n),
          
          const UICSpacer(),
          
          RichText(
            text: TextSpan(
              text: "RSSI: ".i18n,
              style: theme.textTheme.titleMedium,
              children: [
                TextSpan(text: "${localRssi}dBm", style: TextStyle(color: series[0].color)),
                TextSpan(text:" "),
                TextSpan(text: "${remoteRssi}dBm", style: TextStyle(color: series[1].color)),
              ],
            ),
          ),

          const UICSpacer(),
          
          GraphWidget<int>(
            series: series,
            theme: graphTheme,
          ),
        
          const UICSpacer(),

          Row(
            children: [
              SizedBox(width: 30),

              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    WidgetSpan(
                      child: Icon(Icons.call_received_rounded, color: series[0].color, size: 18),
                    ),
                    TextSpan(text: node.cp.mac, style: TextStyle(
                      color: series[0].color,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
              ),

              const Spacer(),

              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    WidgetSpan(
                      child: Icon(Icons.call_made_rounded, color: series[1].color, size: 18),
                    ),
                    TextSpan(text: node.mac, style: TextStyle(
                      color: series[1].color,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
              ),
            ],
          ),

          const UICSpacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              UICTextButton(
                shrink: true,
                leading: Icon(Icons.share_outlined, size: 18),
                onPressed: _copyDataAsCsv,
                text: "Exportieren".i18n,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
