part of '../../gateway.dart';


/// ## logout_user
/// End current user session
///
///
/// Usage example:
/// ```
/// import 'package:becker_central_control/shared/services/gateway/module.dart' as gatewayAPI;
/// final con = CCWebviewSocket(url: 'ws://address/jrpc');
/// await con.connect();
/// final gatewayAPI.LogoutUser result =
///    await gatewayAPI.request(gatewayAPI.LogoutUser.param());
/// ```
/// 

@JsonSerializable()
class NewDeviceSetup {
  bool success;
  String message;

  NewDeviceSetup({
    required this.success,
    required this.message
  });

  factory NewDeviceSetup.fromJson(GatewayRpcResponse json) =>
          _$NewDeviceSetupFromJson(json.result!);

  Map<String, dynamic> toJson() => _$NewDeviceSetupToJson(this);

  /// ## logout_user
  static GatewayRequestParamBuilder<NewDeviceSetup> param({
    required String pin,
  }) {
    final param = {
      "method": "newDevice",
      "params": [pin]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => NewDeviceSetup.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}