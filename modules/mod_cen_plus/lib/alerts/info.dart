part of '../module.dart';

class CPInfoAlert extends UICAlert<void> {
  static open(BuildContext context) {
    UICMessenger.of(context).alert(CPInfoAlert(
      centronicPlus: context.read<CentronicPlus>(),
    ));
  }

  final CentronicPlus centronicPlus;
  
  CPInfoAlert({
    super.key,
    required this.centronicPlus,
  });
  
  @override
  get title => "Informationen zum USB-Stick".i18n;

  @override
  get useMaterial => true;

  @override
  get materialWidth => 460;

  @override
  get backdrop => true;

  @override
  get dismissable => true;

  @override
  get closeAction => pop;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyMediumMuted = theme.bodyMediumMuted;
    return Provider<CentronicPlus>.value(
      value: centronicPlus,
      builder: (context, _) {
        return UICInfo(
          style: UICColorScheme.variant,
          margin: EdgeInsets.all(theme.defaultWhiteSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Teilnehmer einer Installation:".i18n, style: bodyMediumMuted),
                  Expanded(
                    child: centronicPlus.coupled == true
                      ? Text("Ja".i18n, textAlign: TextAlign.right, style: bodyMediumMuted?.copyWith(color: theme.colorScheme.successVariant.primary))
                      : Text("Nein".i18n, textAlign: TextAlign.right, style: bodyMediumMuted?.copyWith(color: theme.colorScheme.errorVariant.primary))
                  )
                ],
              ),
              Row(
                children: [
                  Text("MAC-ID:".i18n, style: bodyMediumMuted),
                  Expanded(
                    child: Text(centronicPlus.mac ?? "",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right
                    )
                  )
                ],
              ),
              Row(
                children: [
                  Text("Installations-ID:".i18n, style: bodyMediumMuted),
                  Expanded(child: Text(centronicPlus.pan, textAlign: TextAlign.right,))
                ],
              ),
              Row(
                children: [
                  Text("Firmware:".i18n, style: bodyMediumMuted),
                  Expanded(child: Text("${centronicPlus.swVersion}", textAlign: TextAlign.right))
                ],
              ),
                    
              Consumer<UICPackageInfoProvider>(
                builder: (context, packageInfo, _) {
                  return Row(
                    children: [
                      Text("App-Version:".i18n, style: bodyMediumMuted),
                      Expanded(
                        child: Text(packageInfo.version?.version ?? "", textAlign: TextAlign.right)
                      )
                    ],
                  );
                }
              ),
              
              const Divider(),
    
              Row(
                children: [
                  Text("Bekannte Geräte:".i18n, style: TextStyle(color: theme.colorScheme.successVariant.primary)),
                  Expanded(
                    child: Text("${centronicPlus.getOwnNodes().length}", textAlign: TextAlign.end, style: TextStyle(color: theme.colorScheme.successVariant.primary))
                  )
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
