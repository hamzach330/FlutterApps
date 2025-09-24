part of '../module.dart';

class CCElevenSelectDevices extends UICAlert<List<CentronicPlusNode>> {
  final CentronicPlus centronicPlus;
  final List<CentronicPlusNode> selection;
  
  CCElevenSelectDevices({
    super.key,
    required this.selection,
    required this.centronicPlus,
  });
  
  @override
  get title => "Empfänger hinzufügen".i18n;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 500;

  @override
  get backdrop => true;

  @override
  get dismissable => false;

  @override
  get closeAction => () {
    pop(selection);
  };

  @override
  Widget build(BuildContext context) {
    for(final node in selection) {
      node.select();
    }
    return _CCElevenSelectDevicesContent(
      centronicPlus: centronicPlus,
      selection: selection,
    );
  }
}

class _CCElevenSelectDevicesContent extends StatefulWidget {
  final CentronicPlus centronicPlus;
  final List<CentronicPlusNode> selection;
  
  const _CCElevenSelectDevicesContent({
    required this.centronicPlus,
    required this.selection,
  });

  @override
  State<_CCElevenSelectDevicesContent> createState() => _CCElevenSelectDevicesContentState();
}

class _CCElevenSelectDevicesContentState extends State<_CCElevenSelectDevicesContent> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: widget.centronicPlus.updateStream.stream,
          initialData: widget.centronicPlus,
          updateShouldNotify: (_, __) => true,
        ),
      ],
      builder: (context, _) {
        return Selector<CentronicPlus, Map<String?, List<CentronicPlusNode>>>(
          selector: (context, centronicPlus) => centronicPlus.getForeignNetworks(""),
          builder: (context, foreignNetworks, _) {
            final theme = Theme.of(context);
            return CustomScrollView(
              primary: false,
              shrinkWrap: true,
              slivers: [
                SliverMainAxisGroup(
                  slivers: [
                    CPOwnNodes(
                      showControls: true,
                      extraFilter: (node) {
                        if (!(node.visible == true && !node.isCentral && !node.isRemote && !node.isSensor)) {
                          return false;
                        }
                        
                        if (widget.selection.isNotEmpty) {
                          final firstSelectedNode = widget.selection.first;
                          return node.compareFeatures(firstSelectedNode);
                        }
                        
                        return true;
                      },
                      onSelect: (node) async {
                        dev.log("Looking for features: ${node.features}");
                        if(widget.selection.contains(node)) {
                          node.unselect();
                          widget.selection.remove(node);
                        } else {
                          node.select();
                          widget.selection.add(node);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),

                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: theme.defaultWhiteSpace,
                  ),
                ),

                if(foreignNetworks.isNotEmpty && widget.centronicPlus.discovery) SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(theme.defaultWhiteSpace),
                        child: Center(
                          child: UICProgressIndicator(
                            color: theme.colorScheme.onTertiaryContainer,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(theme.defaultWhiteSpace),
                        child: Center(
                          child: Text("Suche weitere Geräte".i18n, textAlign: TextAlign.center)
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          }
        );
      }
    );
  }
}
