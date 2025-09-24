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
class DelThisUser {
  String message;
  bool success;

  DelThisUser({
    required this.message,
    required this.success,
  });

  factory DelThisUser.fromJson(GatewayRpcResponse json) =>
          _$DelThisUserFromJson(json.result!);

  Map<String, dynamic> toJson() => _$DelThisUserToJson(this);

  /// ## get_boxes
  static GatewayRequestParamBuilder param() {
    final param = {
      "method":"delThisUser",
      "params":[]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => DelThisUser.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}
