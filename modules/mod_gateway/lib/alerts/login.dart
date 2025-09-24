// part of '../../../main.dart';

// class GatewayLoginAlert extends UICAlert<void> {
//   static open(BuildContext context) =>
//       UICMessenger.of(context).alert(GatewayLoginAlert());

//   GatewayLoginAlert({
//     super.key,
//   });

//   @override
//   get title => "Login".i18n;

//   @override
//   get useMaterial => true;

//   @override
//   get materialWidth => 460;

//   @override
//   get backdrop => true;

//   @override
//   get dismissable => true;

//   @override
//   get closeAction => pop;

//   @override
//   Widget build(BuildContext context) {
//     return const GatewayLoginView();
//   }
// }

// class GatewayLoginView extends StatefulWidget {
//   const GatewayLoginView({super.key});

//   @override
//   State<GatewayLoginView> createState() => _GatewayLoginViewState();
// }

// class _GatewayLoginViewState extends State<GatewayLoginView> {
//   final String _tag = "UserModelController:";
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final codeController = TextEditingController();

//   bool loggedIn = false;
//   bool loginError = false;

//   static String? sessionCredential;
//   static String? tokenCredential;

//   Map<String, String> headers = {
//     "Host": "gw.b-tronic.net",
//     "Origin": "https://gw.b-tronic.net",
//     "Referer": "https://gw.b-tronic.net/login",
//     "User-Agent":
//         "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0",
//     "Sec-Fetch-Dest": "empty",
//     "Sec-Fetch-Mode": "cors",
//     "Sec-Fetch-Site": "same-origin",
//     "Set-Cookie":
//         "GWB_TOKEN=-316194380763806O12613; Domain=b-tronic.net; expires=Sat, 31-Aug-2024 08:29:14 GMT; Path=/; secure,_SID_=20240809102240-7c6fae33a96eb0b474fd38a4abb3ddbc; Path=/; secure"
//   };

//   Future<T> request<T>(GatewayRequestParamBuilder<T> param) async {
//     final uri = Uri.https("gw.b-tronic.net", "req/RPC");

//     dev.log("$_tag >>> CREDENTIAL: <<<");
//     dev.log("$_tag >>> ${credentials()} <<<");
//     dev.log("$_tag >>> ${param.requestString}");

//     http.Response? response;
//     try {
//       response = await http.post(uri, body: param.requestString, headers: {
//         "Host": "gw.b-tronic.net",
//         "Origin": "https://gw.b-tronic.net",
//         "Referer": "https://gw.b-tronic.net/login",
//         "User-Agent":
//             "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:128.0) Gecko/20100101 Firefox/128.0",
//         "Sec-Fetch-Dest": "empty",
//         "Sec-Fetch-Mode": "cors",
//         "Sec-Fetch-Site": "same-origin",
//         ...credentials()
//       });
//       dev.log(response.body);
//     } catch (e) {
//       dev.log("Request error: $e");
//     }

//     if (response?.headers['set-cookie'] != null) {
//       await setCredentials(response?.headers['set-cookie']);
//     }

//     if (response?.statusCode != 200) {
//       throw GatewayException(response?.body);
//     }

//     final body = jsonDecode(response?.body ?? "");

//     if (body['result'] is bool) {
//       return body['result'];
//     } else if (body['result']?['success'] != true) {
//       throw ResponseException(body['result']?['message'] ?? "$body");
//     }

//     dev.log('$_tag '
//         ' <<< ${response?.body}');
//     return param.requestTypeBuilder(body) as T;
//   }

//   /// parseAndSetCookie
//   Future<void> setCredentials(String? cookie) async {
//     final tokens = cookie?.split(';') ?? [];

//     for (var chunk in tokens) {
//       chunk = chunk.replaceAll('secure,', '');
//       if (chunk.contains("_SID_")) {
//         sessionCredential = chunk.trim();
//       } else if (chunk.contains("GWB_TOKEN")) {
//         tokenCredential = chunk.trim();
//       }
//     }
//     return;
//   }

//   /// Check whether the user is currently logged in
//   Map<String, String> credentials() {
//     return {
//       if (sessionCredential != null && tokenCredential != null)
//         "Cookie": "$sessionCredential; $tokenCredential"
//       else if (sessionCredential != null)
//         "Cookie": "$sessionCredential;"
//       else if (tokenCredential != null)
//         "Cookie": "$tokenCredential;"
//     };
//   }

//   /// Check whether the user is currently logged in
//   /// This calls index.psp internally initiating a new session
//   Future<void> updateCredentials() async {
//     final uri = Uri.https("gw.b-tronic.net", "");
//     final response = await http.post(uri, headers: {
//       "Host": "gw.b-tronic.net",
//       "Origin": "https://gw.b-tronic.net",
//       ...credentials()
//     });

//     if (response.headers['set-cookie'] != null) {
//       await setCredentials(response.headers['set-cookie']);
//     }

//     return;
//   }

//   /// Check whether the user is currently logged in
//   Future<bool> verifyCredentials(
//       {bool checkOnlyTokenCredential = false}) async {
//     try {
//       // if(checkOnlyTokenCredential == false) {
//       //   sessionCredential = null;
//       // }
//       // dev.log("Verifying session credentials: $sessionCredential $tokenCredential");
//       final loggedIn = await request(GetLoggedInUser.param());
//       if (sessionCredential == null && loggedIn.success == true) {
//         /// ??? This should never happen, as request itself calls updateCredentials
//         tokenCredential = null;
//         sessionCredential = null;
//         return false;
//       }
//       return true;
//     } on ResponseException catch (e) {
//       /// Success 0 not logged in
//       /// Reset session id
//       sessionCredential = null;
//       dev.log("$_tag $e");
//       if (tokenCredential == null) {
//         // Error condition, there is no token
//         return false;
//       } else if (checkOnlyTokenCredential == false) {
//         /// get new credentials from index.psp
//         await updateCredentials();

//         /// verify new credentials
//         return await verifyCredentials(checkOnlyTokenCredential: true);
//       } else {
//         /// Refresh token attempt failed
//         /// Finally not logged in
//         tokenCredential = null;
//         return false;
//       }
//     } catch (e) {
//       /// Gateway not reachable or 500
//       return false;
//     }
//   }

//   void login(String email, password) async {
//     setState(() {
//       loginError = false;
//     });

//     loggedIn = await verifyCredentials();
//     dev.log('$_tag '
//         'LOGGED IN : $loggedIn');

//     if (loggedIn != true) {
//       try {
//         await request(
//             LoginUser.param(password: password, username: email, remember: 1));
//       } catch (e) {
//         setState(() {
//           loginError = true;
//         });
//         return;
//       }
//     }

//     setState(() {
//       loggedIn = true;
//     });
//   }

//   void getServiceAccess() async {
//     final url = await request(GetWebAccess.param(code: codeController.text));
//     if (!mounted) return;
//     final navigator = Navigator.of(context);

//     dev.log(
//         "SERVICE URL: ${url.webLink.replaceAll(r"https://", "wss://")}jrpc");

//     final ep = MTWebSocketEndpoint(
//         name: "",
//         info: MTMDNSRecord(),
//         cookie: credentials()["Cookie"] ?? "",
//         protocolName: "CentronicPLUS",
//         lastSeen: DateTime.now(),
//         url: "${url.webLink.replaceAll(r"https://", "wss://")}jrpc");
//     final centronicPlus = CentronicPlus();
//     ep.openWith(centronicPlus);
//     ep.onClose = () {
//       context.go("/");
//     };
//     centronicPlus.initEndpoint(readMesh: true);
//     CPHome.go(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (loginError) Text("Ungültige E-Mail oder Passwort".i18n),
//         if (!loggedIn)
//           TextFormField(
//             controller: emailController,
//             decoration: const InputDecoration(hintText: 'Email'),
//           ),
//         if (!loggedIn) const UICSpacer(2),
//         if (!loggedIn)
//           TextFormField(
//             controller: passwordController,
//             decoration: const InputDecoration(hintText: 'Password'),
//           ),
//         if (!loggedIn) const UICSpacer(2),
//         if (!loggedIn)
//           GestureDetector(
//             onTap: () {
//               login(emailController.text.toString(),
//                   passwordController.text.toString());
//             },
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                   color: Colors.green, borderRadius: BorderRadius.circular(10)),
//               child: Center(
//                 child: Text('Anmelden'.i18n),
//               ),
//             ),
//           ),
//         if (loggedIn)
//           TextFormField(
//             controller: codeController,
//             decoration: const InputDecoration(hintText: 'Service-Code'),
//           ),
//         if (loggedIn) const UICSpacer(2),
//         if (loggedIn)
//           GestureDetector(
//             onTap: () {
//               getServiceAccess();
//             },
//             child: Container(
//               height: 50,
//               decoration: BoxDecoration(
//                   color: Colors.green, borderRadius: BorderRadius.circular(10)),
//               child: Center(child: Text('Weiter'.i18n)),
//             ),
//           ),
//       ],
//     );
//   }
// }
