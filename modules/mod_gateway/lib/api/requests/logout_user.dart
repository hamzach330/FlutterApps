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
class LogoutUser {
  bool success;
  String message;

  LogoutUser({
    required this.success,
    required this.message
  });

  factory LogoutUser.fromJson(GatewayRpcResponse json) =>
          _$LogoutUserFromJson(json.result!);

  Map<String, dynamic> toJson() => _$LogoutUserToJson(this);

  /// ## logout_user
  static GatewayRequestParamBuilder param() {
    final param = {
      "method":"logoutUser",
      "params":[]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => LogoutUser.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}