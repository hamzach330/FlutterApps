part of "../module.dart";

class CPFooter extends StatefulWidget {
  const CPFooter({
    super.key,
  });

  @override
  State<CPFooter> createState() => _CPFooterState();
}

class _CPFooterState extends State<CPFooter> {
  final locations = const [
    CPHome.path,
    CPHome.path,
    CPHome.path,
    CPHome.path,
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      elevation: 3,
      shadowColor: Theme.of(context).colorScheme.shadow,
      type: MaterialType.card,
      child: Row(
        children: [
          Expanded(
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 1,
              onDestinationSelected: (index) {
                final scaffold = UICScaffold.of(context);
                scaffold.hideSecondaryBody();
                if(index == 0) {
                  context.go(CPHome.path);
                  _selectedIndex = index;
                } else if(index == 1) {
                  MulticastControlAlert.open(context);
                }
              },
              
              // indicatorColor: Theme.of(context).primaryColor,
              selectedIndex: _selectedIndex,
            
              destinations: [
                NavigationDestination(
                  selectedIcon: Icon(Icons.home_rounded),
                  icon: Icon(Icons.home_rounded),
                  label: "Home".i18n,
                ),
            
                NavigationDestination(
                  icon: Icon(Icons.broadcast_on_personal_rounded),
                  label: "Global".i18n,
                ),
              ],
            ),
          ),
      
          SafeArea(child: Padding(
            padding: EdgeInsets.only(right: Theme.of(context).defaultWhiteSpace * 1.5),
            child: CPMenuMore(),
          )),
        ],
      ),
    );
  }
}
