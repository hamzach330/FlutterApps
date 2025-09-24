part of '../module.dart';

class CCGroupTile extends StatelessWidget {
  final CCGroup group;

  const CCGroupTile({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final cp = context.read<CentronicPlus>();
    final cc = context.read<CCEleven>();
    final List<CentronicPlusNode> selectedNodes = cp.getNodesFrom64BitMask(group.cpGroup);
    final theme = Theme.of(context);

    final commands = cc.getSharedCommands(selectedNodes);

    final supportsMove = commands.contains(CPAvailableCommands.up) && 
                         commands.contains(CPAvailableCommands.down) && 
                         commands.contains(CPAvailableCommands.stop);

    final supportsSwitch = commands.contains(CPAvailableCommands.on) && 
                           commands.contains(CPAvailableCommands.off);

    return UICGridTile(
      borderWidth: 1,
      elevation: 2,
      backgroundImage: DecorationImage(
        alignment: Alignment.center,
        fit: BoxFit.cover,
        image: const AssetImage("assets/images/devices/shutter.jpeg"),
      ),
      borderColor: null,
      onTap: () {
        CCElevenGroupView.goToGroup(context, group);
      },
      title: UICGridTileTitle(
        title: Text(group.name),
        margin: EdgeInsets.all(3),
        borderRadius: 7,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if(supportsMove) Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            margin: EdgeInsets.all(theme.defaultWhiteSpace),
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final pageData = cp.getPage32FromPage64(group.cpGroup);
                      for(final groupCode in pageData) {
                        cp.multicast.sendUpCommand(group: groupCode);
                      }
                    },
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
                    onTap: () {
                      final pageData = cp.getPage32FromPage64(group.cpGroup);
                      for(final groupCode in pageData) {
                        cp.multicast.sendStopCommand(group: groupCode);
                      }
                    },
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
                    onTap: () {
                      final pageData = cp.getPage32FromPage64(group.cpGroup);
                      for(final groupCode in pageData) {
                        cp.multicast.sendDownCommand(group: groupCode);
                      }
                    },
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

          if(supportsSwitch) Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            margin: EdgeInsets.all(theme.defaultWhiteSpace),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final pageData = cp.getPage32FromPage64(group.cpGroup);
                      for(final groupCode in pageData) {
                        cp.multicast.sendUpCommand(group: groupCode);
                      }
                    },
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
                    onTap: () {
                      final pageData = cp.getPage32FromPage64(group.cpGroup);
                      for(final groupCode in pageData) {
                        cp.multicast.sendStopCommand(group: groupCode);
                      }
                    },
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
}
