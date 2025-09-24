part of ui_common;

class UICOptionList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? spacing;
  final bool dividers;

  const UICOptionList({
    required this.children,
    this.dividers = true,
    this.padding,
    this.spacing,
    super.key
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> widgets = [];

    for(final child in children) {
      widgets.add(Padding(
        padding: spacing ?? EdgeInsets.all(theme.defaultWhiteSpace),
        child: child,
      ));
      
      if(dividers && child != children.last) {
        widgets.add(Divider(
          height: 1,
          indent: spacing?.left ?? theme.defaultWhiteSpace,
          endIndent: spacing?.right ?? theme.defaultWhiteSpace,
        ));
      }
    }

    return Material(
      color: theme.brightness == Brightness.dark
        ? theme.colorScheme.surface.brighten(.2)
        : theme.colorScheme.surface.darken(.2),
      elevation: 4,
      borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets
      ),
    );
  }
}
