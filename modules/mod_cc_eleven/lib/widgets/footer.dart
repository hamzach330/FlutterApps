part of "../module.dart";

class CCElevenFooter extends StatefulWidget {
  const CCElevenFooter({
    super.key,
  });

  @override
  State<CCElevenFooter> createState() => _CCElevenFooterState();
}

class _CCElevenFooterState extends State<CCElevenFooter> {
  late final cc = context.read<CCEleven>();

  final locations = const [
    CCElevenHome.path,
    CCElevenClocks.path,
    CCElevenSunProtection.path,
    CCSettings.path,
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final otaAvailable = CCSettings.getOtaForCC11(context) != null;
    return NavigationBar(
      onDestinationSelected: (int index) {
        UICScaffold.of(context).hideSecondaryBody();
        final cp = context.read<CentronicPlus>();
        cp.unselectNodes();
        if(selectedIndex != index) {
          context.go(locations[index]);
          setState(() {
            selectedIndex = index;
          });
        }
      },
      selectedIndex: selectedIndex,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_rounded),
          label: "Home".i18n,
        ),

        NavigationDestination(
          icon: Icon(Icons.access_time_rounded),
          label: "Uhren".i18n,
        ),

        NavigationDestination(
          icon: Icon(Icons.wb_sunny_rounded),
          label: "Sonne".i18n,
        ),

        NavigationDestination(
          icon: otaAvailable ? UICBadge(
            label: Icon(Icons.upgrade_rounded, size: 12, color: Theme.of(context).colorScheme.successVariant.onPrimary),
            backgroundColor: Theme.of(context).colorScheme.successVariant.primary,
            child: Icon(Icons.settings_rounded)
          ) : Icon(Icons.settings_rounded),
          label: "System".i18n,
        ),
      ],
    );
  }
}
