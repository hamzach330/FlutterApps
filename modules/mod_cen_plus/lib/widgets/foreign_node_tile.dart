part of '../module.dart';

class CPForeignNodeTile extends StatefulWidget {
  final CentronicPlusNode node;
  final bool setGroupId; /// set the devices group ID, optional on configuration mode

  const CPForeignNodeTile({
    required this.node,
    this.setGroupId = false,
    super.key,
  });

  @override
  State<CPForeignNodeTile> createState() => _CPForeignNodeTileState();
}

class _CPForeignNodeTileState extends State<CPForeignNodeTile> {
  late final centronicPlus = Provider.of<CentronicPlus>(context, listen: false);
  bool pending = false;

  teachIn() async {
    if(pending == true) {
      return;
    }
    pending = true;

    if(centronicPlus.coupled == false && widget.node.netFactory == false) {
      final confirm = await confirmJoinNet();

      if(confirm == true) {
        await widget.node.couple();
        await centronicPlus.initEndpoint(readMesh: false);
      }
    } else if(widget.node.netFactory) {
      final confirm = await confirmTeachIn();

      if(confirm == true) {
        await widget.node.couple();
      }
    } else if(widget.node.netDiff) {
      final confirm = await confirmJoinOrTeachIn();

      if(confirm == 1) {
        await widget.node.couple();
      } else if(confirm == 2) {
        showNetChangeIndicator();
        centronicPlus.stickReset();
        // navigator.pop();
      }
    }

    pending = false;
  }

  Future<int?> confirmJoinOrTeachIn() async {
    return await UICMessenger.of(context).alert(NetConfirmJoinAlert());
  }

  Future<bool?> confirmTeachIn() async {
    return await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
      title: "Empfänger einlernen".i18n,
      child: Text("Soll der Empfänger der Installation hinzugefügt werden?".i18n.fill([centronicPlus.pan]))
    ));
  }

  Future<bool?> confirmJoinNet() async {
    return await UICMessenger.of(context).alert(UICSimpleQuestionAlert(
      title: "Netz beitreten".i18n,
      child: Text("Der ausgewählt Empfänger ist bereits Teil einer Installation. Möchten Sie dieser Installation beitreten?".i18n)
    ));
  }

  Future<void> showNetChangeIndicator() async {
    return await UICMessenger.of(context).alert(UICBarrierAlert(
      title: "Netzwerkbeitritt".i18n,
      child: Text("Netzbeitritt läuft. Bitte einen kleinen Moment Geduld.".i18n)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      initialData: widget.node,
      value: widget.node.updateStream.stream,
      updateShouldNotify: (_, __) => true,
      builder: (context, _) {
        return Consumer<CentronicPlusNode>(
          builder: (context, node, __) {
            return UICGridTile(
              onTap: teachIn,
              title: UICGridTileTitle(
                title: Text(node.name ?? node.mac),
              ),
              actions: [
                UICGridTileAction(
                  style: UICColorScheme.variant,
                  onPressed: node.identify,
                  tooltip: "Gerät identifizieren".i18n,
                  child: const Icon(Icons.wb_iridescent_rounded),
                ),
                        
                if(widget.node.waitForCouple) UICGridTileAction(
                  style: UICColorScheme.variant,
                  child: const UICProgressIndicator(),
                ),
                        
                if(!node.waitForCouple && (node.netFactory || node.netDiff)) UICGridTileAction(
                  style: UICColorScheme.warn,
                  onPressed: node.identify,
                  tooltip: node.netFactory
                    ? "Werkszustand".i18n
                    : "Das Gerät ist bereits Teil einer Installation".i18n,
                  child: node.netFactory
                    ? const Icon(Icons.factory)
                    : const Icon(Icons.key)
                ),
              ],
              backgroundImage: DecorationImage(
                alignment: Alignment.center,
                fit: BoxFit.cover,
                image: node.getImage(),
              ),
            );
          }
        );
      }
    );
  }
}
