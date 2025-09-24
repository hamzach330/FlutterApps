part of '../module.dart';

class MulticastNetDeleteAlert extends UICAlert<bool> {
  @override
  String get title => "Empfänger einlernen".i18n;

  get confirmationString => "Ja".i18n;

  final confirmationTextController = TextEditingController();

  MulticastNetDeleteAlert({
    super.key,
  });
  
  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      onPressed: () => pop(false),
      isDestructiveAction: true
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          Text("Durch das Löschen der Funkzuordnung werden alle Einstellungen zum gewählten Funksystem zurückgesetzt! Eingelernte Handsender verlieren dadurch die Funktion und müssen neu verbunden werden. Sind Sie sicher dass das Funksystem zurückgesetzt werden soll?".i18n),
          const UICSpacer(),
          Center(child: Text("Diese Aktion mit \"%s\" bestätigen".i18n.fill([confirmationString ?? ""]))),
          const UICSpacer(),
          UICTextInput(
            controller: confirmationTextController,
            autofocus: true,
            hintText: "".i18n,
            onChanged: (value) {
              if(confirmationTextController.text.toLowerCase() == confirmationString?.toLowerCase()) {
                pop(true);
              }
            },
          )
        ]
      ),
    );
  }
}