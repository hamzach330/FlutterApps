part of 'module.dart';


class CPRemoteView extends StatelessWidget {
  static const route = 'remote_assign/';
  static Widget buildRoute(dynamic params) => const CPRemoteView();
  static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

  const CPRemoteView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: CPOwnNodes()),
        const CPForeignNodes()
      ],
    );
  }
}
