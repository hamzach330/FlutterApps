part of 'gateway.dart';


class CCBoxInfoModel { // with ChangeNotifier, CCBox<List<CCUserModel>, CCUserModel>
  static int numModels = 0;
  int? id;
  String? lastBoxIp;
  String? lastErr;
  String? name;
  int? state;
  String? urlPath;
  String? address;
  List<CCUserInfoModel>? userRef;
  CCUserInfoModel? get user => (userRef?.isNotEmpty ?? false)
    ? userRef!.first
    : null;

  String? serial;
  String? hwVariant;
  // List<CCItemModel>? items;
  // List<CCItemListModel>? lists;
  bool? autoconnect;
  bool installationMode = false;

  // Volatile entries
  String? serviceCode;
  bool updating = false;
  // SystemdSrvFwUpdateInfo? updateInfo;
  // CCSocket? socket;
  // CCSocket? localSocket;
  // CCSocket? remoteSocket;
  // CancelableCompleter<CCSocket?>? connectOperation;
  // SystemdNetInfo? systemdNetInfo;

  // StreamController<CCSocketStatus> socketStatus = StreamController<CCSocketStatus>.broadcast();
  // CancelableOperation? polling;

  Map<String, bool> availableBackends = {};
  bool availableBackendsLoaded = false;
  bool forceStopUpdate = false;
  bool forceClose = false;
  
  int onlineState = 0;
  List<QueueObject> queue = [];
  int requestCounter = 0;

  bool connectFailedLocal = false;
  bool connectFailedRemote = false;

  bool reachableLocal = true;
  bool reachableRemote = true;

  CCBoxInfoModel({
    this.id,
    this.lastBoxIp,
    this.lastErr,
    this.name,
    this.state,
    this.urlPath,
    this.address,
    this.serial,
    this.hwVariant,
    List<CCUserInfoModel>? userRef,
    // List<CCItemModel>? items,
    // List<CCItemListModel>? lists,
    this.autoconnect,
  }) {
    this.userRef = userRef ?? [];
    // this.items = items ?? [];
    // this.lists = lists ?? [];
    autoconnect ??= false;
    // print("OK");
  }

  // factory CCBoxInfoModel.fromInfo(CCBoxInfo ccBoxInfo) {
  //   final ccBox = CCBoxInfoModel(
  //     id: ccBoxInfo.id,
  //     address: ccBoxInfo.address,
  //     lastBoxIp: ccBoxInfo.lastBoxIp,
  //     lastErr: ccBoxInfo.lastErr,
  //     name: ccBoxInfo.name,
  //     state: ccBoxInfo.state,
  //     urlPath: ccBoxInfo.urlPath,
  //     serial: ccBoxInfo.serial
  //   );
  //   return ccBox;
  // }

  @override
  int get hashCode {
    return id.hashCode ^ (name?.hashCode ?? 0) ^ (address?.hashCode ?? 0);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    return other is CCBoxInfoModel &&
        other.id == id &&
        other.name == name &&
        other.address == address;
  }
}


class QueueObject<T> {
  final RequestParamBuilder<T>? param;
  final Completer<T> completer;
  final bool raw;
  final String? rawParams;
  final String? rawMethod;
  // final dynamic id;

  QueueObject({
    this.param,
    this.raw = false,
    this.rawParams,
    this.rawMethod,
    required this.completer,
    // required this.id
  });
}
