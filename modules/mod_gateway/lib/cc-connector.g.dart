// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_element

part of 'gateway.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CCJsonRpcResponse<T> _$CCJsonRpcResponseFromJson<T extends dynamic>(
        Map<String, dynamic> json) =>
    CCJsonRpcResponse<T>(
      jsonrpc: json['jsonrpc'] as String,
      id: json['id'],
      result: json['result'] as Map<String, dynamic>?,
      method: json['method'] as String?,
      params: json['params'] as Map<String, dynamic>?,
      error: json['error'],
    );

Map<String, dynamic> _$CCJsonRpcResponseToJson<T extends dynamic>(
        CCJsonRpcResponse<T> instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'method': instance.method,
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
      'params': instance.params,
    };

CCJsonRpcBatchResponse _$CCJsonRpcBatchResponseFromJson(
        Map<String, dynamic> json) =>
    CCJsonRpcBatchResponse();

Map<String, dynamic> _$CCJsonRpcBatchResponseToJson(
        CCJsonRpcBatchResponse instance) =>
    <String, dynamic>{};

GatewayRpcResponse<T> _$GatewayRpcResponseFromJson<T extends dynamic>(
        Map<String, dynamic> json) =>
    GatewayRpcResponse<T>(
      jsonrpc: json['jsonrpc'] as String?,
      id: json['id'] as int,
      result: json['result'] as Map<String, dynamic>?,
      error: json['error'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GatewayRpcResponseToJson<T extends dynamic>(
        GatewayRpcResponse<T> instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'result': instance.result,
      'error': instance.error,
    };

ConnectBox _$ConnectBoxFromJson(Map<String, dynamic> json) => ConnectBox(
      port: json['Port'] as int,
      url: json['URL'] as String,
      message: json['message'] as String,
      success: json['success'] as bool,
    );

Map<String, dynamic> _$ConnectBoxToJson(ConnectBox instance) =>
    <String, dynamic>{
      'Port': instance.port,
      'URL': instance.url,
      'message': instance.message,
      'success': instance.success,
    };

GetBoxes _$GetBoxesFromJson(Map<String, dynamic> json) => GetBoxes(
      message: json['message'] as String,
      success: json['success'] as bool,
      // boxes: (json['boxes'] as List<dynamic>)
      //     .map((e) => CCBoxInfoModel.fromJson(e as Map<String, dynamic>))
      //     .toList(),
    );

Map<String, dynamic> _$GetBoxesToJson(GetBoxes instance) => <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      // 'boxes': instance.boxes,
    };

GetLoggedInUser _$GetLoggedInUserFromJson(Map<String, dynamic> json) =>
    GetLoggedInUser(
      message: json['message'] as String,
      success: json['success'] as bool,
      tokenLogin: json['tokenLogin'] as bool,
      user: json['user'] as String,
      vipLevel: json['VIPlevel'] as int,
    );

Map<String, dynamic> _$GetLoggedInUserToJson(GetLoggedInUser instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'VIPlevel': instance.vipLevel,
      'tokenLogin': instance.tokenLogin,
      'user': instance.user,
    };

GetLoggedInEMail _$GetLoggedInEMailFromJson(Map<String, dynamic> json) =>
    GetLoggedInEMail(
      message: json['message'] as String,
      success: json['success'] as bool,
      user: json['user'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$GetLoggedInEMailToJson(GetLoggedInEMail instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'email': instance.email,
      'user': instance.user,
    };

LoginUser _$LoginUserFromJson(Map<String, dynamic> json) => LoginUser(
      success: json['success'] as bool,
      isAdmin: json['isAdmin'] as bool,
      vipLevel: json['VIPlevel'] as int,
      message: json['message'] as String,
    );

Map<String, dynamic> _$LoginUserToJson(LoginUser instance) => <String, dynamic>{
      'success': instance.success,
      'isAdmin': instance.isAdmin,
      'VIPlevel': instance.vipLevel,
      'message': instance.message,
    };

LogoutUser _$LogoutUserFromJson(Map<String, dynamic> json) => LogoutUser(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$LogoutUserToJson(LogoutUser instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

NewDeviceSetup _$NewDeviceSetupFromJson(Map<String, dynamic> json) =>
    NewDeviceSetup(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$NewDeviceSetupToJson(NewDeviceSetup instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

NewUserSignup _$NewUserSignupFromJson(Map<String, dynamic> json) =>
    NewUserSignup(
      success: json['success'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$NewUserSignupToJson(NewUserSignup instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

LostPassword _$LostPasswordFromJson(Map<String, dynamic> json) => LostPassword(
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LostPasswordToJson(LostPassword instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };

SetLocale _$SetLocaleFromJson(Map<String, dynamic> json) => SetLocale();

Map<String, dynamic> _$SetLocaleToJson(SetLocale instance) =>
    <String, dynamic>{};

DelThisUser _$DelThisUserFromJson(Map<String, dynamic> json) => DelThisUser(
      message: json['message'] as String,
      success: json['success'] as bool,
    );

Map<String, dynamic> _$DelThisUserToJson(DelThisUser instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
    };

EditThisUser _$EditThisUserFromJson(Map<String, dynamic> json) => EditThisUser(
      message: json['message'] as String,
      success: json['success'] as bool,
    );

Map<String, dynamic> _$EditThisUserToJson(EditThisUser instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
    };

DelDevice _$DelDeviceFromJson(Map<String, dynamic> json) => DelDevice(
      message: json['message'] as String,
      success: json['success'] as bool,
    );

Map<String, dynamic> _$DelDeviceToJson(DelDevice instance) => <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
    };

GetWebAccess _$GetWebAccessFromJson(Map<String, dynamic> json) => GetWebAccess(
      webLink: json['web_link'] as String,
      success: json['success'] as bool,
    );

Map<String, dynamic> _$GetWebAccessToJson(GetWebAccess instance) => <String, dynamic>{
      'service_code': instance.webLink,
      'success': instance.success,
    };

ValidateUser _$ValidateUserFromJson(Map<String, dynamic> json) =>
    ValidateUser();

Map<String, dynamic> _$ValidateUserToJson(ValidateUser instance) =>
    <String, dynamic>{};
