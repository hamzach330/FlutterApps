part of ui_common;

class UICSwitch extends StatelessWidget {
  final bool value;
  final bool enabled;
  final String? label;
  final void Function() onChanged;

  const UICSwitch({
    required this.value,
    required this.onChanged,
    this.label,
    this.enabled = true,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 42,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Opacity(
          opacity: enabled ? 1 : .5,
        
          child: theme.platform != TargetPlatform.iOS && theme.platform != TargetPlatform.macOS
            ? Switch(
                
                padding: EdgeInsets.zero,
                value: value,
                onChanged: (_) => enabled ? onChanged() : null,
                activeTrackColor: theme.colorScheme.successVariant.primary,
              )
            : CupertinoSwitch(
                activeTrackColor: theme.colorScheme.successVariant.primary,
                value: value,
                onChanged: (_) => enabled ? onChanged() : null,
              ),
        
          // child: Builder( /// ??? WHY BUILDER?
          //   builder: (context) {
          //     if(theme.platform == TargetPlatform.android) {
          //       return CupertinoSwitch(
          //         activeTrackColor: theme.colorScheme.successVariant.primary,
          //         value: value,
          //         onChanged: (_) => enabled ? onChanged() : null,
          //       );
          //     } else if(theme.platform == TargetPlatform.iOS) {
          //       return CupertinoSwitch(
          //         activeTrackColor: theme.colorScheme.successVariant.primary,
          //         value: value,
          //         onChanged: (_) => enabled ? onChanged() : null,
          //       );
          //     } else {
          //       return Switch(
          //         value: value,
          //         onChanged: (_) => enabled ? onChanged() : null,
          //       );
          //     }
          //   },
          // )
        ),
      ),
    );
  }
}
