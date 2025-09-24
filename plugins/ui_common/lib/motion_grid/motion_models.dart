part of ui_common;

enum _UICMotionState {
  incomming, stable, drag, dragEnd
}

class _UICMotionClone {
  OverlayEntry? overlayEntry;
  final GlobalKey<_UICMotionDragItemState> key = GlobalKey();
}

class _UICHitTestResult {
  final bool hit;
  final Offset offset;
  _UICHitTestResult({
    required this.hit,
    this.offset = Offset.zero
  });
}

class _UICListInfo<E> {
  bool waitForUpdate = false;
  final List<_UICMotionData<E>> items;
  final List<_UICMotionData<E>> cache = [];
  final Function (int oldIndex, int? newIndex) onReorder;
  final Duration? insertDuration;
  final Duration? removeDuration;
  final _UICMotionSliverState vsync;

  _UICListInfo({
    required this.items,
    required this.onReorder,
    required this.vsync,
    this.insertDuration,
    this.removeDuration,
  });
}

class _UICMotionData<E> {
  final E?                data;
  final _UICListInfo<E>   list;

  Offset?                 pointerOffsetStart;
  Offset?                 pointerOffsetLocal;
  Offset?                 endOffset;
  Offset?                 startOffset;
  Size?                   size;
   
   
  AnimationController?    animationController;
  Animation<double>?      animation;

  _UICMotionItemState?    contentState;
  _UICMotionState         motionState;
  _UICMotionClone?        clone;
  _UICMotionData<E>?      wantUpdate;

  _UICMotionData({
    required this.list,
    this.data,
    this.motionState = _UICMotionState.incomming,
  });

  int? hitTest (PointerEvent event) {
    // for(int i = 0; i < list.items.length; i++) {
    //   final result = list.items[i].contentState?.hitTest(event);
    //   if(result?.hit == true) {
    //     return i;
    //   }
    // }
    return null;
  }

  void setAnimationController () {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: list.vsync,
    );
  }

  Offset? getOffset () {
    if(contentState?.mounted == true) {
      startOffset = endOffset;
      final box = contentState?.context.findRenderObject() as RenderBox?;
      endOffset = box?.localToGlobal(Offset.zero);
      startOffset = startOffset ?? endOffset;
    } else {
      endOffset = null;
    }
    // print("OFFSET: ${endOffset} $data");
    return endOffset;

  }

}
