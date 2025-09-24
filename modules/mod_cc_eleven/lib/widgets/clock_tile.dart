part of '../module.dart';

class CCElevenClockTile extends StatefulWidget {
  final int index;
  final CCElevenTimer clock;
  
  const CCElevenClockTile({
    super.key,
    required this.clock,
    required this.index,
  });

  @override
  State<CCElevenClockTile> createState() => _CCElevenClockTileState();
}

class _CCElevenClockTileState extends State<CCElevenClockTile> {
  late final cp = context.read<CentronicPlus>();
  List<CentronicPlusNode>? selectedNodes = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.primary);
    selectedNodes = cp.getNodesFrom64BitMask(widget.clock.command.cpDevices);
    return UICGridTile(
      borderWidth: 1,
      borderColor: theme.colorScheme.primaryContainer,
      title: UICGridTileTitle(
        title: Text(widget.clock.name),
        margin: EdgeInsets.all(3),
        borderRadius: 7,
      ),
      body: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
            margin: EdgeInsets.all(theme.defaultWhiteSpace),
            child: Padding(
              padding: EdgeInsets.all(theme.defaultWhiteSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...selectedNodes!.take(1).map((node) => Text(
                    node.name ?? "Unbenannt".i18n,
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    ),
                  ),
                    
                  if (selectedNodes!.length > 1) Text(
                    selectedNodes!.length == 2 
                      ? "Und 1 weiteres Gerät".i18n
                      : "Und %s weitere Geräte".i18n.fill([selectedNodes!.length - 1]),
                    style: textStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                    
                  const UICSpacer(),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.play_circle_fill_rounded, color: theme.colorScheme.primary, size: 16,),
                      Text("Aktion", style: textStyle,)
                    ],
                  ),
                  
                  const UICSpacer(),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.access_alarm, color: theme.colorScheme.primary, size: 16,),
                      Text(
                        DateFormat('dd.MM - HH:mm').format(widget.clock.nextTime.toLocal()),
                        style: textStyle,
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ),
        ],
      ),
      backgroundImage: DecorationImage(
        alignment: Alignment.center,
        opacity: .75,
        fit: BoxFit.cover,
        image: AssetImage("assets/images/watch_timer.jpg"),
      ),
      onTap: () {
        CCElevenClock.go(context, widget.index, widget.clock);
      },
    );
  }
}
