part of '../module.dart';

class CPNodeAdminTile extends StatelessWidget {
  final Function (CentronicPlusNode)? onSelect;
  
  const CPNodeAdminTile({
    super.key,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final otaInfo = Provider.of<OtauInfoProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Consumer<CentronicPlusNode>(
      builder: (context, node, _) {
        final update = otaInfo.getOtaForNode(node);
        return UICGridTile(
          borderWidth: node.selected ? 2 : 1,
          borderColor: node.selected ? theme.colorScheme.successVariant.primaryContainer : null,
          onTap: () {
            if(onSelect != null) {
              onSelect?.call(node);
            } else {
              node.selectUnique();
              CPNodeAdminView.go(context, node);
            }
          },
          title: UICGridTileTitle(
            margin: EdgeInsets.all(3),
            borderRadius: 7,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(node.name ?? node.mac),
              ],
            ),
          ),
          backgroundImage: DecorationImage(
            alignment: Alignment.center,
            fit: BoxFit.cover,
            image: node.getImage(),
          ),
          // body: Text("${node.parentMac}"),
          actions: [
            if(!node.isBatteryPowered) UICGridTileAction(
              style: UICColorScheme.variant,
              onPressed: node.identify,
              tooltip: "Gerät identifizieren".i18n,
              child: const Icon(Icons.wb_iridescent_rounded),
            )
            else if(node.indicateActivity == null) const SizedBox(width: 44, height: 44),

            if(node.indicateActivity == CPRemoteActivity.stop) UICGridTileAction(
              style: UICColorScheme.success,
              child: const Icon(Icons.stop_rounded),
            ),

            if(node.indicateActivity == CPRemoteActivity.up) UICGridTileAction(
              style: UICColorScheme.success,
              child: Transform.scale(
                scale: 2,
                child: const RotatedBox(
                  quarterTurns: 2,
                  child: Icon(Icons.arrow_drop_down_rounded)
                ),
              ),
            ),
            
            if(node.indicateActivity == CPRemoteActivity.down) UICGridTileAction(
              style: UICColorScheme.success,
              child: Transform.scale(
                scale: 2,
                child: const Icon(Icons.arrow_drop_down_rounded),
              ),
            ),
        
            if(node.wantsAttention) const CPNodeStatusIcon(),
        
            if(update != null) UICGridTileAction(
              style: UICColorScheme.success,
              tooltip: "${"Aktualisierung verfügbar".i18n}: v${update.version.toString()}", // This is only to avoid creation of new translation untis
              onPressed: () {
                OtaView.go(context, node);
              },
              child: const Icon(Icons.upgrade_rounded),
            ),
        
            if(node.loading) UICGridTileAction(
              style: UICColorScheme.variant,
              child: UICProgressIndicator(color: theme.colorScheme.onPrimaryContainer),
            )
          ]
        );
      }
    );

  }
}