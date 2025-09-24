part of ui_common;

class UICDrawer extends StatelessWidget {
  final List<Widget> children;
  final Widget? leading;
  final Widget? trailing;
  final Widget? backdropChild;

  const UICDrawer({
    super.key,
    required this.children,
    this.leading,
    this.trailing,
    this.backdropChild,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Drawer(
          width: 300,
          backgroundColor: theme.colorScheme.surfaceContainer,
          surfaceTintColor: theme.colorScheme.surfaceContainer,
          elevation: 1,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: theme.defaultWhiteSpace * 3),
                  child: Column(
                    children: [
                      if(leading != null) leading!,
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          primary: true,
                          children: children,
                        )
                      ),
                          
                      if(trailing != null) Divider(height: 1),
                      
                      if(trailing != null) trailing!
                    ],
                  ),
                ),
                if(UICScaffold.of(context).breakPointSML) Positioned(
                  left: theme.defaultWhiteSpace,
                  top: theme.defaultWhiteSpace,
                  child: IconButton(
                    onPressed: () => UICScaffold.of(context).closeDrawer(),
                    icon: const Icon(Icons.close),
                    color: theme.colorScheme.onSurface,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if(backdropChild != null && UICScaffold.of(context).breakPointML) backdropChild!,
      ],
    );
  }
}
