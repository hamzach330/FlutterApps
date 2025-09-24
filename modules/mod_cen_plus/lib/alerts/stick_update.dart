part of '../module.dart';

class AlertStickUpdate extends UICAlert<bool> {
  @override
  String get title => "USB-Firmware aktualisieren".i18n;

  final CentronicPlus centronicPlus;

  AlertStickUpdate({
    super.key,
    required this.centronicPlus
  });
  
  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      isDestructiveAction: true,
      onPressed: () => pop(false),
    ),
    UICAlertAction(
      text: "Weiter".i18n,
      isDefaultAction: false,
      onPressed: () {
        centronicPlus.stickUpdate();
        pop(true);
      }
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Der USB-Stick wird ausgeworfen und als Laufwerk eingebunden.".i18n),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text("Kopieren Sie das Firmware Update auf dieses Laufwerk.".i18n),
        )
      ],
    );
  }
}