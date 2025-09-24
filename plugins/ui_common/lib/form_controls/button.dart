part of ui_common;

class UICElevatedButton extends StatelessWidget {
  final Function() onPressed;
  final UICColorScheme? style;
  final Widget? leading;
  final Widget? trailing;
  final Widget child;
  final double elevation;
  final bool shrink;
  final TextOverflow? overflow;

  UICElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.leading,
    this.trailing,
    this.elevation = 0,
    this.shrink = true,
    this.overflow = null,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = style == UICColorScheme.error   ? theme.errorButtonStyle :
             style == UICColorScheme.warn    ? theme.warnButtonStyle :
             style == UICColorScheme.success ? theme.successButtonStyle :
             style == UICColorScheme.variant ? theme.variantButtonStyle :
                                               theme.defaultButtonStyle;
    return ElevatedButton(
      style: buttonStyle.copyWith(
        elevation: WidgetStatePropertyAll(elevation),
      ),
      onPressed: this.onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if(leading != null) leading ?? SizedBox(
            width: theme.defaultButtonIconSize,
            height: theme.defaultButtonIconSize
          ),
          if(leading != null) SizedBox(width: theme.defaultWhiteSpace),
          if(shrink) Flexible(
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.start, // TextAlign.center,
              overflow: overflow,
              softWrap: true,
              child: child
            ),
          )
          else Expanded(
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.start, // TextAlign.center,
              overflow: overflow,
              softWrap: true,
              child: child
            ),
          ),
          // child,
          if(trailing != null) SizedBox(width: theme.defaultWhiteSpace),
          if(trailing != null) trailing ?? SizedBox(
            width: theme.defaultButtonIconSize,
            height: theme.defaultButtonIconSize
          ),
        ],
      )
    );
  }
}


class UICTextButton extends StatelessWidget {
  final Function() onPressed;
  final UICColorScheme? style;
  final Widget? leading;
  final Widget? trailing;
  final String text;
  final bool shrink;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  UICTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.style,
    this.leading,
    this.trailing,
    this.shrink = false,
    this.textStyle,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      style: (
          style == UICColorScheme.error   ? theme.errorTextButtonStyle :
          style == UICColorScheme.warn    ? theme.warnTextButtonStyle :
          style == UICColorScheme.variant ? theme.variantTextButtonStyle :
          style == UICColorScheme.success ? theme.successTextButtonStyle :
          theme.defaultTextButtonStyle
        ).copyWith(
          padding: WidgetStatePropertyAll(padding ?? EdgeInsets.all(theme.defaultWhiteSpace)),
          textStyle: WidgetStatePropertyAll(textStyle ?? TextStyle()),
          backgroundColor: WidgetStatePropertyAll(backgroundColor ?? Colors.transparent),
        ),
      onPressed: this.onPressed,
      child: Row(
        children: [
          if(leading != null) leading!,
          if(leading != null) SizedBox(width: theme.defaultWhiteSpace),
          
          if(shrink) Text(text)
          else       Expanded(child: Text(text)),
          
          if(trailing != null) SizedBox(width: theme.defaultWhiteSpace),
          if(trailing != null) trailing!,
        ],
      )
    );
  }
}