part of ui_common;

class UICNamedDivider extends StatelessWidget {
  final reorderable = false;
  final String? title;
  final Widget? child;
  final EdgeInsets? padding;
  final Widget? endChild;

  const UICNamedDivider({
    super.key, 
    this.title,
    this.padding,
    this.child,
    this.endChild
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 10.0, bottom: 10),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: title != null 
              ? Text("$title",
                style: theme.textTheme.titleSmall)
              : child
          ),
          Expanded(child: Divider(color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha((255 * .2).toInt()))),
          if(endChild != null) endChild!
        ],
      ),
    );
  }
}

class UICNamedCenterDivider extends StatelessWidget {
  final reorderable = false;
  final String? title;
  final Widget? child;
  final EdgeInsets? padding;
  final Widget? endChild;

  const UICNamedCenterDivider({
    super.key, 
    this.title,
    this.padding,
    this.child,
    this.endChild
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: theme.colorScheme.onSecondaryContainer.withAlpha((255 * .2).toInt()))),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: title != null 
              ? Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text("$title",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white : Colors.black)),
              )
              : child
          ),
          Expanded(child: Divider(color: theme.colorScheme.onSecondaryContainer.withAlpha((255 * 0.2).toInt()))),
          if(endChild != null) endChild!
        ],
      ),
    );
  }
}