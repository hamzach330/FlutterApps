part of ui_common;

class UICAlertAction extends StatelessWidget {
  final String text;
  final void Function() onPressed;
  final bool isDefaultAction;
  final bool isDestructiveAction;

  const UICAlertAction({
    required this.text,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    Key? key
  }):super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if(Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CupertinoDialogAction(
          onPressed: onPressed,
          isDefaultAction: isDefaultAction,
          isDestructiveAction: isDestructiveAction,
          child: Text(text),
        ),
      );
    } else {
      if(isDestructiveAction == false) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TextButton (
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(theme.colorScheme.surfaceContainerHighest),
              foregroundColor: WidgetStatePropertyAll<Color>(theme.colorScheme.onSurfaceVariant),
              textStyle: WidgetStatePropertyAll<TextStyle>(TextStyle(
                fontWeight: isDefaultAction ? FontWeight.bold : FontWeight.normal
              ))
            ),
            onPressed: onPressed,
            child: Text(text, style: TextStyle(
              color: isDestructiveAction ? Colors.red : Colors.blue,
              fontWeight: isDefaultAction ? FontWeight.bold : FontWeight.normal
            ))
          ),
        );
      } else {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TextButton (
            onPressed: onPressed,
            child: Text(text, style: TextStyle(
              color: theme.colorScheme.errorVariant.primary,
              fontWeight: isDefaultAction ? FontWeight.bold : FontWeight.normal
            ))
          ),
        );
      }
    }
  }
}
