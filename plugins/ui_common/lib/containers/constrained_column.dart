part of ui_common;

class UICConstrainedColumn extends StatelessWidget {

  final List<Widget> children;
  final double maxWidth;
  const UICConstrainedColumn({super.key, required this.children, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for(final child in children) SizedBox(
              width: maxWidth,
              child: child
            )
        
          ],
        ),
      ),
    );
  }
}