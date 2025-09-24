// part of 'module.dart';

// class EvoControlView extends StatelessWidget {
//   static const route = '/evo_control';
//   static Widget buildRoute(dynamic params) => const EvoControlView();
//   static open (BuildContext context) => UICScaffold.of(context).contentNavigator?.pushNamed(route);

//   const EvoControlView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<Evo>(
//       builder: (context, evo, _) => UICPage(
//         elevation: 0,
//         menu: true,
//         title: "Bedienung".i18n,
//         slivers: const [
//           UICConstrainedSliverList(
//             maxWidth: 640,
//             children: [
//               UICSpacer(5),
//               EvoControl()
//             ],
//           ),
//         ] // const [ EvoProfiles(), EvoSpeed() ],
//       )
//     );
//   }
// }
