/// The plugin library
library xcf_protocol;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:hex/hex.dart';
import 'package:mt_interface/const.dart';
import 'package:mt_interface/message.dart';
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/queue.dart';
import 'package:collection/collection.dart';

export 'package:hex/hex.dart';

part 'package:xcf_protocol/queue/xcf_queue.dart';
part 'package:xcf_protocol/queue/event_listener.dart';
part 'package:xcf_protocol/mutators.dart';
part 'package:xcf_protocol/generated/message.dart';
part 'package:xcf_protocol/models/fault.dart';
part 'package:xcf_protocol/models/company_info.dart';
part 'package:xcf_protocol/parameters.dart';
part 'package:xcf_protocol/const.dart';


class XCFSetupState {
  final bool posZuBekannt;
  final bool posRWABekannt;
  final bool posTeilAuf;
  final bool posAufBekannt;
  final bool drehsinnBekannt;
  final bool drehsinn;
  
  const XCFSetupState({
    required this.posZuBekannt,
    required this.drehsinn,
    required this.posTeilAuf,
    required this.posRWABekannt,
    required this.drehsinnBekannt,
    required this.posAufBekannt,
  });

  factory XCFSetupState.fromPayload(int payload) {
    return XCFSetupState(
      posZuBekannt: payload & 0x01 == 0x01,
      posRWABekannt: payload & 0x02 == 0x02,
      posTeilAuf: payload & 0x04 == 0x04,
      posAufBekannt: payload & 0x08 == 0x08,
      drehsinnBekannt: payload & 0x10 == 0x10,
      drehsinn: payload & 0x20 == 0x20,
    );
  }

  static get empty => const XCFSetupState(
    posZuBekannt: false,
    drehsinn: false,
    posTeilAuf: false,
    posRWABekannt: false,
    drehsinnBekannt: false,
    posAufBekannt: false,
  );
}

enum XCFCommand {
  DI_AUF,          // 0    
  DI_AB,           // 1
  DI_FE1,          // 2
  DI_FE2,          // 3
  DI_SE1,          // 4
  DI_VE1,          // 5
  DI_VE2,          // 6
  DI_VE3,          // 7
  DI_VE4,          // 8
  DI_VE5,          // 9
  DI_VE6,          // 10
  DI_PROG,         // 11
  DI_NA_TEST_DYN,  // 12
  DI_SK_SI_KR,     // 13
  DI_REL_TEST,     // 14
  DI_HILFSKONTAKT, // 15
  DI_BREMSE_ASB_TEST_CTRL, // 16
  DI_ANZAHL,       // 17
}

class XCFProtocol<Message_T extends XCFMessage>
  extends MTReaderWriter<Message_T, List<int>, XCFProtocol> {
    
  final _queue          = _XCFQueue();
  List<int> _readBuffer = [];
  final _stx            = 0x02;                    /// [_stx] telegram start byte
  late final stx        = ascii.decode([_stx]);
  final _etx            = 0x03;                    /// [_etx] telegram stop byte
  late final etx        = ascii.decode([_etx]);

  Map<String, XCFParameterInfo> parameters = {}; // XCF Parameter List
  Map<String, XCFParameterInfo> parameterDefinitions = {}; // XCF Parameter List
  bool loadingParameters = false; /// Whether the parameters are still loading

  @override
  void read(data) {
    _readBuffer.addAll(data);

    while (_readBuffer.contains(_etx) && _readBuffer.contains(_stx)) {
      final start = _readBuffer.indexOf(_stx);
      final end   = _readBuffer.indexOf(_etx);
      if(start > end) {
        endpoint.logMessage(tag: MTLogTags.info, message: '${MTLogTags.dropped} DROPPED (INVALID STX): ${ascii.decode(_readBuffer.sublist(0, start - 1))} ${_readBuffer.sublist(0, start - 1)} $start $end');
        _readBuffer = _readBuffer.sublist(end + 1, _readBuffer.length);
      } else {
        try {
          final sublist      = _readBuffer.sublist(start + 1, end);
          // endpoint.logMessage(message: '<<< ${asciiDecoded.replaceAllMapped(RegExp(r".{2}"), (match) => "${match.group(0)} ")}');
          if(!_queue.unpack(sublist)) {
            /// Queue didn't unpack a message we'll log it here instead...
            endpoint.logMessage(message: "${sublist}", tag: MTLogTags.unhandled);
          }
        } catch(e) {
          final sublist      = _readBuffer.sublist(start + 1, end);
          final asciiDecoded = ascii.decode(sublist);
          endpoint.logMessage(message: asciiDecoded, tag: MTLogTags.error);
          endpoint.logMessage(message: e.toString(), tag: MTLogTags.error);
        }
        _readBuffer = _readBuffer.sublist(end + 1);
      }
    }
  }

  Future<T?> _write<T extends Message_T>(T message) async {
    await _queue.add(message);
    print(">>> ${HEX.encode(message.unpackedRequest ?? [])}");
    await endpoint.write(message.packedRequest ?? []);
    await message.completer.future;
    print("<<< ${HEX.encode(message.unpackedResponse ?? [])}");
    print('''[${message.rspCommand! == message.reqCommand ? '✅' : '❌'} ${_TEL_DESCRIPTORS[message.rspCommand]} Response] protocol ${message.rspProtocol} command ${message.rspCommand} length ${message.rspLength} ${message.rspLength == message.unpackedResponse?.length ? '✅' : '❌'} payload ${message.rspPayload} checksum ${message.rspChecksum} ${message.rspChecksumValid == true ? '✅' : '❌'}''');
    return message;
  }

  @override
  Future<void> writeMessage(Message_T message) async {
    await _write(message);
  }

  @override
  Future<T?> writeMessageWithResponse<T extends Message_T>(T message) async {
    return await _write(message);
  }
  
  @override
  void notifyListeners() => updateStream.add(this);

  loadParameterDefinitions (String json) {
    parameterDefinitions = XCFParameterInfo.fromJsonList(json);
  }

  Future<XCFMessage?> _writeRaw(int reqTel, {
    withResponse = true,
    List<int> payload = const []
  }) async {
    final message = XCFMessage(
      reqCommand: reqTel,
      reqPayload: payload,
      withResponse: withResponse
    );
    await writeMessageWithResponse<Message_T>(message as Message_T);

    return message;
  }

  Future<List<int>?> getBusVersion () async {
    final result = await _writeRaw(_TEL.TEL_BUSPROTOCOL, withResponse: true);
    return result?.rspPayload;
  }

  Future<List<int>?> calibrate () async {
    final result = await _writeRaw(_TEL.TEL_SET_ROTATION_SPEED, payload: [0x00, 0x01], withResponse: true);
    return result?.rspPayload;
  }

  Future<(String, String)?> getVersion () async {
    final result = await _writeRaw(_TEL.TEL_VERSION, withResponse: true);
    final hexEncoded = HEX.encode(result?.rspPayload ?? []);
    final articleId = hexEncoded.substring(0, 11);
    final version = hexEncoded[hexEncoded.length - 1]; 
    // print("articleId: $articleId version: $version");
    return (articleId, version);
  }

  Future<String?> getName () async {
    final result = await _writeRaw(_TEL.TEL_NAME, withResponse: true);
    // print("name: ${ascii.decode(result?.rspPayload ?? [])}");
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<XCFMessage?> getLevel () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_LEVEL, withResponse: true);
    return result;
  }

  Future<XCFMessage?> setLevel () async {
    final result = await _writeRaw(_TEL.TEL_SET_LEVEL, withResponse: true);
    return result;
  }

  Future<XCFMessage?> sendCommand (XCFCommand command) async {
    final result = await _writeRaw(_TEL.TEL_SET_INPUT, payload: [command.index, 1],  withResponse: true);
    return result;
  }

  Future<XCFMessage?> toggleRotaryDirection (int direction) async {
    // FIXME: Explain parameter code 130
    // final currentValue = (await getParameter("130"))?.value ?? 0;

    final param = parameters["130"]?.copyWith(
      value: [
        0x00,
        direction,
      ]
    );
    
    final result = await _writeRaw(_TEL.TEL_SET_PARAM,
      payload: param?.getPayload() ?? [],
      withResponse: true
    );

    return result;
  }

  Future<XCFMessage?> enterParamMode () async {
    final result = await _writeRaw(_TEL.TEL_PARAMETERISATION_ON, withResponse: true);
    return result;
  }

  Future<XCFMessage?> leaveParamMode () async {
    final result = await _writeRaw(_TEL.TEL_PARAMETERISATION_OFF, withResponse: true);
    return result;
  }

  Future<XCFMessage> _resetParameterPointer () async {
    final result = await _writeRaw(_TEL.TEL_START_FIRST_PARAM, withResponse: true);

    if(result == null) {
      throw Exception("XCF: getFirstParam failed");
    }

    return result;
  }

  Future<XCFSetupState?> readSetup () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_LIMIT, withResponse: true);

    if(result?.rspPayload?.isNotEmpty == true) {
      return XCFSetupState.fromPayload(result!.rspPayload!.first);
    } else {
      return XCFSetupState.empty;
    }
  }

  Future<XCFParameterInfo?> _getNextParam () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_PARAM_NEXT, withResponse: true);
    if(result == null) {
      throw Exception("XCF: getNextParam failed");
    }

    final rawCode = result.rspPayload?.sublist(0, 2) ?? [0,0];
    final String code = XCFParameterInfo.decodeParameterId(rawCode);

    final info = parameterDefinitions[code]?.copyWith(
      value: result.rspPayload?.sublist(2) ?? [0,0]
    );

    print("getNextParam - HEX: ${code} DEC: ${result.rspPayload?.sublist(0, 2) ?? []} Value: ${result.rspPayload?.sublist(2) ?? []}");
    
    return info;
  }

  Future<void> loadAllParameters ({
    required int userRole,
    bool forceReload = false
  }) async {
    if((parameters.isNotEmpty || loadingParameters) && !forceReload) {
      return;
    }

    parameters.clear();
    loadingParameters = true;
    notifyListeners();

    String firstParameter = XCFParameterInfo.decodeParameterId(
      (await _resetParameterPointer()).rspPayload ?? [0,0]);
    XCFParameterInfo? result = await _getNextParam();

    while(true) {
      if(result != null) {
        parameters[result.id] = result;
      }
      
      result = await _getNextParam();
      
      if(result?.id == firstParameter) {
        break;
      }
    }

    loadingParameters = false;
    notifyListeners();
  }


  Future<void> setAllParameters () async {
    for (final parameter in parameters.values) {
      await setParameter(parameter);
    }
  }

  Future<XCFParameterInfo?> getParameter (String id) async {
    if(id == "846") {
      print("test");
    }
    final code = HEX.decode(id.padLeft(4, '0'));
    final result = await _writeRaw(_TEL.TEL_QUERY_PARAM, payload: [code[0], code[1]], withResponse: true);
    final parameter = parameterDefinitions[id]?.copyWith(
      value: result?.rspPayload?.sublist(2) ?? [0,0]
    );
    return parameter;
  }

  Future<void> setParameter (XCFParameterInfo parameter) async {
    final payload = parameter.getPayload();
    await _writeRaw(_TEL.TEL_SET_PARAM, payload: payload, withResponse: true);
  }

  Future<XCFMessage?> setDwellTime (int dwellTime) async {
    // FIXME: Explain parameter code 846
    final param = parameters["846"]?.copyWith(
      value: [
        (dwellTime >> 8) & 0xFF,
        dwellTime & 0xFF
      ]
    );
    
    if(param != null) {
      await setParameter(param);
    }
  }

  Future<int> getDwellTime () async {
    final result = await getParameter("846");
    return int.tryParse(result?.value ?? "") ?? 0;
  }

  Future<void> setEndPosition (XCFEndPosition value) async {
    final param = parameters["210"]?.copyWith(
      value: [
        0x00,
        value.index
      ]
    );

    if(param != null) {
      await setParameter(param);
    }
  }

  Future<void> setIntermediatePosition (XCFIntermediatePosition value) async {
    final param = parameters["244"]?.copyWith(
      value: [
        0x00,
        value.index
      ]
    );

    if(param != null) {
      await setParameter(param);
    }
  }

  Future<double> readPosition () async {
    // 230,

    final param230 = await getParameter("230");
    final param220 = await getParameter("220");
    final param950 = await getParameter("950");

    int min = int.parse(param220!.value);
    int max = int.parse(param230!.value);

    int waylen = max - min;

    final value = 1 - (int.parse(param950!.value) / waylen);

    return value;
  }
  

  Future<XCFParameterInfo?> getIntermediatePosition () async {
    final result = await getParameter("210");
    return result;
  }
  
  Future<List<XCFFault>?> getFaultInfos () async {
    List<XCFFault> faultsInfo = [];
    for(int i = 0; i < 20; i++) {
      final info = await getNextFaultInfo();
      print("test");
      if(info != null) {
        faultsInfo.add(info);
      }
    }

    return faultsInfo.toList();
  }

  Future<XCFFault?> getNextFaultInfo () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_FAULT_INFO, withResponse: true);
    return XCFFault.fromPayload(result?.rspPayload ?? [0xFF]);
  }

  Future<List<int>?> getInputs () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_INPUTS, withResponse: true);
    return result?.rspPayload;
  }

  Future<bool?> queryBreakRelais () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_OUTPUTS, payload: [TEL_OUTPUT.DO_FA03_REL3.index], withResponse: true);
    print("BreakState: ${result?.rspPayload}");

    return ((result?.rspPayload?.firstOrNull ?? 0) & 0x10) > 0; // FIXME: EXPLAIN Bitmask
  }

  Future<bool?> queryFE1 () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_INPUTS, payload: [_TEL_INPUT.DI_FE1.index], withResponse: true);

    return ((result?.rspPayload?.firstOrNull ?? 0) & 0x04) > 0; // FIXME: EXPLAIN Bitmask
  }

  Future<bool?> queryFE2 () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_INPUTS, payload: [_TEL_INPUT.DI_FE2.index], withResponse: true);
    return (result?.rspPayload?.firstOrNull ?? 0) > 0;
  }

  Future<bool?> queryMaintenanceRelais () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_OUTPUTS, payload: [TEL_OUTPUT.DO_FA02_REL2.index], withResponse: true);
    
    return ((result?.rspPayload?.firstOrNull ?? 0) & 0x10) > 0; // FIXME: EXPLAIN Bitmask
  }

  Future<bool?> queryVDCIn () async {
    // final result = await _writeRaw(_TEL.TEL_QUERY_INPUTS, payload: [_TEL_INPUT.DI_SE1.index], withResponse: true);
    // return (result?.rspPayload?.firstOrNull ?? 0) > 0;
    return false;
  }

  Future<bool?> queryEndPositionTopRelais () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_OUTPUTS, payload: [TEL_OUTPUT.DO_FA01_REL1.index], withResponse: true);
    return (result?.rspPayload?.firstOrNull ?? 0) > 0;
  }

  Future<int?> getCycleCount () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_CYCLE_COUNT, withResponse: true);
    return result?.rspPayload?.first;
  }

  Future<int?> getServiceCount () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_SERVICE_COUNT, withResponse: true);
    return result?.rspPayload?.first;
  }

  Future<int?> getPosition () async {
    final result = await _writeRaw(_TEL.TEL_READPOSITION, withResponse: true);
    return result?.rspPayload?.first;
  }

  Future<double?> getTemperature () async {
    final result = await _writeRaw(_TEL.TEL_READTEMPERATURE, withResponse: true);
    if(result?.rspPayload != null && result!.rspPayload!.length >= 1) {
      return result.rspPayload?.first.toDouble();
    }
    return null;
  }

  Future<DateTime?> getTime () async {
    // FIXME: Verify
    final result = await _writeRaw(_TEL.TEL_QUERY_DATUM_ZEIT, withResponse: true);
    if (result?.rspPayload != null && result!.rspPayload!.length >= 6) {
      final year = result.rspPayload![0] + 2000;
      final month = result.rspPayload![1];
      final day = result.rspPayload![2];
      final hour = result.rspPayload![3];
      final minute = result.rspPayload![4];
      final second = result.rspPayload![5];
      return DateTime(year, month, day, hour, minute, second);
    }
    return null;
  }

  Future<void> setInputs(List<int> inputs) async {
    await _writeRaw(_TEL.TEL_SET_INPUTS, payload: inputs, withResponse: true);
  }

  Future<XCFMessage> queryState () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_STATE, withResponse: true);
    return result!;
  }

  Future<XCFMessage> setOutput (int output, bool value) async {
    final result = await _writeRaw(_TEL.TEL_SET_OUTPUT, payload: [output, value ? 1 : 0], withResponse: true);
    return result!;
  }

  Future<double> getRotationSpeed () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_ROTATION_SPEED, withResponse: true);
    return result?.rspPayload?.first.toDouble() ?? 0;
  }

  Future<void> setPassword (String password) async {
    final passwordBytes = ascii.encode(password);
    await _writeRaw(_TEL.TEL_SET_PASSWORD, payload: passwordBytes, withResponse: true);
  }

  Future<XCFCompanyInfo> getCompanyInfo () async {
    final companyName     = await _getCompanyName();
    final projectId       = await _getProjectId();
    final technicianName  = await _getTechnicianName();
    final projectLocation = await _getProjectLocation();
    final projectName     = await _getProjectName();
    final projectCountry  = await _getProjectCountry();
    final projectCity     = await _getProjectCity();
    final projectPostcode = await _getProjectPostcode();
    final projectStreet   = await _getProjectStreet();
    final comment1        = await _getComment1();
    final comment2        = await _getComment2();
    final comment3        = await _getComment3();

    return XCFCompanyInfo(
      companyName: (companyName ?? "").trim(),
      projectId: (projectId ?? "").trim(),
      technicianName: (technicianName ?? "").trim(),
      projectLocation: (projectLocation ?? "").trim(),
      city: (projectCity ?? "").trim(),
      country: (projectCountry ?? "").trim(),
      postcode: (projectPostcode ?? "").trim(),
      street: (projectStreet ?? "").trim(),
      comment1: (comment1 ?? "").trim(),
      comment2: (comment2 ?? "").trim(),
      comment3: (comment3 ?? "").trim(),
      projectName: (projectName ?? "").trim(),
    );
  }

  Future<void> setCompanyInfo (XCFCompanyInfo companyInfo) async {
    await _setCompanyName(companyInfo.companyName);
    await _setProjectId(companyInfo.projectId);
    await _setTechnicianName(companyInfo.technicianName);
    await _setProjectLocation(companyInfo.projectLocation);
    await _setProjectName(companyInfo.projectName);

    await _setProjectCountry(companyInfo.country);
    await _setProjectCity(companyInfo.city);
    await _setProjectPostcode(companyInfo.postcode);
    await _setProjectStreet(companyInfo.street);
    await _setComment1(companyInfo.comment1);
    await _setComment2(companyInfo.comment2);
    await _setComment3(companyInfo.comment3);
    // await _setProjectAddress(companyInfo.address);
  }

  Future<void> _setProjectName (String projectName) async {
    final bauvorhabenBytes = ascii.encode(projectName);
    await _writeRaw(_TEL.TEL_SET_BAUVORHABEN, payload: bauvorhabenBytes, withResponse: true);
  }

  Future<void> _setProjectCountry (String country) async {
    final landBytes = ascii.encode(country);
    await _writeRaw(_TEL.TEL_SET_LAND, payload: landBytes, withResponse: true);
  }

  Future<void> _setProjectCity (String city) async {
    final ortBytes = ascii.encode(city);
    await _writeRaw(_TEL.TEL_SET_ORT, payload: ortBytes, withResponse: true);
  }

  Future<void> _setProjectPostcode (String postcode) async {
    final postleitzahlBytes = ascii.encode(postcode);
    await _writeRaw(_TEL.TEL_SET_POSTLEITZAHL, payload: postleitzahlBytes, withResponse: true);
  }

  Future<void> _setProjectStreet (String street) async {
    final strasseBytes = ascii.encode(street);
    await _writeRaw(_TEL.TEL_SET_STRASSE, payload: strasseBytes, withResponse: true);
  }

  Future<void> _setComment1 (String comment1) async {
    final zusatz1Bytes = ascii.encode(comment1);
    await _writeRaw(_TEL.TEL_SET_ZUSATZ_1, payload: zusatz1Bytes, withResponse: true);
  }

  Future<void> _setComment2 (String comment2) async {
    final zusatz2Bytes = ascii.encode(comment2);
    await _writeRaw(_TEL.TEL_SET_ZUSATZ_2, payload: zusatz2Bytes, withResponse: true);
  }

  Future<void> _setComment3 (String comment3) async {
    final zusatz3Bytes = ascii.encode(comment3);
    await _writeRaw(_TEL.TEL_SET_ZUSATZ_3, payload: zusatz3Bytes, withResponse: true);
  }

  Future<String?> _getProjectName () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_BAUVORHABEN, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);    
  }

  Future<String?> _getProjectCountry () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_LAND, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<String?> _getProjectCity () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_ORT, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<String?> _getProjectPostcode () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_POSTLEITZAHL, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<String?> _getProjectStreet () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_STRASSE, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<String?> _getComment1 () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_ZUSATZ_1, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<String?> _getComment2 () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_ZUSATZ_2, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<String?> _getComment3 () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_ZUSATZ_3, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<void> _setProjectLocation (String projectLocation) async {
    final montageortBytes = ascii.encode(projectLocation);
    await _writeRaw(_TEL.TEL_SET_MONTAGEORT, payload: montageortBytes, withResponse: true);
  }

  Future<String?> _getProjectLocation () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_MONTAGEORT, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<void> _setTechnicianName (String monteur) async {
    final monteurBytes = ascii.encode(monteur);
    await _writeRaw(_TEL.TEL_SET_MONTEUR, payload: monteurBytes, withResponse: true);
  }

  Future<String?> _getTechnicianName () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_MONTEUR, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<void> _setCompanyName (String companyName) async {
    final firmaBytes = ascii.encode(companyName);
    await _writeRaw(_TEL.TEL_SET_FIRMA, payload: firmaBytes, withResponse: true);
  }

  Future<String?> _getCompanyName () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_FIRMA, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }

  Future<void> _setProjectId (String projectId) async {
    final projektNummerBytes = ascii.encode(projectId);
    await _writeRaw(_TEL.TEL_SET_PROJEKTNUMMER, payload: projektNummerBytes, withResponse: true);
  }

  Future<String?> _getProjectId () async {
    final result = await _writeRaw(_TEL.TEL_QUERY_PROJEKTNUMMER, withResponse: true);
    return ascii.decode(result?.rspPayload ?? []);
  }
}

