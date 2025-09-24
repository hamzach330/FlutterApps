part of '../../gateway.dart';

@JsonSerializable()
class ValidateUser {

  ValidateUser();

  factory ValidateUser.fromJson(GatewayRpcResponse json) =>
          _$ValidateUserFromJson(json.result!);

  Map<String, dynamic> toJson() => _$ValidateUserToJson(this);

  /// ## reset password
  static GatewayRequestParamBuilder param({
    required String username
  }) {
    final param = {
      "method": "validateUser",
      "params": [username]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => ValidateUser.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}