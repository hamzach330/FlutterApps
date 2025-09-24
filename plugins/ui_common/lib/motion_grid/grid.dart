part of ui_common;

enum UICGridViewMode {
  list, grid
}

class UICGrid<T> extends StatefulWidget {
  static _UICGridState? of(BuildContext context) => context.findAncestorStateOfType<_UICGridState>();

  /// A widget that can be used to create a grid of items that can be reordered.
  ///
  /// The grid can have any number of children, and the children can be reordered.
  /// The [items] is the list of items that will be shown in the grid.
  /// The [onReorder] is the function that will be called when the children are reordered.
  /// The [childAspectRatio] is the aspect ratio of the children.
  /// The [viewMode] either [UICGridViewMode.list] or [UICGridViewMode.grid].
  /// The [builder] is the function that will be used to build the children.
  /// The [scrollDirection] is the scroll direction of the grid.
  ///
  /// Example:
  /// ```dart
  /// UICGrid(
  ///   onReorder: (children, oldIndex, newIndex) {},
  ///   children: [
  ///     for(int i = 0; i < 200; i++) UICGridTile(
  ///       backgroundImage: const AssetImage("assets/images/devices/shutter.jpeg"),
  ///       backgroundImageOpacity: 0.5,
  ///       actions: [
  ///         UICGridTileAction(
  ///           icon: Icons.wb_iridescent_rounded,
  ///           onPressed: () {},
  ///           backgroundColor: theme.colorScheme.surface
  ///         ),
  ///         
  ///         UICGridTileAction(
  ///           icon: Icons.abc,
  ///           onPressed: () {},
  ///           backgroundColor: theme.colorScheme.surface,
  ///         ),
  ///         
  ///         UICGridTileAction(
  ///           icon: Icons.warning_rounded, onPressed: () {},
  ///           backgroundColor: theme.colorScheme.warningSurface,
  ///           foregroundColor: theme.colorScheme.onWarningSurface,
  ///         ),
  ///       ],
  ///       title: UICGridTileTitle(
  ///         title: Text("$i test test test test test test test test"),
  ///         leading: const Icon(Icons.ac_unit),
  ///       ),
  ///     )
  ///   ]
  /// );
  /// ```
  const UICGrid({
    super.key,
    required this.items,
    required this.builder,
    this.onReorder,
    this.childAspectRatio = 1,
    this.viewMode = UICGridViewMode.list,
    this.scrollDirection = Axis.vertical,
  });

  /// The items that will be shown in the grid.
  final List<T> items;

  /// The builder that will be used to build the children.
  final Widget Function(BuildContext, T) builder;

  /// The function that will be called when the children are reordered.
  final Function(int, int)? onReorder;

  /// The aspect ratio of the children.
  final double childAspectRatio;

  /// The mode of the grid.
  final UICGridViewMode viewMode;

  /// The scroll direction of the grid.
  final Axis scrollDirection;

  @override
  State<UICGrid<T>> createState() => _UICGridState<T>();
}

class _UICGridState<T> extends State<UICGrid<T>> {
  late UICGridViewMode viewMode = widget.viewMode;
  final double _cacheExtent = 0;

  _UICGridState();

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    viewMode = widget.viewMode;
  }

  void _onReorder (int oldIndex, int newIndex) {
    widget.onReorder?.call(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if(viewMode == UICGridViewMode.grid) {
      if(widget.onReorder != null) {
        return UICMotionView(
          cacheExtent: _cacheExtent,
          longPressDelay: Duration.zero,
          padding: EdgeInsets.all(theme.defaultWhiteSpace),
          sliverGridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            crossAxisSpacing: theme.defaultWhiteSpace,
            mainAxisSpacing: theme.defaultWhiteSpace,
            childAspectRatio: widget.childAspectRatio,
          ),
          items: widget.items,
          scrollDirection: widget.scrollDirection,
          itemBuilder: widget.builder,
          onReorder: _onReorder,
          insertDuration: const Duration(milliseconds: 300),
          removeDuration: const Duration(milliseconds: 200),
          proxyDecorator: (Widget child, int index, Animation<double> animation) => _ProxyDecorator(
            child: child,
            index: index,
            animation: animation,
            theme: theme,
          ),
        );
      } else {
        return GridView.builder(
          cacheExtent: _cacheExtent,
          padding: EdgeInsets.all(theme.defaultWhiteSpace),
          scrollDirection: widget.scrollDirection,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisExtent: 200,
            crossAxisSpacing: theme.defaultWhiteSpace,
            mainAxisSpacing: theme.defaultWhiteSpace,
            childAspectRatio: widget.childAspectRatio,
          ),
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) => widget.builder(context, widget.items[index]),
        );
      }
    } else {
      if(widget.onReorder != null) {
        return UICMotionView(
          cacheExtent: _cacheExtent,
          longPressDelay: Duration.zero,
          padding: EdgeInsets.all(theme.defaultWhiteSpace),
          scrollDirection: widget.scrollDirection,
          items: widget.items,
          itemBuilder: widget.builder,
          onReorder: _onReorder,
          insertDuration: const Duration(milliseconds: 300),
          removeDuration: const Duration(milliseconds: 300),
          separator: const UICSpacer(),
          proxyDecorator: (Widget child, int index, Animation<double> animation) => _ProxyDecorator(
            child: child,
            index: index,
            animation: animation,
            theme: theme,
          ),
        );
      } else {
        return ListView.separated(
          scrollDirection: widget.scrollDirection,
          separatorBuilder: (context, index) => const UICSpacer(),
          cacheExtent: _cacheExtent,
          padding: EdgeInsets.all(theme.defaultWhiteSpace),
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) => widget.builder(context, widget.items[index]),
        );
      }
    }
  }
}

class _ProxyDecorator extends StatelessWidget {
  final Widget child;
  final int index;
  final Animation<double> animation;
  final ThemeData theme;

  const _ProxyDecorator({
    required this.child,
    required this.index,
    required this.animation,
    required this.theme
  });

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = 1 - .1 * Curves.easeInOut.transform(animation.value);
      return Transform.scale(
        scaleX: animValue,
        scaleY: animValue,
        child: Container(
          child: child,
          clipBehavior: Clip.hardEdge,
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
            color: theme.colorScheme.surface,
            boxShadow: [BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: .75),
              blurRadius: 8 * animation.value,
            )],
          ),
        ),
      );
    },
    child: child,
  );
}

class UICGridTile extends StatefulWidget {
  static _UICGridTileState of(BuildContext context) {
    final _UICGridTileState? result = context.findAncestorStateOfType<_UICGridTileState>();
    if(result != null) {
      return result;
    } else {
      throw Exception("UICGridTile.of() called with a context that does not contain a UICGridTile.");
    }
  }
  /// A widget that can be used as a tile in a [UICGrid].
  ///
  /// The tile can have a background image, a border color, a background color, and actions.
  /// The [actions] can be any widget, but [UICGridTileAction] is provided to make it easier to add actions.
  /// The [title] is a widget that can be used to show the title of the tile.
  /// The [backgroundImage] is an [ImageProvider] that will be used as the background image of the tile.
  /// The [borderColor] is the color of the border around the tile.
  /// The [backgroundColor] is the color of the background of the tile.
  /// The [backgroundImageOpacity] is the opacity of the background image.
  /// The [actions] are the actions that will be shown on the tile.
  /// The [onTap] is the function that will be called when the tile is pressed.
  ///
  /// Example:
  /// ```dart
  /// UICGridTile(
  ///   backgroundImage: const AssetImage("assets/images/devices/shutter.jpeg"),
  ///   backgroundImageOpacity: 0.5,
  ///   actions: [
  ///     UICGridTileAction(
  ///       icon: Icons.wb_iridescent_rounded,
  ///       onPressed: () {},
  ///       backgroundColor: theme.colorScheme.surface
  ///     ),
  ///     
  ///     UICGridTileAction(
  ///       icon: Icons.abc,
  ///       onPressed: () {},
  ///       backgroundColor: theme.colorScheme.surface,
  ///     ),
  ///     
  ///     UICGridTileAction(
  ///       icon: Icons.warning_rounded, onPressed: () {},
  ///       backgroundColor: theme.colorScheme.warningSurface,
  ///       foregroundColor: theme.colorScheme.onWarningSurface,
  ///     ),
  ///   ],
  ///   title: UICGridTileTitle(
  ///     title: Text("test test test test test test test test test"),
  ///     leading: const Icon(Icons.ac_unit),
  ///   ),
  /// )
  /// ```
  const UICGridTile({
    super.key,
    required this.title,
    this.backgroundImage,
    this.opacity = 1,
    this.borderColor,
    this.borderWidth = 1,
    this.backgroundColor,
    this.tintColor,
    this.actions = const [],
    this.backgroundImageOpacity = 1,
    this.onTap,
    this.body,
    this.bodyPadding = EdgeInsets.zero,
    this.elevation = 1,
    this.collapsible = false,
    this.collapsed = false,
    this.viewMode,
  });

  /// The title can be any widget, but [UICGridTileTitle] is provided to make it easier to add actions.
  final Widget title;

  /// The border color of the tile.
  final Color? borderColor;

  final Color? tintColor;

  /// The background color of the tile.
  final Color? backgroundColor;

  /// The background image of the tile.
  final DecorationImage? backgroundImage;

  /// The opacity of the background image.
  final double backgroundImageOpacity;

  /// The actions that will be shown on the tile.
  final List<Widget> actions;

  final Function()? onTap;

  final double opacity;

  final double borderWidth;

  final Widget? body;

  final EdgeInsets bodyPadding;

  final double elevation;

  final bool collapsible;
  final bool collapsed;

  final UICGridViewMode? viewMode;

  @override
  State<UICGridTile> createState() => _UICGridTileState();
}

class _UICGridTileState extends State<UICGridTile> {
  late UICGridViewMode? viewMode = widget.viewMode ?? UICGrid.of(context)?.viewMode;
  
  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(context.mounted) {
      viewMode = widget.viewMode ?? UICGrid.of(context)?.viewMode;
    }
  }

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: widget.opacity,
    child: viewMode == UICGridViewMode.list
      ? _UICGridTileAsListItem(
        title: widget.title,
        borderColor: widget.borderColor,
        borderWidth: widget.borderWidth,
        backgroundColor: widget.backgroundColor,
        tintColor: widget.tintColor,
        actions: widget.actions,
        onTap: widget.onTap,
        body: widget.body,
        bodyPadding: widget.bodyPadding,
        elevation: widget.elevation,
      )
      : _UICGridTileAsGridItem(
        title: widget.title,
        borderColor: widget.borderColor,
        borderWidth: widget.borderWidth,
        backgroundColor: widget.backgroundColor,
        tintColor: widget.tintColor,
        actions: widget.actions,
        backgroundImage: widget.backgroundImage,
        onTap: widget.onTap,
        body: widget.body,
        bodyPadding: widget.bodyPadding,
        elevation: widget.elevation,
        collapsed: widget.collapsed,
        collapsible: widget.collapsible,
      ),
  );
}

class _UICGridTileAsGridItem extends StatelessWidget {
  final Widget title;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? tintColor;
  final List<Widget> actions;
  final DecorationImage? backgroundImage;
  final Function()? onTap;
  final double borderWidth;
  final Widget? body;
  final EdgeInsets bodyPadding;
  final double elevation;
  final bool collapsible;
  final bool collapsed;

  final controller = ExpansibleController();

  _UICGridTileAsGridItem({
    required this.title,
    required this.borderWidth,
    this.borderColor,
    this.backgroundColor,
    this.tintColor,
    this.actions = const [],
    this.backgroundImage,
    this.onTap,
    this.body,
    this.bodyPadding = EdgeInsets.zero,
    this.elevation = 1,
    this.collapsible = false,
    this.collapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primaryContainer,
          width: borderWidth
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
        color: backgroundColor ?? theme.colorScheme.surface,
        image: backgroundImage,
        boxShadow: [
          if(elevation > 0) BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        elevation: backgroundImage != null ? 0 : elevation,
        // borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
        surfaceTintColor: backgroundImage != null ? Colors.transparent : theme.colorScheme.surfaceTint,
        color: backgroundImage != null ? Colors.transparent : theme.colorScheme.surface,
        child: InkWell(
          splashColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
          overlayColor: WidgetStatePropertyAll(theme.colorScheme.primaryContainer.withValues(alpha: 0.2)),
          onTap: onTap,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // if(!collapsible) title,
                if(!collapsible) title,

                if (body != null && collapsible) ExpansionTileTheme(
                  data: ExpansionTileThemeData(
                    shape: const Border(),
                    tilePadding: EdgeInsets.only(right: theme.defaultWhiteSpace),
                    iconColor: theme.colorScheme.onSurface,
                    textColor: theme.colorScheme.onSurface,
                    collapsedIconColor: theme.colorScheme.onSurface,
                    collapsedTextColor: theme.colorScheme.onSurface,
                  ),
                  child: ExpansionTile(
                    visualDensity: VisualDensity.compact,
                    dense: true,
                    initiallyExpanded: !collapsed,
                    controller: controller,
                    title: title,
                    children: [
                      Padding(
                        padding: bodyPadding,
                        child: body!,
                      )
                    ],
                  ),
                )
                else if(!collapsible && body == null) Expanded(
                  child: Container()
                ) 
                else if(!collapsible && body != null) Padding(
                  padding: bodyPadding,
                  child: body!,
                ),

                if(actions.isNotEmpty) Padding(
                  padding: EdgeInsets.all(theme.defaultWhiteSpace / 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var action in actions) Padding(
                        padding: action == actions.first
                          ? EdgeInsets.zero
                          : EdgeInsets.only(left: theme.defaultWhiteSpace / 2),
                        child: action,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}

class _UICGridTileAsListItem extends StatelessWidget {
  final Widget title;
  final Color? borderColor;
  final Color? tintColor;
  final Color? backgroundColor;
  final List<Widget> actions;
  final Function()? onTap;
  final double borderWidth;
  final Widget? body;
  final EdgeInsets bodyPadding;
  final double elevation;

  const _UICGridTileAsListItem({
    required this.title,
    this.borderColor,
    this.backgroundColor,
    this.tintColor,
    this.actions = const [],
    required this.borderWidth,
    this.onTap,
    this.body,
    this.bodyPadding = EdgeInsets.zero,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    /// Widget is in overlay context - there is no parent UICGrid, this means the item is dragging
    final theme = Theme.of(context);
    return Container(
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primaryContainer,
          width: borderWidth
        ),
      ),
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(theme.defaultWhiteSpace),
        color: backgroundColor ?? (theme.colorScheme.surface),
        child: InkWell(
          onTap: onTap,
          child: Row (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const UICSpacer(),
          
              Expanded(child: title),
          
              Padding(
                padding: EdgeInsets.all(theme.defaultWhiteSpace),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var action in actions) Padding(
                      padding: action == actions.first
                        ? EdgeInsets.zero
                        : EdgeInsets.only(left: theme.defaultWhiteSpace),
                      child: action,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}


class UICGridTileAction extends StatelessWidget {
  /// A widget that can be used as an action in a [UICGridTile].
  ///
  /// The action can have an icon, a background color, and a foreground color.
  /// The [child] is the icon that will be shown on the action.
  /// The [onPressed] is the function that will be called when the action is pressed.
  ///
  /// Example:
  /// ```dart
  /// UICGridTileAction(
  ///   icon: Icons.warning_rounded, onPressed: () {},
  ///   backgroundColor: theme.colorScheme.warningSurface,
  ///   foregroundColor: theme.colorScheme.onWarningSurface,
  /// )
  /// ```
  UICGridTileAction({
    super.key,
    required this.child,
    this.onPressed,
    this.style = UICColorScheme.none,
    this.tooltip,
    this.size = 24,
  });

  /// The icon that will be shown on the action.
  final Widget child;

  /// The function that will be called when the action is pressed.
  final Function()? onPressed;

  final UICColorScheme style;

  final String? tooltip;
  final tooltipState = GlobalKey<TooltipState>();
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if(tooltip != null) {
      return Tooltip(
        key: tooltipState,
        triggerMode: TooltipTriggerMode.manual,
        showDuration: const Duration(seconds: 0),
        message: tooltip,
        child: IconButton(
          style: (
            style == UICColorScheme.error   ? theme.errorIconButtonStyle :
            style == UICColorScheme.warn    ? theme.warnIconButtonStyle :
            style == UICColorScheme.variant ? theme.variantIconButtonStyle :
            style == UICColorScheme.success ? theme.successIconButtonStyle :
                                              theme.defaultIconButtonStyle
          ).copyWith(
            padding: WidgetStatePropertyAll(EdgeInsets.all(size / 2.4)),
            iconSize: WidgetStatePropertyAll(size)
          ),
          onPressed: onPressed,
          icon: child,
        ),
      );
    } else {
      return IconButton(
        style: (
          style == UICColorScheme.error   ? theme.errorIconButtonStyle :
          style == UICColorScheme.warn    ? theme.warnIconButtonStyle :
          style == UICColorScheme.variant ? theme.variantIconButtonStyle :
          style == UICColorScheme.success ? theme.successIconButtonStyle :
                                            theme.defaultIconButtonStyle
        ).copyWith(
          padding: WidgetStatePropertyAll(EdgeInsets.all(size / 2.4)),
          iconSize: WidgetStatePropertyAll(size)
        ),
        onPressed: onPressed,
        icon: child,
      );
    }
  }
}


class UICGridTileTitle extends StatelessWidget {
  /// A widget that can be used as a title in a [UICGridTile].
  ///
  /// The title can have a leading widget, a title, and a trailing widget.
  /// The [leading] is a widget that will be shown at the beginning of the title.
  /// The [title] is a widget that will be shown as the title of the tile.
  /// The [trailing] is a widget that will be shown at the end of the title.
  ///
  /// Example:
  /// ```dart
  /// UICGridTileTitle(
  ///   title: Text("test test test test test test test test test"),
  ///   leading: const Icon(Icons.ac_unit),
  /// )
  /// ```
  const UICGridTileTitle({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.padding,
    this.margin,
    this.borderRadius,
  });
  
  /// The widget that will be shown at the beginning of the title.
  final Widget? leading;

  /// The widget that will be shown as the title of the tile.
  final Widget? title;

  /// The widget that will be shown at the end of the title.
  final Widget? trailing;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewMode = UICGridTile.of(context).viewMode;
    final foreground = foregroundColor ?? (viewMode == UICGridViewMode.list
      ? theme.colorScheme.onSurface
      : theme.colorScheme.onPrimaryContainer);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(
          iconTheme: IconThemeData(
            color: foreground,
            size: 24
          )
        ),
        child: Material(
          color: viewMode == UICGridViewMode.list
              ? Colors.transparent
              : backgroundColor ?? theme.colorScheme.primaryContainer,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          elevation: elevation,
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          child: Padding(
            padding: padding ?? (viewMode == UICGridViewMode.list
              ? EdgeInsets.zero
              : EdgeInsets.all(theme.defaultWhiteSpace)),
            child: DefaultTextStyle(
              style: TextStyle(
                color: foreground,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (leading != null) leading!,
                  if (leading != null) UICSpacer(),
                  
                  if (title != null || viewMode == UICGridViewMode.grid)
                    Expanded(
                      child: DefaultTextStyle.merge(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        child: title!,
                      ),
                    )
                  else Expanded(
                    child: DefaultTextStyle.merge(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      child: title!,
                    ),
                  ),
                      
                  if (trailing != null) UICSpacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
