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
/// final requestsAPI.GetWebAccess result =
///    await con.request(requestsAPI.GetWebAccess.param());
/// ```
/// 

@JsonSerializable()
class GetWebAccess {
  bool success;
  @JsonKey(name: 'service_code')
  String webLink;

  GetWebAccess({
    required this.webLink,
    required this.success
  });

  factory GetWebAccess.fromJson(GatewayRpcResponse json) =>
          _$GetWebAccessFromJson(json.result!);

  Map<String, dynamic> toJson() => _$GetWebAccessToJson(this);

  /// ## get_logged_in_user
  static GatewayRequestParamBuilder<GetWebAccess> param({required String code}) {
    final param = {
    "method" : 'getWebAccess',
    "params" : [{
      "service_code": code
    }]
  };
    return GatewayRequestParamBuilder<GetWebAccess>(
      param,
      (json) => GetWebAccess.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}