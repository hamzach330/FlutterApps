part of '../module.dart';

class NetConfirmJoinAlert extends UICAlert<int> {
  @override
  String get title => "Empfänger einlernen".i18n;

  NetConfirmJoinAlert({
    super.key,
  });
  
  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      onPressed: () => pop(0),
      isDestructiveAction: true
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text("Das gewählte Centronic PLUS Gerät ist bereits Teil einer anderen Installation. Wie möchten Sie fortfahren?".i18n),
        ),
        
        Text("Das gewählte Gerät zu meiner Installation hinzufügen (die bestehenden Funkdaten werden gelöscht).".i18n),
        
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: OutlinedButton(
              onPressed: () {
                pop(1);
              },
              child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))
            ),
          ),
        ),

        Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text("oder".i18n),
          )
        ),

        Text("Installationsdaten des USB Sticks verwerfen und der bestehenden Installation beitreten.".i18n),
        
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: OutlinedButton(
              onPressed: () {
                pop(2);
              },
              child: Text("Weiter".i18n, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))
            ),
          ),
        ),
      ]
    );
  }
}
