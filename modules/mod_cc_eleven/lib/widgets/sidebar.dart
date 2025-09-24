part of '../module.dart';

class CCElevenSidebar extends StatefulWidget {
  const CCElevenSidebar({super.key});

  @override
  State<CCElevenSidebar> createState() => _CCElevenSidebarState();
}

class _CCElevenSidebarState extends State<CCElevenSidebar> {
  final locations = const [
    CCElevenHome.path,
    CCElevenClocks.path,
    CCElevenSunProtection.path,
    CCSettings.path,
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otaAvailable = CCSettings.getOtaForCC11(context) != null;
    
    return NavigationRail(
      selectedIndex: selectedIndex,
      groupAlignment: -1,
      labelType: NavigationRailLabelType.all,
      backgroundColor: theme.colorScheme.surfaceContainer,
      elevation: 1,
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

      leading: Container(
        margin: EdgeInsets.only(
          top: theme.defaultWhiteSpace,
          bottom: theme.defaultWhiteSpace * 3,
        ),
        child: ImageIcon(
          const AssetImage("assets/images/icon.png"),
          color: theme.colorScheme.onSurface,
          size: 48,
        ),
      ),

      trailing: Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed: () {
                context.read<CCElevenModule>().quit(context);
              },
              child: Icon(Icons.exit_to_app_rounded),
            ),
          ),
        ),
      ),
    
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.home_rounded),
          label: Text("Home".i18n),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.access_time_rounded),
          label: Text("Uhren".i18n),
        ),

        NavigationRailDestination(
          icon: Icon(Icons.wb_sunny_rounded),
          label: Text("Sonnenschutz".i18n),
        ),

        NavigationRailDestination(
          icon: otaAvailable ? UICBadge(
            label: Icon(Icons.upgrade_rounded, size: 12, color: Theme.of(context).colorScheme.successVariant.onPrimary),
            backgroundColor: Theme.of(context).colorScheme.successVariant.primary,
            child: Icon(Icons.settings_rounded)
          ) : Icon(Icons.settings_rounded),
          label: Text("System".i18n),
        ),
      ],
    );
  }
}
