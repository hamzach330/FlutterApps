part of '../../gateway.dart';

/// ## login_user
/// Login with username / mail and password
/// The user remains logged in as long as the session is valid.
///
///
/// Usage example:
/// ```
/// import 'package:becker_central_control/shared/services/gateway/module.dart' as gatewayAPI;
/// final con = CCWebviewSocket(url: 'ws://address/jrpc');
/// await con.connect();
/// final gatewayAPI.LoginUser result =
///    await gatewayAPI.request(gatewayAPI.LoginUser.param());
/// ```
/// 

@JsonSerializable()
class LoginUser {
  bool success;
  bool isAdmin;
  @JsonKey(name: 'VIPlevel')
  int vipLevel;
  String message;

  LoginUser({
    required this.success,
    required this.isAdmin,
    required this.vipLevel,
    required this.message
  });

  factory LoginUser.fromJson(GatewayRpcResponse json) =>
          _$LoginUserFromJson(json.result!);

  Map<String, dynamic> toJson() => _$LoginUserToJson(this);

  /// ## login_user
  /// ### Input parameters
  /// * username: The users user name or email address
  /// * password: The users password 
  /// * remember: Whether the session should expire or not
  static GatewayRequestParamBuilder param({
    required String password,
    required String username,
    int remember = 1
  }) {
    final param = {
      "method":"loginUser",
      "params":[{
        "Kennwort": password,
        "User": username,
        "savelogin": remember
      }]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => LoginUser.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}