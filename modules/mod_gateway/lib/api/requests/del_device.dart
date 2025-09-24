part of '../../gateway.dart';
/// ## get_boxes
/// Retrieve a list of CentralControl units owned by currently logged in user.
///
///
/// Usage example:
/// ```
/// import 'package:becker_central_control/shared/services/gateway/module.dart' as gatewayAPI;
/// final con = CCWebviewSocket(url: 'ws://address/jrpc');
/// await con.connect();
/// final gatewayAPI.GetBoxes result =
///    await gatewayAPI.request(gatewayAPI.GetBoxes.param());
/// ```
/// 

@JsonSerializable()
class DelDevice {
  String message;
  bool success;

  DelDevice({
    required this.message,
    required this.success,
  });

  factory DelDevice.fromJson(GatewayRpcResponse json) =>
          _$DelDeviceFromJson(json.result!);

  Map<String, dynamic> toJson() => _$DelDeviceToJson(this);

  /// ## get_boxes
  static GatewayRequestParamBuilder param({required int? boxId}) {
    final param = {
      "method":"delDevice",
      "params":[boxId]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => DelDevice.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}
