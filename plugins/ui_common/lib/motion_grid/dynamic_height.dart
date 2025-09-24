part of ui_common;

/// GridView with dynamic height
///
/// Usage is almost same as [GridView.count]
/// FIXME: This should be a constructor or something of UICGrid
class UICDynamicHeightGridView extends StatelessWidget {
  const UICDynamicHeightGridView({
    Key? key,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    this.crossAxisSpacing = 8,
    this.mainAxisSpacing = 8,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
    this.dividers = false,
  }) : super(key: key);
  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final CrossAxisAlignment rowCrossAxisAlignment;

  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool shrinkWrap;
  final bool dividers;

  int columnLength() {
    if (itemCount % crossAxisCount == 0) {
      return itemCount ~/ crossAxisCount;
    } else {
      return (itemCount ~/ crossAxisCount) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemBuilder: (ctx, columnIndex) {
        return _GridRow(
          columnIndex: columnIndex,
          builder: builder,
          itemCount: itemCount,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisAlignment: rowCrossAxisAlignment,
          dividers: dividers,
        );
      },
      itemCount: columnLength(),
    );
  }
}

/// Use this for [CustomScrollView]
class SliverUICDynamicHeightGridView extends StatelessWidget {
  const SliverUICDynamicHeightGridView({
    Key? key,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    this.dividers = false,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.rowCrossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
  }) : super(key: key);
  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final ScrollController? controller;
  final bool dividers;

  int columnLength() {
    if (itemCount % crossAxisCount == 0) {
      return itemCount ~/ crossAxisCount;
    } else {
      return (itemCount ~/ crossAxisCount) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, columnIndex) {
          return _GridRow(
            columnIndex: columnIndex,
            builder: builder,
            itemCount: itemCount,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing ?? theme.defaultWhiteSpace,
            mainAxisSpacing: mainAxisSpacing ?? theme.defaultWhiteSpace,
            crossAxisAlignment: rowCrossAxisAlignment,
            dividers: dividers,
          );
        },
        childCount: columnLength(),
      ),
    );
  }
  
  factory SliverUICDynamicHeightGridView.children({
    required List<Widget> children,
    required int crossAxisCount,
    double? crossAxisSpacing,
    double? mainAxisSpacing,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.start,
    ScrollController? controller,
    bool dividers = false,
  }) {
    return SliverUICDynamicHeightGridView(
      itemCount: children.length,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      rowCrossAxisAlignment: rowCrossAxisAlignment,
      controller: controller,
      dividers: dividers,
      builder: (context, index) {
        return children[index];
      },
    );
  }
}

class _GridRow extends StatelessWidget {
  const _GridRow({
    Key? key,
    required this.columnIndex,
    required this.builder,
    required this.itemCount,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.crossAxisAlignment,
    required this.dividers
  }) : super(key: key);
  final IndexedWidgetBuilder builder;
  final int itemCount;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final int columnIndex;
  final bool dividers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: (columnIndex == 0) ? 0 : mainAxisSpacing,
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: List.generate(
          (crossAxisCount * 2) - 1,
          (rowIndex) {
            final rowNum = rowIndex + 1;
            if (rowNum % 2 == 0) {
              if(dividers) {
                return SizedBox(
                  width: crossAxisSpacing,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                  ),
                );
              }
              return SizedBox(width: crossAxisSpacing);
            }
            final rowItemIndex = ((rowNum + 1) ~/ 2) - 1;
            final itemIndex = (columnIndex * crossAxisCount) + rowItemIndex;
            if (itemIndex > itemCount - 1) {
              return const Expanded(child: SizedBox());
            }
            return Expanded(
              child: builder(context, itemIndex),
            );
          },
        ),
      ),
    );
  }
}