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
class GetBoxes {
  String message;
  bool success;
  // List<CCBoxInfo> boxes;

  GetBoxes({
    required this.message,
    required this.success,
    // required this.boxes,
  });

  factory GetBoxes.fromJson(GatewayRpcResponse json) =>
          _$GetBoxesFromJson(json.result!);

  Map<String, dynamic> toJson() => _$GetBoxesToJson(this);

  /// ## get_boxes
  static GatewayRequestParamBuilder<GetBoxes> param() {
    final param = {
      "method":"getBoxes",
      "params":[]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => GetBoxes.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}
