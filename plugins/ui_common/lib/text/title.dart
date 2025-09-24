part of ui_common;

class UICTitle extends StatelessWidget {
  final String title;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const UICTitle(this.title,
      {super.key,
      this.crossAxisAlignment = CrossAxisAlignment.start,
      this.mainAxisAlignment = MainAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class UICButtonTitle extends StatelessWidget {
  final UICColorScheme? style;
  final String title;

  const UICButtonTitle({
    required this.title,
    super.key,
    this.style
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(title,
      textAlign: TextAlign.start,
      style: style == UICColorScheme.error   ? theme.titleMediumError :
             style == UICColorScheme.warn    ? theme.titleMediumWarn :
             style == UICColorScheme.success ? theme.titleMediumSuccess :
             style == UICColorScheme.variant ? theme.titleMediumVariant :
                                               theme.textTheme.titleMedium,
    );
  }
}
