part of ui_common;

class NamedContainer extends StatelessWidget{
  final reorderable = false;
  final String title;
  final Widget? child;
  final EdgeInsets? padding;
  final Widget? endChild;

 const NamedContainer({
    required this.title,
    this.padding,
    this.child,
    this.endChild,
    Key? key
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 20.0, bottom: 10),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(title, style: theme.textTheme.titleSmall),
          ),
          const Expanded(child: Divider()),
          if(endChild != null) endChild!
        ],
      ),
    );
  }
}
