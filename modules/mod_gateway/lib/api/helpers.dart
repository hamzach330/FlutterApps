part of '../gateway.dart';

int rpcCounter = 0;

@JsonSerializable()
class GatewayRpcResponse<T extends dynamic> {
  String? jsonrpc;
  int id;
  Map<String, dynamic>? result;
  Map<String, dynamic>? error;

  GatewayRpcResponse({
    required this.jsonrpc,
    required this.id,
    required this.result,
    required this.error
  });

  factory GatewayRpcResponse.fromJson(Map<String, dynamic> json, {dynamic t}) {
    return _$GatewayRpcResponseFromJson(json);
  }
  T fromJson(Map<String, dynamic> json, {T? t}) {
    if(t != null) {
      return t.fromJson(json['result']);
    } else {
      return json as T;
    }
  }
}


class GatewayRequestParamBuilder<T> {
  late String requestString;
  late dynamic Function(dynamic json) requestTypeBuilder;

  GatewayRequestParamBuilder(Map<String, dynamic> param, dynamic typeBuilder) {
    rpcCounter++;
    final Map<String, dynamic> rpcRequest = {
      "jsonrpc": "2.0",
      "id": rpcCounter
    };
    rpcRequest.addAll(param);
    requestString = jsonEncode(rpcRequest);
    requestTypeBuilder = typeBuilder;
  }
}


/// Base class for RequestInfos
abstract class RequestInfoImpl {
  List<int> toRequest();
  dynamic toRequestMap();
  String toRequestString() => utf8.decode(toRequest());

  dynamic id;
  late Map<String, dynamic> params;
  late String method;
}

/// Generate JRPC 2.0 requests and convert them to a format readable by CentralControl
class RequestInfo extends RequestInfoImpl {
  RequestInfo({
    required Map<String, dynamic> params,
    required String method,
    dynamic id,
  }) {
    this.params = params;
    this.method = method;
    this.id = id;
  }

  @override
  List<int> toRequest() {
    final request = jsonEncode({
      "jsonrpc": "2.0",
      "id": id,
      "params": params,
      "method": method
    });
    final jsonData = utf8.encode(request);
    return List.from(jsonData)..add(0x00);
  }

  @override
  Map<String, dynamic> toRequestMap() {
    return {
      "jsonrpc": "2.0",
      "id": id,
      "params": params,
      "method": method
    };
  }
}

/// Generate JRPC 2.0 batch requests and convert them to a format readable by CentralControl
class BatchRequestInfo extends RequestInfoImpl {
  final List<RequestInfoImpl> requests;

  BatchRequestInfo({required this.requests}) {
    id = requests.isNotEmpty ? requests.first.id : null;  // Setzt id aus erstem Request oder null
  }

  @override
  List<int> toRequest() {
    List<Map<String, dynamic>> request = requests.map((info) => {
      "jsonrpc": "2.0",
      "id": info.id,
      "params": info.params,
      "method": info.method
    }).toList();
    final jsonData = utf8.encode(jsonEncode(request));
    return List.from(jsonData)..add(0x00);
  }

  @override
  List<Map<String, dynamic>> toRequestMap() {
    return requests.map((info) => {
      "jsonrpc": "2.0",
      "id": info.id,
      "params": info.params,
      "method": info.method
    }).toList();
  }
}

/// Builds Parameters and resolves types accordingly
class ParamBuilder {
  late RequestInfoImpl requestInfo;
}

/// Builds Parameters and resolves types accordingly
class RequestParamBuilder<T> implements ParamBuilder{
  @override
  late RequestInfoImpl requestInfo;
  late dynamic Function(dynamic json) requestType;
  RequestParamBuilder(RequestInfoImpl param, dynamic type) {
    requestInfo = param;
    requestType = type;
  }
}

/// Builds Parameters and resolves types accordingly
class BatchRequestParamBuilder<T> implements ParamBuilder{
  @override
  late RequestInfoImpl requestInfo;
  late dynamic Function(dynamic json) requestType;
  BatchRequestParamBuilder(RequestInfoImpl param, dynamic type) {
    requestInfo = param;
    requestType = type;
  }
}

/// An object in the async queue, which will be resolved once a request responds
class QueueInfo {
  QueueInfo({
    required this.completer,
    required this.request
  });
  final Completer completer;
  final String request;
}

class ResponseError {
  final int code;
  final String message;
  ResponseError({
    required this.code,
    required this.message
  });
  factory ResponseError.fromJson(dynamic json) {
    return ResponseError(
      code: json["code"],
      message: json["message"]
    );
  }
}

/// Check for response validity and resolve the response
@JsonSerializable()
class CCJsonRpcResponse<T extends dynamic> {
  final String jsonrpc;
  final String? method;
  final dynamic id;
  final dynamic error;
  final Map<String, dynamic>? result;
  final Map<String, dynamic>? params;

  CCJsonRpcResponse({
    required this.jsonrpc,
    this.id,
    this.result,
    this.method,
    this.params,
    this.error
  });

  factory CCJsonRpcResponse.fromJson(Map<String, dynamic> json, {dynamic t})
    => _$CCJsonRpcResponseFromJson(json);

  T? fromJson(Map<String, dynamic> json, {T? t}) {
    if(t != null) {
      return t.fromJson(json['result']);
    } else {
      return json as T;
    }
  }
}


/// Same as CCJsonRpcResponse, but for batch requests
@JsonSerializable()
class CCJsonRpcBatchResponse {
  static List<CCJsonRpcResponse> fromJson(List<dynamic> json) {
    return json.map((data) {
      return CCJsonRpcResponse.fromJson(data);
    }).toList();
  }
}
