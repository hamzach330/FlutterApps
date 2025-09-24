part of '../module.dart';

class RemoteAssignmentAlert extends UICAlert<bool> {
  final CentronicPlusNode target;
  final CentronicPlusNode? source;
  final int? channel;

  RemoteAssignmentAlert({
    super.key,
    required this.target,
    required this.source,
    this.channel
  });

  @override
  String get title => channel != null
    ? "Kanalbelegung".i18n
    : target.isSensor
      ? "Sensorzuordnung".i18n
      : "Gerätezuordnung".i18n;

  @override
  get actions => [
    UICAlertAction(
      text: "Nein".i18n,
      onPressed: decline,
      isDestructiveAction: true
    ),
    UICAlertAction(
      text: "Ja".i18n,
      onPressed: confirm
    )
  ];

  decline () async {
      pop();
  }

  confirm () async {
    if(source == null) {
      pop();
      return;
    }

    // if(selection.multiSelection.contains(target)) {
    //   await source!.macUnassign(target);
    //   if(channel != null) {
    //     await target.macUnassign(source!);
    //   }
    //   selection.multiSelection.remove(target);
    // } else {
    //   await source!.macAssign(target, channel);
    //   if(channel != null) {
    //     await target.macAssign(source!, channel);
    //   }
    //   selection.multiSelection.add(target);
    // }
    pop();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // if(channel != null && selection.multiSelection.contains(target))
        //   Text("Soll der Sender von dem Gerät getrennt werden?".i18n.fill([channel!]))
        // else if(channel != null)
        //   Text("Soll das Gerät Kanal %s auf dem Handsender zugeordnet werden?".i18n.fill([channel!]))
        // else if(selection.multiSelection.contains(target) && selection.selection?.isSensor == true)
        //   Text("Soll der Sensor von dem Gerät getrennt werden?".i18n)
        // else if(selection.multiSelection.contains(target))
        //   Text("Soll der Sender von dem Gerät getrennt werden?".i18n)
        // else if(selection.selection?.isSensor == true)
        //   Text("Soll der Sensor dem Gerät zugeordnet werden?".i18n)
        // else
        //   Text("Soll der Sender dem Gerät zugeordnet werden?".i18n),
      ]
    );
  }
}
