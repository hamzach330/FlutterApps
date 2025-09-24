part of '../module.dart';

class CPOwnNodes extends StatefulWidget {
  final bool showControls;
  final bool Function (CentronicPlusNode)? extraFilter;
  final Function(CentronicPlusNode)? onSelect;
  final EdgeInsetsGeometry? padding;

  const CPOwnNodes({
    super.key,
    this.showControls = false,
    this.extraFilter,
    this.onSelect,
    this.padding,
  });

  @override
  State<CPOwnNodes> createState() => _CPOwnNodesState();
}

class _CPOwnNodesState extends State<CPOwnNodes> {
  late final centronicPlus = context.read<CentronicPlus>();
  late final otaInfo       = context.read<OtauInfoProvider>();
  late final settings      = context.read<CPExpandSettings>();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<CentronicPlus>(
      builder: (context, cp, _) {
        final items = cp.getOwnNodes().where(widget.extraFilter ?? (node) => true).toList();
        return SliverPadding(
          padding: widget.padding ?? EdgeInsetsGeometry.all(theme.defaultWhiteSpace),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 120,
              crossAxisSpacing: theme.defaultWhiteSpace,
              mainAxisSpacing: theme.defaultWhiteSpace,
              // childAspectRatio: 16 / 12,
            ),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) => Consumer<CentronicPlus>(
              builder: (context, centronicPlus, _) {
                return StreamProvider.value(
                  key: ValueKey(items[index].mac),
                  updateShouldNotify: (_, __) => true,
                  initialData: items[index],
                  value: items[index].updateStream.stream,
                  builder: (context, _) => Consumer<OtauInfoProvider>(
                    builder: (context, otauInfo, _) {
                      if(widget.showControls) {
                        return CPNodeUserTile(
                          showControls: false,
                          onSelect: widget.onSelect,
                        );
                      } else {
                        return CPNodeAdminTile(
                          onSelect: widget.onSelect
                        );
                      }
                    }
                  )
                );
              },
            )
          ),
        );
      }
    );
  }
}
