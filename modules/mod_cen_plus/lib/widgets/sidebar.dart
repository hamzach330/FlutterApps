part of '../module.dart';



class CPSidebar extends StatefulWidget {
  const CPSidebar({super.key});

  @override
  State<CPSidebar> createState() => _CPSidebarState();
}

class _CPSidebarState extends State<CPSidebar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final railTheme = NavigationRailThemeData.of(context);
    // NavigationRailThemeData(

    // );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      elevation: 3,
      shadowColor: Theme.of(context).colorScheme.shadow,
      type: MaterialType.card,
      child: NavigationRail(
        selectedIndex: _selectedIndex,
        groupAlignment: -1,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Colors.transparent,
        onDestinationSelected: (index) {
          final scaffold = UICScaffold.of(context);
          if(index == 0) {
            scaffold.hideSecondaryBody();
            context.go(CPHome.path);
            _selectedIndex = index;
          } else if(index == 1) {
            MulticastControlAlert.open(context);
          }
        },
      
        leading: Consumer<CPExpandSettings>(
          builder: (context, expandSettings, child) {
            return GestureDetector(
              onTap: expandSettings.unlock,
              child: Container(
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
            );
          },
        ),
      
        trailing: Expanded(
          child: Column(
            children: [
              const CPMenuMore(),
              
              const Expanded(child: SizedBox()),
      
              Padding(
                padding: EdgeInsets.only(bottom: theme.defaultWhiteSpace),
                child: FloatingActionButton(
                  onPressed: () {
                    context.read<CPModule>().quit(context);
                  },
                  child: Icon(Icons.exit_to_app_rounded),
                ),
              ),
            ],
          ),
        ),
      
        destinations: [
          NavigationRailDestination(
            icon: Icon(Icons.home_rounded),
            label: Text("Home"),
          ),
      
          NavigationRailDestination(
            icon: Icon(Icons.broadcast_on_personal_rounded),
            label: Text("Global"),
          ),
        ],
      ),
    );
  }
}