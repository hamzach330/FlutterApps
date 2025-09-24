part of '../module.dart';

class OTAAllAlert extends UICAlert<void> {
  static open(BuildContext context) => UICMessenger.of(context).alert(OTAAllAlert(
    centronicPlus: Provider.of<CentronicPlus>(context, listen: false),
    otaInfo: Provider.of<OtauInfoProvider>(context, listen: false),
  ));

  final CentronicPlus centronicPlus;
  final OtauInfoProvider otaInfo;
  
  OTAAllAlert({
    super.key,
    required this.centronicPlus,
    required this.otaInfo
  });
  
  @override
  get title => "Alle Geräte aktualisieren".i18n;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 460;

  @override
  get backdrop => true;

  @override
  get dismissable => false;

  @override
  get closeAction => pop;
  
  @override
  Widget build(BuildContext context) {
    return _OTAAllPopover(centronicPlus: centronicPlus, otaInfo: otaInfo);
  }
}
class _OTAAllPopover extends StatefulWidget {
  final CentronicPlus centronicPlus;
  final OtauInfoProvider otaInfo;

  const _OTAAllPopover({
    required this.centronicPlus,
    required this.otaInfo
  });

  @override
  State<_OTAAllPopover> createState() => _OTAAllAlertState();
}

class _OTAAllAlertState extends State<_OTAAllPopover> {
  final mac = "0000000000000000";
  final confirmationTextController = TextEditingController();
  String? confirmationString;


  void lockUnlock({
    required bool up,
    required bool down,
  }) {
    widget.centronicPlus.multicast.lockUnlock(
      up: up,
      down: down
    );
  }

  @override
  Widget build (BuildContext context) {
    final receivers = widget.centronicPlus.nodes;
    final updateNodes = receivers.where((node) {
      final update = widget.otaInfo.getOtaForNode(node);
      return update != null;
    }).toList().reversed.toList();

    return StreamProvider<CentronicPlus>.value(
      initialData: widget.centronicPlus,
      value: widget.centronicPlus.updateStream.stream,
      updateShouldNotify: (_, __) => true,
      builder: (context, _) {
        return SizedBox(
          height: 300,
          child: CustomScrollView(
            slivers: [
              OtaView(nodes: updateNodes)
            ],
          ),
        );
      }
    );
  } 
}