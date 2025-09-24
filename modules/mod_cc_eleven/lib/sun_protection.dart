part of 'module.dart';

class CCElevenSunProtection extends StatefulWidget {
  static const path = '${CCElevenHome.path}/groups';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: const CCElevenSunProtection(),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: CCElevenSunProtection(),
    ),
  );

  static go (BuildContext context) {
    UICScaffold.of(context).hideSecondaryBody();
    context.go(path);
  }

  const CCElevenSunProtection({
    super.key,
  });

  @override
  State<CCElevenSunProtection> createState() => _CCElevenSunProtectionState();
}

class _CCElevenSunProtectionState extends State<CCElevenSunProtection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UICPage(
      slivers: [
        UICPinnedHeader(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UICTitle("Sonnenschutz".i18n),
            ],
          ),
          trailing: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: theme.defaultWhiteSpace * 1.5, vertical: theme.defaultWhiteSpace),
              backgroundColor: theme.colorScheme.successVariant.primaryContainer,
              foregroundColor: theme.colorScheme.successVariant.onPrimaryContainer,
              elevation: 2,
            ),
            onPressed: () {},
            child: Row(
              children: [
                Text("Aktiv".i18n),
                const UICSpacer(),
                Icon(Icons.wb_sunny_outlined, size: 16, color: theme.colorScheme.successVariant.onPrimaryContainer),
              ],
            ),
          ),
        ),
        CPOwnNodes(
          padding: EdgeInsets.zero,
          showControls: true,
          extraFilter: (CentronicPlusNode node) => node.isDrive && node.visible,
          onSelect: (CentronicPlusNode node) {
            CPNodeSunProtectionView.go(context, node);
          },
        ),
      ],
    );
  }
}
