part of ui_common;

class UICPackageInfoProvider extends ChangeNotifier {
  PackageInfo? version;
  UICPackageInfoProvider() {
    Future(() async {
      version = await PackageInfo.fromPlatform();
      notifyListeners();
    });
  }
}
