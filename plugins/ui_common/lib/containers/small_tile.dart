part of ui_common;

class UICSmallTile extends StatelessWidget {
  final String image;
  final String? name;
  final String? value;
  final double opacity;
  final double radius;
  final Color? borderColor;
  final double? borderWidth;

  const UICSmallTile({
    super.key, 
    required this.image,
    this.name,
    this.value,
    this.opacity = 1,
    this.radius = 8,
    this.borderColor,
    this.borderWidth
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primaryContainer,
          width: borderWidth ?? 2
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(image),
          opacity: 1,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if(name != null) Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: opacity),
            ),
            padding: EdgeInsets.all(theme.defaultWhiteSpace / 2),
            child: Text(name!,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)
            )
          ),
          if(name == null) Container(),
          if(value != null) Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: opacity),
            ),
            padding: EdgeInsets.all(theme.defaultWhiteSpace / 2),
            child: Text(value ?? "",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)
            )
          )
        ],
      )
    );
  }
}
