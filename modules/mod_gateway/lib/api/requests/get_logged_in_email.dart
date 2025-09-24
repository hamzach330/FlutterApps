part of '../../gateway.dart';
/// ## get_logged_in_user
/// Check if the current user session is logged in, retrieve a new one if not.
/// ### Output
/// * message: A descriptive message, i.e. "not logged in"
/// * success: True if the current session is logged in, False otherwise
/// * VIPlevel: Access level of the user (i.e. 1 for normal users)
/// * tokenLogin: ???
/// * user: The username
/// Usage example:
/// ```
/// import 'package:becker_central_control/shared/services/socket/main.dart';
/// import 'package:becker_central_control/shared/services/socket/api/requests.dart' as requestsAPI;
/// final con = CCWebviewSocket(url: 'ws://address/jrpc');
/// await con.connect();
/// final requestsAPI.GetLoggedInUser result =
///    await con.request(requestsAPI.GetLoggedInUser.param());
/// ```
/// 

@JsonSerializable()
class GetLoggedInEMail {
  String message;
  bool success;
  String? email;
  String? user;

  GetLoggedInEMail({
    required this.message,
    required this.success,
    required this.user,
    required this.email
  });

  factory GetLoggedInEMail.fromJson(GatewayRpcResponse json) =>
          _$GetLoggedInEMailFromJson(json.result!);

  Map<String, dynamic> toJson() => _$GetLoggedInEMailToJson(this);

  /// ## get_logged_in_user
  static GatewayRequestParamBuilder<GetLoggedInEMail> param() {
    final param = {
    "method" : 'getLoggedInEMail',
    "params" : []
  };
    return GatewayRequestParamBuilder(
      param,
      (json) => GetLoggedInEMail.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}