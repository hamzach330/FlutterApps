part of 'module.dart';

class CPHome extends StatefulWidget {
  static const path = '/centronic_plus';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
      child: const CPHome(),
    )
  );

  static go (BuildContext context) {
    context.go(path);
  }

  const CPHome({
    super.key,
  });

  @override
  State<CPHome> createState() => _CPHomeState();
}

class _CPHomeState extends State<CPHome> {
  late final centronicPlus = context.read<CentronicPlus>();
  late final scaffold = UICScaffold.of(context);
  late final theme = Theme.of(context);
  final filterController = TextEditingController();
  final menuController = MenuController();

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    // centronicPlus.multicast.getAllNodes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context); // DO NOT REMOVE. Force rebuild on window size change.
    dev.log("Rebuild: ${size.width}x${size.height}", name: "CPHome");
    return UICPage(
      // elevation: 0,
      // menu: true,
      // padding: EdgeInsets.zero,
      // title: "Home",
      // appBarActions: [
      //   if(scaffold.breakPointSML) Consumer<CentronicPlus>(
      //     builder: (context, cp, __) {
      //       if (cp.meshUpdatePending) {
      //         return Padding(
      //           padding: EdgeInsets.only(right: theme.defaultWhiteSpace),
      //           child: UICProgressIndicator(size: 14),
      //         );
      //       }

      //       return Container();
      //     }
      //   ),


        
      //   SizedBox(),
      // ],
      // pop: scaffold.breakPointLXLXXL ? null : () {
      //   context.read<CPModule>().quit(context);
      // },
      slivers: [
        UICPinnedHeader(
          body: UICTitle("Home".i18n),
          trailing: Row(
            children: [
              MenuAnchor(
                controller: menuController,
                menuChildren: [
                  SizedBox(
                    width: 300,
                    child: Padding(
                      padding: EdgeInsets.all(theme.defaultWhiteSpace * 0.5),
                      child: UICTextInput(
                        controller: filterController,
                        hintText: "Gerätename".i18n,
                        label: "Gerätename".i18n,
                        autofocus: true,
                        onClear: () {
                          filterController.clear();
                          menuController.close();
                          setState(() {/* No work */});
                        },
                        onEditingComplete: () {
                          menuController.close();
                          setState(() {/* No work */});
                        },
                        onChanged: (value) {
                          setState(() {/* No work */});
                        },
                      ),
                    ),
                  ),
                ],
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return IconButton(
                    tooltip: "Gerätenamen filtern".i18n,
                    icon: filterController.text.isEmpty ?
                      const Icon(Icons.filter_alt_rounded, size: 28) :
                      const Icon(Icons.filter_alt_off_rounded, size: 28),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
              ),

              IconButton(
                tooltip: "Neue Geräte finden und hinzufügen".i18n,
                icon: const Icon(Icons.add_box_outlined, size: 28),
                onPressed: () async {
                  await CPTeachinAlert.open(context, false);
                },
              ),
            ],
          ),
        ),

        CPOwnNodes(
          extraFilter:
              (node) =>
                  filterController.text.isEmpty
                      ? true
                      : node.name?.toLowerCase().contains(filterController.text.toLowerCase()) ?? false,
        ),
      ],
      // footer: const CPForeignNodes(),
    );
  }
}
