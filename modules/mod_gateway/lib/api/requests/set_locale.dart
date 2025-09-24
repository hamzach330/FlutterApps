part of '../../gateway.dart';

@JsonSerializable()
class SetLocale {

  SetLocale();

  factory SetLocale.fromJson(GatewayRpcResponse json) =>
          _$SetLocaleFromJson(json.result!);

  Map<String, dynamic> toJson() => _$SetLocaleToJson(this);

  /// ## reset password
  static GatewayRequestParamBuilder param({
    required String locale
  }) {
    final param = {
      "method": "setLang",
      "params": [locale]
    };
    return GatewayRequestParamBuilder(
      param,
      (json) => SetLocale.fromJson(GatewayRpcResponse.fromJson(json)));
  }
}