part of '../module.dart';

class AlertQuit extends UICAlert<int> {
  @override
  String get title => "Achtung!".i18n;

  AlertQuit({
    super.key,
  });
  
  @override
  get actions => [
    UICAlertAction(
      text: "Abbrechen".i18n,
      onPressed: () => pop(2),
      isDestructiveAction: true
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onTap: () => pop(0),
            child: Padding(
              padding: EdgeInsets.all(theme.defaultWhiteSpace),
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/usb_stick_remains.png"),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter
                      ),
                      color: theme.colorScheme.primaryContainer.withValues(alpha: .5)
                    ),
                    foregroundDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: theme.colorScheme.primaryContainer, width: 2)
                    ),
                  ),
                  const UICSpacer(),      
                  Text("USB-Stick verbleibt beim Kunden".i18n, textAlign: TextAlign.center)
                ],
              ),
            )
          ),
        ),
        
        const UICSpacer(2),

        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            onTap: () => pop(1),
            child: Padding(
              padding: EdgeInsets.all(theme.defaultWhiteSpace),
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/usb_stick_removed.png"),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter
                      ),
                      color: theme.colorScheme.primaryContainer.withValues(alpha: .5),
                    ),
                    foregroundDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: theme.colorScheme.primaryContainer, width: 2)
                    ),
                  ),

                  const UICSpacer(),
                  Text("USB-Stick verbleibt beim Monteur".i18n, textAlign: TextAlign.center)
                ],
              ),
            )
          ),
        ),
      ],
    );
  }
}