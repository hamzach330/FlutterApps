part of '../module.dart';

class CCElevenGroupList extends StatefulWidget {
  const CCElevenGroupList({
    super.key,
  });

  @override
  State<CCElevenGroupList> createState() => _CCElevenGroupListState();
}

class _CCElevenGroupListState extends State<CCElevenGroupList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = theme.defaultWhiteSpace;
    return Consumer<CCEleven>(
      builder: (context, cc, _) {
        cc.groups.sort((a, b) => a.id.compareTo(b.id));

        return SliverMainAxisGroup(
          slivers: [
            if(cc.groups.isNotEmpty) SliverPadding(
              padding: EdgeInsetsGeometry.only(
                top: pad,
                right: pad,
                bottom: pad * 2,
                left: pad
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisExtent: 120,
                      crossAxisSpacing: theme.defaultWhiteSpace,
                      mainAxisSpacing: theme.defaultWhiteSpace,
                      // childAspectRatio: 16 / 12,
                    ),
                    itemCount: cc.groups.length,
                    itemBuilder: (BuildContext context, int index) {
                      return CCGroupTile(group: cc.groups[index]);
                    }
                  );
                }
              ),
            ),
        
            if(cc.groups.isEmpty) SliverPadding(
              padding: EdgeInsets.only(top: theme.defaultWhiteSpace * 2, bottom: theme.defaultWhiteSpace * 2),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        CCElevenGroupView.go(context);
                      },
                      child: Text("Es sind noch keine Gruppen vorhanden.\nErstellen Sie jetzt Ihre erste Gruppe.".i18n, textAlign: TextAlign.center,),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      }
    );
  }
}
