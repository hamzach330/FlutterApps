part of '../module.dart';

class TCFooter extends StatefulWidget {
  const TCFooter({
    super.key,
  });

  @override
  State<TCFooter> createState() => _TCFooterState();
}

class _TCFooterState extends State<TCFooter> {
  final locations = const [
    TCHome.path,
    TimecontrolClocksView.path,
    TimecontrolSunProtectionView.path,
    TimecontrolSystemView.path,
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        // UICScaffold.of(context).hideSecondaryBody();
        if(selectedIndex != index) {
          context.go(locations[index]);
          setState(() {
            selectedIndex = index;
          });
        }
      },
      indicatorColor: Theme.of(context).primaryColor,
      selectedIndex: selectedIndex,
      destinations: [
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_rounded),
          label: 'Home'.i18n,
        ),

        NavigationDestination(
          icon: Icon(Icons.access_time_rounded),
          label: "Uhren".i18n,
        ),

        NavigationDestination(
          icon: Icon(Icons.wb_sunny_rounded),
          label: 'Sonnenschutz'.i18n,
        ),

        NavigationDestination(
          icon: Icon(Icons.settings_rounded),
          label: 'System'.i18n,
        ),
      ],
    );
  }
}
