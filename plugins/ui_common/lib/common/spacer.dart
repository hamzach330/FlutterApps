part of ui_common;

// class UICSpacer extends StatelessWidget {
//   final int rows;
//   const UICSpacer([int rows = 1]): this.rows = rows;
  
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(width: rows * Theme.of(context).defaultWhiteSpace);
//   }
// }

class UICSpacer extends StatelessWidget {
  final int cols;
  const UICSpacer([int cols = 1]) : this.cols = cols;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cols * Theme.of(context).defaultWhiteSpace,
      width: cols * Theme.of(context).defaultWhiteSpace
    );
  }
}