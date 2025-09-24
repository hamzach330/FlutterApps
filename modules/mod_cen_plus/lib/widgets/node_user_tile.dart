part of '../module.dart';

class CPNodeUserTile extends StatelessWidget {
  final Function(CentronicPlusNode)? onSelect;
  final bool showControls;
  
  const CPNodeUserTile({
    super.key,
    this.onSelect,
    this.showControls = true,
  });

  @override
  Widget build(BuildContext context) {

    return Consumer<CentronicPlusNode>(
      builder: (context, node, _) {
        final theme = Theme.of(context);
        return UICGridTile(
          borderWidth: node.selected ? 2 : 1,
          borderColor: node.selected ? theme.colorScheme.successVariant.primaryContainer : null,
          elevation: 2,
          onTap: () {
            if(onSelect != null) {
              onSelect?.call(node);
            } else {
              node.selectUnique();
              CPNodeUserView.go(context, node);
            }
          },
          title: UICGridTileTitle(
            title: Text(node.name ?? node.mac),
            margin: EdgeInsets.all(3),
            borderRadius: 7,
          ),
          backgroundImage: DecorationImage(
            alignment: Alignment.center,
            fit: BoxFit.cover,
            image: node.getImage(),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(node.isDrive && showControls) Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                margin: EdgeInsets.all(theme.defaultWhiteSpace),
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: node.sendUpCommand,
                        child: Container(
                          padding: EdgeInsets.all(theme.defaultWhiteSpace),
                          child: Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: node.sendStopCommand,
                        child: Container(
                          padding: EdgeInsets.all(theme.defaultWhiteSpace),
                          child: Icon(
                            Icons.stop_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: node.sendDownCommand,
                        child: Container(
                          padding: EdgeInsets.all(theme.defaultWhiteSpace),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if(node.isSwitch && showControls) Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                margin: EdgeInsets.all(theme.defaultWhiteSpace),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: node.sendUpCommand,
                        child: Container(
                          padding: EdgeInsets.all(theme.defaultWhiteSpace),
                          child: Icon(
                            Icons.remove_circle_outline_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: node.sendStopCommand,
                        child: Container(
                          padding: EdgeInsets.all(theme.defaultWhiteSpace),
                          child: Icon(
                            Icons.power_settings_new_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );

  }
}