part of ui_common;

class UICInfo extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final UICColorScheme? style;
  final double elevation;
  final double borderTopLeft;
  final double borderTopRight;
  final double borderBottomLeft;
  final double borderBottomRight;

  const UICInfo({
    required this.child,
    this.style = UICColorScheme.none,
    this.padding,
    this.margin,
    this.elevation = 1,
    this.borderTopLeft = 8,
    this.borderTopRight = 8,
    this.borderBottomLeft = 8,
    this.borderBottomRight = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DividerTheme(
      data: DividerThemeData(
        color: style == UICColorScheme.error   ? theme.colorScheme.onErrorContainer.withValues(alpha: .3) :
               style == UICColorScheme.warn    ? theme.colorScheme.warnVariant.onSurface.withValues(alpha: .3) :
               style == UICColorScheme.success ? theme.colorScheme.successVariant.onSurface.withValues(alpha: .3) :
               style == UICColorScheme.variant ? theme.colorScheme.onSecondaryContainer.withValues(alpha: .3) :
                                                 theme.colorScheme.onPrimaryContainer.withValues(alpha: .3)
      ),
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: style == UICColorScheme.error   ? theme.colorScheme.errorContainer :
                 style == UICColorScheme.warn    ? theme.colorScheme.warnVariant.surface :
                 style == UICColorScheme.success ? theme.colorScheme.successVariant.surface :
                 style == UICColorScheme.variant ? theme.colorScheme.secondaryContainer :
                                                   theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          elevation: elevation,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderTopLeft),
            topRight: Radius.circular(borderTopRight),
            bottomLeft: Radius.circular(borderBottomLeft),
            bottomRight: Radius.circular(borderBottomRight),
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(theme.defaultWhiteSpace),
            child: child,
          )
        ),
      ),
    );
  }
}
