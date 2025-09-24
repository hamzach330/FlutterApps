part of '../module.dart';

class OTAAlert extends UICAlert<int?> {
  @override
  String get title => "Firmware aktualisieren".i18n;

  final OtaProgressProvider progress;
  final Function onClose;

  OTAAlert({
    super.key,
    required this.progress,
    required this.onClose
  });
  
  @override
  get actions => [
    _OtaCloseAction(progress, () {
      onClose();
      pop();
    })
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: progress,
      builder: (context, _) => Consumer<OtaProgressProvider>(
        builder: (context, progress, _) {

          if(progress.done) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Icon(Icons.check_circle_outline_rounded, size: 96, color: Colors.green),
                ),
                const UICSpacer(),
                Text("Die Firmware wurde aktualisiert.".i18n),
                const SizedBox(height: 20),
                Text("Hinweis: Das Gerät ist unter Umständen mehrere Minuten nicht erreichbar.".i18n, style: theme.bodyMediumItalic)
              ]
            );
          }

          return Column(
            children: [
              Text("${(progress.current / progress.length * 100).round()}%"),

              const UICSpacer(),

              LinearProgressIndicator(
                value: progress.current / progress.length,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              
              const UICSpacer(),

              Text("Sende Paket %s von %s".i18n.fill([progress.current, progress.length - 1])),
            ],
          );
        }
      ),
    );
  }
}

class _OtaCloseAction extends StatelessWidget {
  final OtaProgressProvider progress;
  final Function onPressed;
  const _OtaCloseAction(this.progress, this.onPressed);
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: progress,
      builder: (context, _) => Consumer<OtaProgressProvider>(
        builder: (context, progress, _) {
          return UICAlertAction(
            text: progress.done ? "Fertig".i18n : "Abbrechen".i18n,
            isDestructiveAction: !progress.done,
            onPressed: () {
              onPressed();
            },
          );
        }
      )
    );
  }
}
