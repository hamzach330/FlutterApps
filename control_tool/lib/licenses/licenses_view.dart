part of '../main.dart';

class LicensesView extends StatelessWidget {
  static const pathName = "licenses";
  static const path = '/licenses';

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
      child: const LicensesView(),
    )
  );

  static go (BuildContext context) {
    context.push("/licenses");
  }

  const LicensesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.chevron_left),
        ),
        title: Text("Lizenzen".i18n),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: SizedBox(
              width: 600,
              child: Column(
                children: ossLicenses.map((package) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package.name, style: textTheme.titleLarge),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(package.description),
                    ),
                    Text("Version: %s".i18n.fill([package.version])),
                    if(package.homepage != null) Text("Homepage: %s".i18n.fill([package.homepage!])),
                    if(package.repository != null) Text("Repository: %s".i18n.fill([package.repository!])),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text("${package.license}"),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(),
                    )
                  ],
                )).toList()
              ),
            ),
          ),
        ),
      ),
    );
  }
}
