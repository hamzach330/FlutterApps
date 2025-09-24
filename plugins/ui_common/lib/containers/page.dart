part of ui_common;

class UICPage extends StatefulWidget {
  final List<Widget> slivers;
  final bool loading;
  final EdgeInsets? padding;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const UICPage({
    super.key,
    this.slivers = const [],
    this.loading = false,
    this.padding,
    this.floatingActionButton,
    this.floatingActionButtonLocation
  });

  @override
  State<UICPage> createState() => _UICPageState();
}

class _UICPageState extends State<UICPage> {
  @override
  didUpdateWidget(UICPage oldWidget) {
    super.didUpdateWidget(oldWidget);

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background gradient (positioned, not scrolling)
          Positioned.fill(
            child: Container(
              color: theme.colorScheme.surface, // Base background color
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.8), // Top center - brightest
                    radius: 0.9,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.35),
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.8, -0.3), // Top-right - secondary light
                      radius: 0.75,
                      colors: [
                        theme.colorScheme.secondary.withValues(alpha: 0.25),
                        theme.colorScheme.secondary.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.6, 0.8), // Bottom-left - subtle shadow area
                        radius: 0.6,
                        colors: [
                          theme.colorScheme.tertiary.withValues(alpha: 0.15),
                          theme.colorScheme.tertiary.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(-0.9, -0.2), // Left side - accent light
                          radius: 0.7,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.6, 0.9), // Bottom-right - warm accent
                            radius: 0.8,
                            colors: [
                              theme.colorScheme.secondary.withValues(alpha: 0.18),
                              theme.colorScheme.secondary.withValues(alpha: 0.04),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if(widget.loading) Center(child: UICProgressIndicator.small()), 
          // Content with scrollable app bar
          if(!widget.loading) CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // if (widget.showAppBar) SliverPersistentHeader(
              //   pinned: true,
              //   delegate: _AppBarDelegate(
              //     theme: theme,
              //     title: widget.title,
              //     leading: widget.pop != null ? BackButton(onPressed: widget.pop) : widget.leading,
              //     actions: widget.appBarActions,
              //     statusBarHeight: MediaQuery.of(context).padding.top,
              //   ),
              // ),

              for (final sliver in widget.slivers)
                if(sliver is UICPinnedHeader == false) SliverPadding(
                  padding: widget.padding ?? EdgeInsets.all(theme.defaultWhiteSpace),
                  sliver: sliver,
                ) else sliver,
            ],
          ),
        ],
      ),
    );
  }
}

class UICPinnedHeader extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? body;
  final double height;
  final Color? backgroundColor;
  final bool floating;
  final bool pinned;
  final EdgeInsets? padding;
  final double? spacing;

  const UICPinnedHeader({
    super.key,
    this.leading,
    this.trailing,
    this.body,
    this.height = 60.0,
    this.backgroundColor,
    this.floating = false,
    this.pinned = true,
    this.padding,
    this.spacing
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultPadding = EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace);
    final actualPadding = padding ?? defaultPadding;

    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _UICPinnedHeaderDelegate(
        child: Row(
          spacing: spacing ?? theme.defaultWhiteSpace,
          children: [
            if (leading != null) leading!,
            if (body != null) 
              Expanded(child: body!)
            else if (leading != null)
              const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
        height: height,
        padding: MediaQuery.of(context).padding + actualPadding,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class _UICPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;
  final EdgeInsets padding;
  final Color? backgroundColor;

  _UICPinnedHeaderDelegate({
    required this.child,
    required this.height,
    this.padding = EdgeInsets.zero,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / height).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final color = backgroundColor ?? theme.colorScheme.surface.withValues(alpha: 0.65 * progress);
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10.0 * progress, sigmaY: 10.0 * progress),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
          ),
          child: Padding(
            padding: padding,
            child: Container(
              height: height,
              child: child,
            ),
          ),
        ),
      ),
    );

  }

  @override
  double get maxExtent => height + padding.vertical;

  @override
  double get minExtent => height + padding.vertical;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

