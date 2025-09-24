part of 'module.dart';

class CPNodePresetsView extends StatelessWidget {
  static const pathName = 'presets';
  static const path = '${CPNodeAdminView.basePath}/:id/$pathName';

  static final route = GoRoute(
    path: path,
    pageBuilder: (context, state) => CustomTransitionPage(
      key: const ValueKey(path),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      child: const CPNodePresetsView(),
    )
  );

  static go (BuildContext context, CentronicPlusNode node) async {
    final scaffold = UICScaffold.of(context);
    scaffold.goSecondary(
      path: "${CPNodeAdminView.basePath}/${node.mac}/$pathName",
    );
  }
  
  const CPNodePresetsView({super.key});

  Future pop (BuildContext context) async {
    context.pop();
  }

  Future close (BuildContext context) async {
    final scaffold = UICScaffold.of(context);
    scaffold.hideSecondaryBody();
  }

  @override
  Widget build(BuildContext context) {
    return UICPage(
      slivers: [
        UICPinnedHeader(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          body: UICTitle("Zwischenpositionen".i18n),
        ),
        const SliverToBoxAdapter(child: CPNodeInfo(readOnly: true,)),

        Consumer<CentronicPlusNode>(
          builder: (context, node, _) {
            return UICConstrainedSliverList(
              maxWidth: 400,
              children: [
                const UICSpacer(2),
                Row(
                  children: [
                    UICBigMove(
                      onUp: node.sendUpCommand,
                      onStop: node.sendStopCommand,
                      onDown: node.sendDownCommand,
                      onRelease: () async {
                        node.sendStopCommand();
                        node.sendStopCommand();
                        node.sendStopCommand();
                      },
                    ),
        
                    const UICSpacer(),
        
                    Expanded(
                      child: Column(
                        children: [
                          UICElevatedButton(
                            shrink: false,
                            onPressed: node.movePreset1,
                            leading: const Icon(BeckerIcons.one),
                            child: Text("Lüftungsposition (ZP1) anfahren".i18n)
                          ),
                      
                          const UICSpacer(),
                          
                          UICElevatedButton(
                            shrink: false,
                            onPressed: node.movePreset2,
                            leading: const Icon(BeckerIcons.two),
                            child: Text("Beschattungsposition (ZP2) anfahren".i18n)
                          ),
                      
                          const UICSpacer(3),
                          
                          UICElevatedButton(
                            shrink: false,
                            onPressed: node.setPreset1,
                            leading: const Icon(Icons.move_up),
                            child: Text("Lüftungsposition (ZP1) setzen".i18n)
                          ),
                      
                          const UICSpacer(),
                          
                          UICElevatedButton(
                            shrink: false,
                            onPressed: node.setPreset2,
                            leading: const Icon(Icons.move_down),
                            child: Text("Beschattungsposition (ZP2) setzen".i18n)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const UICSpacer(3),
        
                Center(
                  child: UICElevatedButton(
                    shrink: false,
                    style: UICColorScheme.error,
                    onPressed: () async {
                      final messenger = UICMessenger.of(context);
                      final answer = await messenger.alert(
                        UICSimpleQuestionAlert(
                          title: "Zwischenpositionen löschen".i18n,
                          child: Text("Möchten Sie wirklich alle Zwischenpositionen löschen?".i18n),
                        )
                      );
        
                      if(answer == true) {
                        node.deletePreset();
                      }
                    },
                    leading: const Icon(Icons.remove_circle_outline_rounded),
                    child: Text("Zwischenpositionen löschen".i18n)
                  ),
                ),
              ],
            );
          }
        ),
      ],
    );
  }
}
