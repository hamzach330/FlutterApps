part of ui_common;

// class UICController extends ChangeNotifier {
//   static final _navigator = GlobalKey<NavigatorState>();
  
//   final List<SingleChildStatelessWidget> _providers;
//   final Map<String, RouteBuilderDef> routes;
//   final Map<String, RouteBuilderDef> endDrawerRoutes;
//   final Map<String, RouteBuilderDef> contentRoutes;


//   UICController({
//     required List<SingleChildStatelessWidget> providers,
//     required this.routes,
//     required this.endDrawerRoutes,
//     required this.contentRoutes
//   }) : _providers = providers;

//   NavigatorState? get navigator => _navigator.currentState;
  
//   add(SingleChildStatelessWidget provider) {
//     _providers.add(provider);
//     notifyListeners();
//   }

//   remove(SingleChildStatelessWidget provider) {
//     _providers.remove(provider);
//     notifyListeners();
//   }

//   Widget _searchRoute(Map<String, RouteBuilderDef> routes, String? path, dynamic arguments) {
//     final route = routes[path];
//     if(route != null) {
//       return route(arguments);
//     } else {
//       return UIC404();
//     }
//   }

//   Widget _searchContentRoute(String? path, dynamic arguments) => _searchRoute(contentRoutes, path, arguments);

//   Widget _searchEndDrawerRoute(String? path, dynamic arguments) => _searchRoute(endDrawerRoutes, path, arguments);

//   Widget _searchMainRoute(String? path, dynamic arguments) => _searchRoute(routes, path, arguments);

//   static UICController of (BuildContext context) {
//     return Provider.of<UICController>(context, listen: false);
//   }
// }