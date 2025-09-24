part of ui_common;

class UICMotionView<E> extends StatelessWidget {
  final List<E> items;
  final ItemBuilder<E> itemBuilder;
  final Duration? insertDuration;
  final Duration? removeDuration;
  final ReorderCallback onReorder;
  final void Function(int)? onReorderStart;
  final void Function(int)? onReorderEnd;
  final Axis scrollDirection;
  final ReorderItemProxyDecorator? proxyDecorator;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollBehavior? scrollBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final DragStartBehavior dragStartBehavior;
  final Duration longPressDelay;
  final double cacheExtent;
  final Widget separator;
  final SliverGridDelegate? sliverGridDelegate;

  const UICMotionView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.insertDuration,
    this.removeDuration,
    this.onReorderStart,
    this.onReorderEnd,
    this.proxyDecorator,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.longPressDelay = kLongPressTimeout,
    this.cacheExtent = 0,
    this.separator = const SizedBox(),
    this.sliverGridDelegate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      scrollBehavior: scrollBehavior,
      restorationId: restorationId,
      keyboardDismissBehavior: keyboardDismissBehavior,
      dragStartBehavior: dragStartBehavior,
      clipBehavior: clipBehavior,
      cacheExtent: cacheExtent,
      shrinkWrap: false,
      slivers: [
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: UICMotionSliver<E>(
            items: items,
            itemBuilder: itemBuilder,
            insertDuration: insertDuration,
            removeDuration: removeDuration,
            onReorder: onReorder,
            onReorderStart: onReorderStart,
            onReorderEnd: onReorderEnd,
            proxyDecorator: proxyDecorator,
            scrollDirection: scrollDirection,
            longPressDelay: longPressDelay,
            separator: separator,
            sliverGridDelegate: sliverGridDelegate,
          )
        )
      ]
    );
  }
}


typedef ItemBuilder<E> = Widget Function(BuildContext context, E item);

class UICMotionSliver<E> extends StatefulWidget {
  final ReorderCallback? onReorder;
  final void Function(int index)? onReorderStart;
  final void Function(int index)? onReorderEnd;

  final ReorderItemProxyDecorator? proxyDecorator;
  final ItemBuilder<E> itemBuilder;
  final int initialCount;
  final Axis scrollDirection;
  final Duration longPressDelay;
  final Widget separator;
  final List<E> items;
  final Duration? insertDuration;
  final Duration? removeDuration;
  final SliverGridDelegate? sliverGridDelegate;

  const UICMotionSliver({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onReorder,
    this.onReorderEnd,
    this.onReorderStart,
    this.proxyDecorator,
    this.initialCount = 0,
    this.scrollDirection = Axis.vertical,
    this.longPressDelay = kLongPressTimeout,
    this.insertDuration,
    this.sliverGridDelegate,
    this.removeDuration,
    this.separator = const SizedBox(height: 0),
  }) : assert(initialCount >= 0);

  @override
  State<UICMotionSliver<E>> createState() => _UICMotionSliverState<E>();
}

class _UICMotionSliverState<E> extends State<UICMotionSliver<E>> with TickerProviderStateMixin {
  List<_UICMotionData<E>> oldList = [];
  late final resizeAnimController = AnimationController(vsync: this);

  final List<_UICMotionData<E>> items = [];
  final List<_UICMotionData> oldIitems = [];

  late final info = _UICListInfo<E>(
    items: items,
    onReorder: _onReorder,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    items..clear()..addAll(widget.items.map((item) => _UICMotionData<E>(
      data: item,
      list: info,
    )));
    oldList = List.from(items);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setItems(oldList, widget.items);
    oldList = List.from(items);
  }

  void _onReorder(int oldIndex, int? newIndex) {
    if (newIndex != null) {
      final oldItem = items.removeAt(oldIndex);
      items.insert(newIndex, oldItem);
      widget.onReorder?.call(oldIndex, newIndex);
      setState(() {});
    }
  }

  void setItems(List<_UICMotionData<E>> oldList, List<E> newList) {
    // for (final oldItem in oldList) {
    //   if (newList.firstWhereOrNull((item) => item == oldItem.data) == null) {
    //     items.remove(oldItem);
    //   }
    // }

    // for (int i = 0; i < newList.length; i++) {
    //   final newItem = newList[i];
    //   final updateItem = oldList.firstWhereOrNull((item) => item.data == newItem);

    //   if (updateItem == null) {
    //     items.insert(i, MotionData(
    //       insertDuration: widget.insertDuration,
    //       removeDuration: widget.insertDuration,
    //       vsync: this,
    //       data: newItem,
    //       info: info,
    //       motionState: MotionState.incomming,
    //       onReorder: _onReorder,
    //       items: items
    //     ));
    //   } else {
    //     updateItem.items = items;
    //   }
    // }

    items..clear()..addAll(widget.items.map((itemData) => _UICMotionData<E>(
      data: itemData,
      list: info,
    )));
    oldList = List.from(items);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.sliverGridDelegate != null
      ? SliverGrid.builder(
        itemCount: items.length + 1,
        gridDelegate: widget.sliverGridDelegate!,
        itemBuilder: _itemBuilder
      ) : SliverList.separated(
        itemCount: items.length + 1,
        separatorBuilder: (context, index) => widget.separator,
        itemBuilder: _itemBuilder
      );
  }

  Widget _itemBuilder(BuildContext context, int index) {

    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    final capturedThemes = InheritedTheme.capture(from: context, to: overlay.context);

    if(index == items.length) {
      return _UICMotionItem(
        motionData: _UICMotionData(
          motionState: _UICMotionState.incomming,
          list: info,
        ),
        capturedThemes: capturedThemes,
        child: Container(),
      );
    }

    return _UICMotionItem(
      motionData: items[index],
      capturedThemes: capturedThemes,
      child: widget.itemBuilder(context, items[index].data!),
    );
  }
}
