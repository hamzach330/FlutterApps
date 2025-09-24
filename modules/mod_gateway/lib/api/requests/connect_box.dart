part of '../../gateway.dart';

/// ## get_boxes
/// Initialize connection to a central control device
/// result: {URL: "https://gw.b-tronic.net/ccjubabo/", message: "ok", Port: 26905, success: true}
/// Port: 26905
/// URL: "https://gw.b-tronic.net/ccjubabo/"
/// message: "ok"
/// success: true
///
///
/// Usage example:
/// ```
/// import 'package:becker_central_control/shared/services/gateway/module.dart' as gatewayAPI;
/// final con = CCWebviewSocket(url: 'ws://address/jrpc');
/// await con.connect();
/// final gatewayAPI.ConnectBox result =
///    await gatewayAPI.request(gatewayAPI.ConnectBox.param());
/// ```
/// 

@JsonSerializable()
class ConnectBox {
  @JsonKey(name: 'Port')
  int port;
  @JsonKey(name: 'URL')
  String url;
  String message;
  bool success;

  ConnectBox({
    required this.port,
    required this.url,
    required this.message,
    required this.success
  });

  factory ConnectBox.fromJson(GatewayRpcResponse json) =>
          _$ConnectBoxFromJson(json.result!);

  Map<String, dynamic> toJson() => _$ConnectBoxToJson(this);

  /// ## Connect box
  static GatewayRequestParamBuilder param({
    required int boxId
  }) {
    final param = {
      "method":"connectBox",
      "params":[boxId]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => ConnectBox.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}
