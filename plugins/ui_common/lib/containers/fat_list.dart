part of ui_common;

class UICFatList<T> extends StatefulWidget {
  final String title;
  final String subTitle;
  final List<T> items;
  final Widget Function(BuildContext, T, Animation<double>) itemBuilder;
  final EdgeInsets? padding;

  UICFatList({
    super.key,
    required this.title,
    required this.subTitle,
    required this.items,
    required this.itemBuilder,
    this.padding
  });

  @override
  _UICFatListState<T> createState() => _UICFatListState<T>();
}

class _UICFatListState<T> extends State<UICFatList<T>> with TickerProviderStateMixin {
  
  late final _repeatingController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3)
  )..repeat();

  late final _oneshotController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1)
  );
  
  late final _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, -0.1),
  ).animate(CurvedAnimation(
    parent: _oneshotController,
    curve: Curves.easeOut,
  ));

  List<T> items      = [];
  final double _bubbleSize = 500;
  final _listAnimationKey  = GlobalKey<AnimatedListState>();


  @override
  void initState() {
    super.initState();
    items.addAll(widget.items);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAddedItems(oldItems: [], newItems: widget.items);
    });
  }
  
  @override
  void dispose() {
    _repeatingController.dispose();
    _oneshotController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleAddedItems(oldItems: items, newItems: widget.items);
    _handleRemovedItems(oldItems: items, newItems: widget.items);
    items..clear()..addAll(widget.items);
  }

  _handleRemovedItems({
    required List<T> oldItems,
    required List<T> newItems,
  }) {
    if(newItems.isEmpty) {
      _listAnimationKey.currentState?.removeAllItems((context, animation) {return Container();});
      _oneshotController.animateTo(0);
      _repeatingController.repeat();
    } else {
      for (final oldItem in oldItems) {
        if (!newItems.contains(oldItem)) {
          _listAnimationKey.currentState?.removeItem(
            oldItems.indexOf(oldItem),
            (context, animation) => widget.itemBuilder(context, oldItem, animation)
          );
        }
      }
    }
  }

  _handleAddedItems({
    required List<T> oldItems,
    required List<T> newItems,
  }) {
    for (var i = 0; i < newItems.length; i++) {
      if (!oldItems.contains(newItems[i])) {
        _listAnimationKey.currentState?.insertItem(i);
      }
    }

    if(newItems.isNotEmpty) {
      _oneshotController.animateTo(1);
      _repeatingController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: FadeTransition(
            opacity: ReverseAnimation(CurvedAnimation(
              parent: _repeatingController,
              curve: Curves.fastOutSlowIn,
            )),
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _repeatingController,
                curve: Curves.fastOutSlowIn,
              ),
              child: Container(
                width: _bubbleSize,
                height: _bubbleSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_bubbleSize),
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),

        Center(
          child: FadeTransition(
            opacity: ReverseAnimation(CurvedAnimation(
              parent: _oneshotController,
              curve: Curves.easeOut,
            )),
            child: SlideTransition(
              position: _offsetAnimation,
              child: SizedBox(
                height: _bubbleSize,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Theme.of(context).defaultWhiteSpace * 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(widget.title, style: Theme.of(context).textTheme.displaySmall),
                      const UICSpacer(2),
                      Text(widget.subTitle,textAlign: TextAlign.center)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Center(
          child: AnimatedList(
            padding: widget.padding ?? EdgeInsets.all(Theme.of(context).defaultWhiteSpace),
            shrinkWrap: true,
            key: _listAnimationKey,
            initialItemCount: 0,
            itemBuilder: (context, index, animation) => widget.itemBuilder(context, items[index], animation)
          ),
        ),
      
      ]
    );
  }
}
