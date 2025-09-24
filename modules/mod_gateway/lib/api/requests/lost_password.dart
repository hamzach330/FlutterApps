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
class LostPassword {
  bool? success;
  String? message;

  LostPassword({
    this.success,
    this.message
  });

  factory LostPassword.fromJson(GatewayRpcResponse json) =>
          _$LostPasswordFromJson(json.result!);

  Map<String, dynamic> toJson() => _$LostPasswordToJson(this);

  /// ## reset password
  static GatewayRequestParamBuilder param({
    required String email
  }) {
    final param = {
      "method": "pwReset",
      "params": [email]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => LostPassword.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}