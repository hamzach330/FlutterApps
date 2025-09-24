part of ui_common;

class UICToggleButton extends StatelessWidget {
  final bool selected;
  final Widget child;
  final Widget? leading;
  final Function(bool)? onPressed;

  UICToggleButton({
    this.selected = false,
    required this.child,
    this.leading,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(theme.defaultWhiteSpace),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(leading != null) leading!,
          child,
        ],
      ),
    );
  }
}

class UICToggleButtonList extends StatelessWidget {
  final List<UICToggleButton> buttons;
  final Function(int) onChanged;
  final Axis axis;

  UICToggleButtonList({
    this.buttons = const [],
    required this.onChanged,
    this.axis = Axis.vertical
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderWidth = 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ToggleButtonsTheme(
          data: ToggleButtonsThemeData(
            color: theme.colorScheme.onSurface,
            borderColor: theme.colorScheme.onSurface.withAlpha(60),
            selectedColor: theme.colorScheme.onSurface,
            selectedBorderColor: theme.colorScheme.primary,
            fillColor: theme.colorScheme.primary.withAlpha(60),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderWidth: borderWidth,
          ),
          child: ToggleButtons(
            constraints: axis == Axis.vertical
              ? BoxConstraints(minWidth: constraints.maxWidth)
              : BoxConstraints(maxWidth: (constraints.maxWidth - borderWidth * (buttons.length + 1)) / buttons.length, minHeight: 56),
            direction: axis,
            onPressed: onChanged,
            isSelected: buttons.map((button) => button.selected).toList(),
            children: buttons.map((button) => button).toList(),
                    
          ),
        );
      }
    );
  }
}