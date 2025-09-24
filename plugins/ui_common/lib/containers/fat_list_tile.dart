part of ui_common;

class UICFatListTile extends StatelessWidget {
  final Animation<double> animation;
  final Widget leading;
  final String title;
  final String subtitle;
  final Function () onTap;

  const UICFatListTile({
    super.key,
    required this.animation,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build (BuildContext context) {
    final theme = Theme.of(context);
    final titleMedium = theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer);
    final bodyMediumMuted = theme.bodyMediumMuted?.copyWith(color: theme.colorScheme.onPrimaryContainer);
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Center(
          child: Container(
            width: 450,
            padding: EdgeInsets.only(top: theme.defaultWhiteSpace),
            child: Material(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(theme.defaultWhiteSpace * 2),
                      child: leading,
                    ),
                
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: titleMedium),
                          Text(subtitle, style: bodyMediumMuted),
                        ],
                      ),
                    ),
                          
                    Padding(
                      padding: EdgeInsets.all(theme.defaultWhiteSpace),
                      child: Icon(Icons.chevron_right_rounded, size: 48, color: theme.colorScheme.onPrimaryContainer,),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      )
    );
  }
}
