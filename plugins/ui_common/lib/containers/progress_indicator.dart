part of ui_common;

class UICProgressIndicator extends StatelessWidget {
  final String? title;
  final int size;
  final Color? color;

  const UICProgressIndicator({
    this.title,
    this.size = 12,
    this.color,
    Key? key
  }):super(key: key);

  factory UICProgressIndicator.large({String? title}) => UICProgressIndicator(title: title, size: 32);
  factory UICProgressIndicator.medium({String? title}) => UICProgressIndicator(title: title, size: 24);
  factory UICProgressIndicator.small({String? title}) => UICProgressIndicator(title: title, size: 14);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // if(theme.platform == TargetPlatform.iOS || theme.platform == TargetPlatform.macOS) {
      return CupertinoActivityIndicator(
        color: color ?? theme.colorScheme.onSurface,
        radius: size.toDouble() // / 2
      );
    // } else {
    //   return SizedBox(
    //     width: size.toDouble(),
    //     height: size.toDouble(),
    //     child: CircularProgressIndicator(
    //       color: theme.colorScheme.onSurface,
    //       strokeWidth: size / 10,
    //     ),
    //   );
    // }
  }
}
