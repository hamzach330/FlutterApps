part of '../module.dart';

class CPNodeInfo extends StatelessWidget {
  final bool readOnly;
  
  const CPNodeInfo({
    super.key,
    this.readOnly = false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final node = context.read<CentronicPlusNode>();

    return Column(
      children: [
        UICInfo(
          style: UICColorScheme.variant,
          child: Column(
            children: [
              Consumer<CentronicPlusNode>(
                key: ValueKey("node_info_${node.mac}"),
                builder: (context, node, _) {
                  final textMediumMuted = theme.bodyMediumMuted;
                  final titleMedium = theme.textTheme.titleMedium;
        
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                node.productName != null
                                  ? Text("%s".i18n.fill([node.productName?.i18n ?? "Unbekannt".i18n]), style: titleMedium)
                                  : node.initiator == CPInitiator.sunDuskWind && node.isBatteryPowered == true
                                  ? Text("SC861 PLUS".i18n, style: titleMedium)
                                  : Text(node.initiator?.name.i18n ?? "Unbekannt".i18n, style: titleMedium),

                                if(node.isDrive && !node.isRemote && !node.isSensor && node.name != null) Container(
                                  padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace / 4),
                                  decoration: BoxDecoration(
                                    color: node.statusFlags.setupComplete == true
                                      ? theme.colorScheme.successVariant.primaryContainer
                                      : theme.colorScheme.errorVariant.primaryContainer,
                                    borderRadius: const BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if(node.statusFlags.setupComplete == true) Padding(
                                        padding: EdgeInsets.only(right: theme.defaultWhiteSpace / 2),
                                        child: Icon(Icons.check_box,
                                          color: theme.colorScheme.successVariant.onPrimaryContainer,
                                          size: 16
                                        )
                                      ) else Padding(
                                        padding: EdgeInsets.only(right: theme.defaultWhiteSpace / 2),
                                        child: Icon(Icons.expand_rounded, color: theme.colorScheme.errorVariant.onPrimaryContainer, size: 16)
                                      ),

                                      if(node.statusFlags.setupComplete == true) Text("Einrichtung abgeschlossen".i18n,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: theme.colorScheme.successVariant.onPrimaryContainer
                                        )
                                      ) else Text("Einrichtung unvollständig".i18n,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: theme.colorScheme.errorVariant.onPrimaryContainer
                                        )
                                      )
                                    ],
                                  ),
                                ) else if(!node.isRemote && !node.isBatteryPowered && !node.isSensor && node.name != null) Container(
                                  padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace / 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.successVariant.primaryContainer,
                                    borderRadius: const BorderRadius.all(Radius.circular(5))
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: theme.defaultWhiteSpace / 2),
                                        child: Icon(Icons.check_box, color: theme.colorScheme.successVariant.onPrimaryContainer, size: 16)
                                      ),
                                      Text("Einrichtung abgeschlossen".i18n,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: theme.colorScheme.successVariant.onPrimaryContainer
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryFixed,
                            backgroundImage: node.getProductImage() ?? node.getImage(),
                            radius: 40,
                          ),
                                  
                          SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Text("%s".i18n.fill([node.initiator ?? "Unbekannt"]), style: textMedium),
                                  if(node.serial != null && node.isVarioControl == false && node.isLightControl == false && node.isBatteryPowered == false && node.isSensor == false)
                                    Text("Seriennummer: %s".i18n.fill([node.serial ?? "Unbekannt".i18n]), style: textMediumMuted),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Text("MAC-ID: %s".i18n.fill([""]), style: textMediumMuted)
                                      ),
                                      Text(node.mac)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Text("Software: %s".i18n.fill([""]), style: textMediumMuted)
                                      ),
                                      Text(node.semVer?.toString()  ?? "Unbekannt".i18n)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Text("Build: %s".i18n.fill([""]), style: textMediumMuted)
                                      ),
                                      Text(node.version?.toString() ?? "Unbekannt".i18n)
                                    ],
                                  ),
                                  if(node.parentMac != CP_EMPTY_MAC) Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Text("Parent:", style: textMediumMuted)
                                      ),
                                      if(node.parent == null)
                                        Text("%s".i18n.fill([node.parentMac]))
                                      else TextButton(
                                        onPressed: () {
                                          final n = node.cp.getNodeByMac(node.parentMac);
                                          if(n != null) {
                                            n.selectUnique();
                                            CPNodeAdminView.go(context, n);
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          node.parentMac,
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
        
                      const UICSpacer(2),

                      CPNodeName(
                        node: node
                      ),
                    ],
                  );
                }
              ),
            ],
          ),
        ),
      ],
    );
  }
}
