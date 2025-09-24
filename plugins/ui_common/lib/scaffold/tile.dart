part of ui_common;

class UICDrawerTile extends StatelessWidget {
  final Function(BuildContext context) onPressed;
  final Widget title;
  final Widget? leading;

  const UICDrawerTile({
    super.key,
    required this.title,
    required this.onPressed,
    this.leading
  });

  @override
  Widget build(BuildContext context) {
    final defaultWhiteSpace = Theme.of(context).defaultWhiteSpace;
    return ListTile(
      contentPadding: EdgeInsets.only(
        top: 0,
        right: defaultWhiteSpace,
        left: defaultWhiteSpace,
        bottom: 0,
      ),
      minTileHeight: 0,
      leading: leading,
      title: title,
      titleTextStyle: Theme.of(context).textTheme.bodyMedium,
      onTap: () {
        final scaffold = UICScaffold.of(context);
        scaffold.closeDrawer();
        onPressed(context);
      },
    );
  }
}