part of ui_common;

class _UICMotionItem<E> extends StatefulWidget {
  final _UICMotionData<E> motionData;
  final Widget child;
  final CapturedThemes? capturedThemes;

  const _UICMotionItem({
    super.key,
    required this.motionData,
    required this.child,
    required this.capturedThemes
  });

  @override
  State<_UICMotionItem<E>> createState() => _UICMotionItemState<E>();
}

class _UICMotionItemState<E> extends State<_UICMotionItem<E>> {
  final GlobalKey repaintBoundaryKey = GlobalKey();

  late _UICMotionData<E> motionData;
  _UICMotionData? dragData;
  Offset? animationStartOffest;

  Offset? startOffset;
  Offset? endOffset;

  RenderRepaintBoundary? repaintBoundary;
  int? dragOverIndex;

  @override
  void initState() {
    super.initState();
    motionData = widget.motionData;
    motionData.contentState = this;
    motionData.motionState = _UICMotionState.stable;

    motionData.setAnimationController();
    motionData.animationController?.addListener(animationListener);
    motionData.animationController?.addStatusListener(anmiationStatusListenr);

    final cachedItem = motionData.list.cache.where((item) => item.data == motionData.data);

    if(cachedItem.isEmpty && motionData.data != null) {
      motionData.list.cache.add(motionData);
      // print("INIT ADD TO CACHE ${motionData.data}");
    }

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   motionData.getOffset();
    //   print("INIT ITEM ${motionData.data} ${motionData.startOffset} => ${motionData.endOffset}");
    // });

  }

  _UICHitTestResult hitTest (PointerEvent event) {
    if(mounted) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      final Offset local = box.globalToLocal(event.position);
      final result = box.paintBounds.contains(local);
      return _UICHitTestResult(hit: result, offset: box.localToGlobal(Offset.zero));
    } else {
      return _UICHitTestResult(hit: false, offset: Offset.zero);
    }
  }

  void animationListener() {
    if(mounted) setState(() {});
  }

  void anmiationStatusListenr(AnimationStatus status) {
    if(status == AnimationStatus.completed) {
      // motionData.endOffset = itemOffset(motionData);
      motionData.startOffset = Offset.zero;
      motionData.endOffset = Offset.zero;
    }
  }

  @override
  void didUpdateWidget(covariant _UICMotionItem<E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if(oldWidget.motionData != widget.motionData) {
      final cachedItem = widget.motionData.list.cache.where((item) => item.data == widget.motionData.data);
      if(cachedItem.isNotEmpty) {
        // print("RELOAD CACHED ITEM ${cachedItem.first.data} ${cachedItem.first.endOffset}");
        motionData = cachedItem.first;
        motionData.getOffset(); // Get Start Offset
        motionData.contentState = this;
      } else {
        motionData.list.cache.add(motionData);
        // print("INIT BLIND DATA");
        motionData = widget.motionData;
        motionData.getOffset(); // Get Start Offset
        motionData.contentState = this;
      }


      motionData.getOffset(); // Get End Offset

      motionData.animationController?.dispose();
      motionData.setAnimationController();
      motionData.animationController?.addListener(animationListener);
      motionData.animationController?.addStatusListener(anmiationStatusListenr);
      motionData.animationController?.forward(from: 0.0);

      // if(cachedItem.isEmpty && motionData.data != null) {
      //   motionData.list.cache.add(motionData);
      //   print("UPDATE ADD TO CACHE ${motionData.data} ${motionData.endOffset} $oldWidget");
      // }

    } else {
      motionData = widget.motionData;
      motionData.contentState = this;
    }

    motionData.list.waitForUpdate = false;
  }

  Future<void> clone () async {
    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    var image = await repaintBoundary?.toImage();
    var byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData?.buffer.asUint8List();

    motionData.clone = _UICMotionClone();
    motionData.clone!.overlayEntry = OverlayEntry(builder: (context) {
      return _UICMotionDragItem(
        key: motionData.clone!.key,
        motionData: motionData,
        child: Image.memory(pngBytes!)
      );
    });
    overlay.insert(motionData.clone!.overlayEntry!);
  }

  Future<void> startDrag(PointerEvent event) async {
    repaintBoundary = context.findRenderObject() as RenderRepaintBoundary?;
    dragData = motionData;
    
    dragData!.motionState = _UICMotionState.drag;
    dragData!.pointerOffsetLocal = event.localPosition;
    dragData!.pointerOffsetStart = event.position;
    dragData!.getOffset();
    dragData!.size = repaintBoundary?.size;

    // print("END OFFSET ${dragData!.endOffset} ${motionData.endOffset} ${motionData.data}");
    
    await clone();
    
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() { });
    });
  }

  void moveDrag(PointerEvent event) {
    dragData?.clone?.key.currentState?.updatePosition();
    final index = dragData!.list.items.indexOf(dragData!);
    
    dragData!.pointerOffsetStart = event.position;
    dragOverIndex = dragData!.hitTest(event);

    if(dragOverIndex == null) {
      motionData.list.waitForUpdate = false;
    }

    if(dragOverIndex != index && motionData.list.waitForUpdate == false && dragOverIndex != null) {
      dragData!.list.onReorder(index, dragOverIndex);
      motionData.list.waitForUpdate = true;
    }

  }

  void stopDrag (PointerEvent event) {
    // print("STOP DRAG!");
    dragData?.motionState = _UICMotionState.dragEnd; // Missing set state for drag item
    dragData?.list.onReorder(0, 0);
    dragData?.clone?.overlayEntry?.remove();
    dragData = null;
    if(mounted) setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    // motionData.update();
    animationStartOffest = (motionData.startOffset ?? Offset.zero) - (motionData.endOffset ?? Offset.zero);
    // print("BUILD UPDATE ${motionData.data} ${motionData.startOffset} => ${motionData.endOffset}");
    if(motionData.motionState == _UICMotionState.drag) {
      return RepaintBoundary(
        key: repaintBoundaryKey,
        child: SizedBox(height: motionData.size?.height)
      );
    }
    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Listener(
        onPointerDown: startDrag,
        onPointerMove: moveDrag,
        onPointerCancel: stopDrag,
        onPointerUp: stopDrag,
        child: motionData.animationController == null ? widget.child : Transform.translate(
          offset: (animationStartOffest ?? Offset.zero) * (1 - (motionData.animationController?.value ?? 0)),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    motionData.list.cache.removeWhere((item) => item.data == motionData.data);
    motionData.startOffset = Offset.zero;
    motionData.endOffset = Offset.zero;
    motionData.animationController?.dispose();
    motionData.animationController = null;
    super.dispose();
  }
}
