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
class NewUserSignup {
  bool success;
  String message;

  NewUserSignup({
    required this.success,
    required this.message
  });

  factory NewUserSignup.fromJson(GatewayRpcResponse json) =>
          _$NewUserSignupFromJson(json.result!);

  Map<String, dynamic> toJson() => _$NewUserSignupToJson(this);

  /// ## logout_user
  static GatewayRequestParamBuilder<NewUserSignup> param({
    required String pin,
    required String salutation,
    required String user,
    required String name,
    required String lastName,
    required String email1,
    required String email2,
    required String pass1,
    required String pass2,
    int save = 1
  }) {
    final param = {
      "method": "newUserSignup",
      "params": [{
        "PIN": pin,
        "Geschlecht": salutation,
        "User": user,
        "Vorname": name,
        "Nachname": lastName,
        "EMail": email1,
        "EMail2": email2,
        "pass1": pass1,
        "pass2": pass2
      }]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => NewUserSignup.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}