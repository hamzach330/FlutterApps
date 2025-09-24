part of ui_common;

class ExpandableContainer extends StatefulWidget {
  final reorderable = false;
  final Widget child;
  final String title;
  final bool expanded;
  final EdgeInsets? contentPadding;
  final EdgeInsets? titlePadding;


  const ExpandableContainer({
    required this.title,
    required this.child,
    this.expanded = false,
    this.contentPadding = EdgeInsets.zero,
    this.titlePadding = const EdgeInsets.only(top: 20, bottom: 10),
    Key? key
  }):super(key: key);

  @override
  ExpandableContainerState createState () => ExpandableContainerState();
}

class ExpandableContainerState extends State<ExpandableContainer> {
  late final ExpandableController _controller = ExpandableController(initialExpanded: widget.expanded);

  ExpandableContainerState();

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      controller: _controller,
      theme: ExpandableThemeData(
        headerAlignment: ExpandablePanelHeaderAlignment.center,
        tapBodyToCollapse: true,
        iconColor:  Theme.of(context).iconTheme.color,
        iconPadding: const EdgeInsets.only(top: 10),
        iconSize: 32
      ),

      header: Padding(
        padding: widget.titlePadding ?? const EdgeInsets.all(0),
        child: UICNamedDivider(title: widget.title),
      ),
      
      builder: (_, collapsed, expanded) {
        return Expandable(
          collapsed: collapsed,
          expanded: expanded,
          theme: const ExpandableThemeData(
            crossFadePoint: 0
          ),
        );
      },

      collapsed: Container(),
      expanded: Padding(
        padding: widget.contentPadding ?? EdgeInsets.zero,
        child: widget.child,
      )
    );
  }
}
