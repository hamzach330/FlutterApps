part of '../module.dart';

class AlertStickReset extends UICAlert {
  static open(BuildContext context) {
    UICMessenger.of(context).alert(AlertStickReset(
      centronicPlus: Provider.of<CentronicPlus>(context, listen: false),
    ));
  }

  @override
  String get title => "USB-Stick zurücksetzen".i18n;

  final CentronicPlus centronicPlus;

  AlertStickReset({
    super.key,
    required this.centronicPlus
  });
  
  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      isDestructiveAction: true,
      onPressed: pop,
    ),
    UICAlertAction(
      text: "Ja".i18n,
      onPressed: () {
        centronicPlus.stickReset();
        centronicPlus.closeEndpoint();
        pop();
      }
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Um die Funktion des USB-Sticks sicherzustellen entfernen Sie diesen nach dem Zurücksetzen aus dem USB-Port".i18n),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Text("Möchten Sie den USB-Stick jetzt zurücksetzen?".i18n),
        )
      ],
    );
  }
}