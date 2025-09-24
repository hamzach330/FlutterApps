// ignore_for_file: unused_element

import 'dart:developer' as dev;
import "package:modules_common/modules_common.dart";
import "package:modules_common/http.dart" as http;

/// Gateway API
part "cc-box.dart";
part "cc-user.dart";
part "cc-connector.g.dart";
part "api/helpers.dart";
part "api/requests/connect_box.dart";
part "api/requests/get_boxes.dart";
part "api/requests/get_logged_in_user.dart";
part "api/requests/get_logged_in_email.dart";
part "api/requests/login_user.dart";
part "api/requests/logout_user.dart";
part "api/requests/new_device_signup.dart";
part "api/requests/new_user_signup.dart";
part "api/requests/lost_password.dart";
part "api/requests/set_locale.dart";
part "api/requests/del_this_user.dart";
part "api/requests/edit_this_user.dart";
part "api/requests/del_device.dart";
part "api/requests/validate_user.dart";
part "api/requests/get_web_access.dart";

extension on CCUserInfoModel {
  static const String _tag = "UserModelController:";

  /// Login with username and password
  /// Throws ResponseException if unsuccesful
  Future login({required String password})
  async {
    // loggedIn = false;
    loggedIn = await verifyCredentials();
    dev.log('$_tag '
      'LOGGED IN : $loggedIn');

    if(loggedIn != true) {
      await request(LoginUser.param(password: password, username: username, remember: 1));
      // await _login(password);
    }
  }

  Future<List<CCBoxInfoModel>> getBoxes () async {
    // final GetBoxes getBoxesResult = await request(GetBoxes.param());
    // return getBoxesResult.boxes.map((b) => CCBoxInfoModel.fromInfo(b)).toList();
    return [];
  }

  /// parseAndSetCookie
  Future<void> setCredentials(String? cookie) async {
    final tokens = cookie?.split(';') ?? [];

    for(var chunk in tokens) {
      chunk = chunk.replaceAll('secure,', '');
      if(chunk.contains("_SID_")) {
        sessionCredential = chunk.trim();
      } else if(chunk.contains("GWB_TOKEN")) {
        tokenCredential = chunk.trim();
      }
    }
    return;
  }

  /// Check whether the user is currently logged in
  Map<String, String> credentials() {
    return {
      if (sessionCredential != null)   "Cookie": "$sessionCredential;"
      else if(tokenCredential != null) "Cookie": "$tokenCredential;"
    };
  }

  /// Check whether the user is currently logged in
  /// This calls index.psp internally initiating a new session
  Future<void> updateCredentials () async {
    final uri = Uri.https("gw.b-tronic.net", "");
    final response = await http.post(
      uri,
      headers: {
        "Host": "gw.b-tronic.net",
        "Origin": "https://gw.b-tronic.net",
        ...credentials()
      }
    );

    if(response.headers['set-cookie'] != null) {
      await setCredentials(response.headers['set-cookie']);
      
    }

    return;
  }

  /// Check whether the user is currently logged in
  Future<bool> verifyCredentials({bool checkOnlyTokenCredential = false}) async {
    try {
      // if(checkOnlyTokenCredential == false) {
      //   sessionCredential = null;
      // }
      // dev.log("Verifying session credentials: $sessionCredential $tokenCredential");
      final loggedIn = await request(GetLoggedInUser.param());
      if(sessionCredential == null && loggedIn.success == true) {
        /// ??? This should never happen, as request itself calls updateCredentials
        tokenCredential   = null;
        sessionCredential = null;
        return false;
      }
      return true;
    } on ResponseException catch(e) {
      /// Success 0 not logged in
      /// Reset session id
      sessionCredential = null;
      dev.log("$_tag $e");
      if(tokenCredential == null) {
        // Error condition, there is no token
        return false;
      } else if(checkOnlyTokenCredential == false) {
        /// get new credentials from index.psp
        await updateCredentials();
        /// verify new credentials
        return await verifyCredentials(checkOnlyTokenCredential: true);
      } else {
        /// Refresh token attempt failed
        /// Finally not logged in
        tokenCredential = null;
        return false;
      }
    } catch(e) {
      /// Gateway not reachable or 500
      return false;
    }
  }

  /// Log out
  /// Also deletes cookie
  Future logout()
  async {
    await request(LogoutUser.param());
    sessionCredential = null;
    tokenCredential   = null;
    cookie = "";
  }

  /// Link a new CentralControl unit
  Future<NewDeviceSetup> newDeviceSignup(String pin)
  async {
    return await request(NewDeviceSetup.param(pin: pin));
  }

  Future<void> addOrUpdateBox(CCBoxInfoModel newBox)
  async {
    // final root = CCDatabaseService.rootState;
    // CCBoxInfoModel? oldBox;

    // if(newBox.installationMode != true) {
    //   oldBox = root?.boxList.firstWhereOrNull((oldBox) => oldBox.serial == newBox.serial);
    // }

    // if(oldBox != null) {
    //   final oldUser = oldBox.user;
    //   oldUser?.boxes.remove(oldBox);
    //   oldBox.userRef?.clear();
    //   oldBox.userRef?.add(this);
    //   boxes.add(oldBox);
    //   oldBox.address = newBox.address;
    //   // await oldBox.updateSystemInformation();
    // } else if(oldBox == null) {
      newBox.userRef?.add(this);
      boxes.add(newBox);
      // await newBox.updateSystemInformation();
    // }
  }

  /// Signup as a new user
  Future<NewUserSignup> newUserSignup({
    required String pin,
    required String salutation,
    // required String user,
    required String name,
    required String lastName,
    required String email1,
    required String email2,
    required String pass1,
    required String pass2,
    // int save = 1
  }) async {
    return await request(NewUserSignup.param(
      pin: pin,
      salutation: salutation,
      user: email1,
      name: name,
      lastName: lastName,
      email1: email1,
      email2: email2,
      pass1: pass1,
      pass2: pass2
    ));
  }

  /// Request to gw.b-tronic.net/req/RPC
  /// Sets cookie if requested
  Future<T> request<T>(GatewayRequestParamBuilder<T> param) async {
    final uri = Uri.https("gw.b-tronic.net", "req/RPC");
    
    // dev.log("$_tag >>> CREDENTIAL: <<<");
    // dev.log("$_tag >>> ${credentials()} <<<");
    dev.log("$_tag >>> ${param.requestString}");

    http.Response? response;
    try {
      response = await http.post(
        uri,
        body: param.requestString,
        headers: {
          "Host": "gw.b-tronic.net",
          "Origin": "https://gw.b-tronic.net",
          ...credentials()
        }
      );
      dev.log(response.body); 
    } catch(e) {
      dev.log("Request error: $e");
    }

    if(response?.headers['set-cookie'] != null) {
      await setCredentials(response?.headers['set-cookie']);
    }

    if(response?.statusCode != 200) {
      throw GatewayException(response?.body);
    }

    final body = jsonDecode(response?.body ?? "");
    
    if(body['result'] is bool) {
      return body['result'];
    } else if (body['result']?['success'] != true) {
      throw ResponseException(body['result']?['message'] ?? "$body");
    }


    dev.log('$_tag '
      ' <<< ${response?.body}');
    return param.requestTypeBuilder(body) as T;
  }

  connectBox({int? boxId}) async {
    await request(ConnectBox.param(boxId: boxId ?? -1));
  }
}
