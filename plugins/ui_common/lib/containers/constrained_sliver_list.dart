part of ui_common;

class UICConstrainedSliverList extends StatelessWidget {

  final List<Widget> children;
  final double maxWidth;
  const UICConstrainedSliverList({super.key, required this.children, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: children[index],
            ),
          );
        },
        childCount: children.length,
      ),
    );
  }
}