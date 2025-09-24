part of 'gateway.dart';

class CCUserInfoModel { // with ChangeNotifier, CCUser<HiveList<CCBoxInfoModel>, CCBoxInfoModel> {
  String username;
  String? cookie;
  CCUserType type;
  List<CCBoxInfoModel> boxes;
  String? tokenCredential;
  String? sessionCredential;
  bool? loggedIn;

  CCUserInfoModel({
    required this.username,
    required this.type,
    required this.boxes,
    this.cookie,
    this.tokenCredential,
    this.sessionCredential,
  });

  static gwRequest<T>(GatewayRequestParamBuilder param) async {
    final uri = Uri.https("gw.b-tronic.net", "req/RPC");

    final response = await http.post(
      uri,
      body: param.requestString,
      headers: {
        "Host": "gw.b-tronic.net",
        "Origin": "https://gw.b-tronic.net"
      }
    );

    if(response.statusCode != 200) {
      throw GatewayException(response.body);
    }

    final body = jsonDecode(response.body);
    
    if(body['result']?['success'] != true) {
      throw ResponseException(body['result']?['message'] ?? "$body");
    }
    return param.requestTypeBuilder(body) as T;
  }
}

enum CCUserType {
   remote, local
}

abstract class ExceptionBase implements Exception {
  final dynamic message;
  ExceptionBase(this.message);
  @override
  String toString() {
      return message.toString();
  }
}

class GatewayException extends ExceptionBase {
  GatewayException(super.message);
}

class ResponseException extends ExceptionBase {
  ResponseException(super.message);
}

class CCSocketException extends ExceptionBase {
  CCSocketException(super.message);
}