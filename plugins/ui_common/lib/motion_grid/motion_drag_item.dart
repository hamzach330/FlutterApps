part of ui_common;

class _UICMotionDragItem extends StatefulWidget {
  final _UICMotionData motionData;
  final Widget child;

  const _UICMotionDragItem({
    super.key,
    required this.motionData,
    required this.child
  });

  @override
  State<_UICMotionDragItem> createState() => _UICMotionDragItemState();
}

class _UICMotionDragItemState extends State<_UICMotionDragItem> {
  updatePosition () => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      width: widget.motionData.size?.width,
      height: widget.motionData.size?.height,
      child: IgnorePointer(
        ignoring: true,
        child: Transform.translate(
          offset: (widget.motionData.pointerOffsetStart ?? Offset.zero) - (widget.motionData.pointerOffsetLocal ?? Offset.zero),
          child: widget.child
        ),
      ),
    );
  }
}
