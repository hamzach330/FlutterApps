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
class EditThisUser {
  String message;
  bool success;

  EditThisUser({
    required this.message,
    required this.success,
  });

  factory EditThisUser.fromJson(GatewayRpcResponse json) =>
          _$EditThisUserFromJson(json.result!);

  Map<String, dynamic> toJson() => _$EditThisUserToJson(this);

  /// ## get_boxes
  static GatewayRequestParamBuilder<EditThisUser> param({
    required String username,
    required String email,
    required String password,
    // required String oldPassword,
  }) {
    final param = {
      "method":"editThisUser",
      "params": [{
        "User": username,
        "EMail1": email,
        "EMail2": email,
        "pass1": password,
        "pass2": password,
        // "oldpass": oldPassword
      }]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => EditThisUser.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}
