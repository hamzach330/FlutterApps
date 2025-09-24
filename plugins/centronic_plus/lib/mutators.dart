part of '../centronic_plus.dart';

/// Collection of functions to convert between integer values and Dart types
abstract class Mutators {
  static String toHexString(List<int> byteval) {
    return HEX.encode(byteval);
  }

  static String toVersionString(List<int> byteval) {
    return byteval.join(".");
  }

  static String toHexByte(int byteval) {
    return HEX.encode([byteval]);
  }

  static List<int> fromHexString(String? stringval, int length) {
    if(stringval == null) return List.filled(length, 0x00);
    return HEX.decode(stringval);
  }

  static int toInt(int intval) {
    return intval;
  }

  static int fromInt(int intval) {
    return intval;
  }

  static bool toBool(int boolval) {
    return boolval > 0;
  }

  static int fromBool(bool boolval) {
    return boolval ? 1 : 0;
  }

  static List<int> fromInt16(int intval, int len) {
    if(intval < 256) {
      return [0, intval];
    } else {
      return [intval >> 8, intval & 0xFF];
    }
  }

  static int toInt16(List<int> intval) {
    return intval[0] | (intval[1] << 8);
  }

  static List<int> toIntList(List<int> listval) {
    return listval;
  }

  static List<int> fromIntList(List<int> listval) {
    return listval;
  }

  static CPInitiator? toInitiator (int initiatorval) {
    return CPInitiator.values.firstWhereOrNull((initiator) => initiator.value == initiatorval);
  }

  static int fromInitiator (CPInitiator initiatorval) {
    return initiatorval.value;
  }

  static CPDatatype? toDatatype (int datatypeval) {
    return CPDatatype.values.firstWhereOrNull((datatype) => datatype.value == datatypeval);
  }

  static int fromDatatype (CPDatatype datatypeval) {
    return datatypeval.value;
  }


  static List<int> fromFilledList(int value, int length) {
    return List.filled(length, value);
  }

  /// default names are misformatted!?
  /// This will remove the last 4 bytes (priority / timeout bytes) in order to parse the name
  /// Once the name is configured manually this shouldn't happen
  static String toUtf8String (List<int> listintval) {
    if(listintval.contains(0x00)) {
      try {
        final end = listintval.indexOf(0x00);
        return utf8.decode(listintval.sublist(0, end)).trim();
      } catch(e) {
        return "Malformed utf8";
      }
    } else {
      return utf8.decode(listintval).trim();
    }
  }

  static List<int> fromUtf8String (String stringval, int length) {
    final data = utf8.encode(stringval);
    final stringLength = data.length;
    List<int>? retval;

    if(length > data.length) {
      retval = [...data, ...List.filled(length - stringLength, 0x00)];
    } else if(length == data.length) {
      retval = [...data];
    } else {
      throw MTConvertException("Tried encoding a utf8 string which is too long. (actual: $stringLength max: $length)");
    }

    return retval;
  }

  static toDriveStateFlags (List<int> listintval) {
    return DriveStateFlags(
      value: listintval
    );
  }

  static List<int> fromSync (int intval) {
    return [intval & 0xFF, (intval >> 8) & 0xFF];
  }

  static int toSync (List<int> listval) {
    return listval[0] | (listval[1] << 8);
  }

  static AnalogValues toAnalogValues(List<int> listintval) {
    return AnalogValues(raw: listintval);
  }

}

/// Return true if [bit] at position is set for [value]
bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class AnalogValues {
  bool? sensorLoss;
  int? sxdResetCount;

  static _findClosestIndex(List<int> values, value) {
    if(values.contains(value) == true) {
      return values.indexOf(value);
    } else {
      final greaterValues = values.where((e) => e > value).toList();
      if(greaterValues.isEmpty) return values.length - 1;
      
      final lowerValues = values.where((e) => e < value).toList();
      if(lowerValues.isEmpty) return 0;

      if((greaterValues.first - lowerValues.first) / 2 + lowerValues.first > value) {
        return values.indexOf(lowerValues.first);
      } else {
        return values.indexOf(greaterValues.first);
      }
    }
  }

  // Actual value
  static const typeMap = {
    "0": "wind",
    "1": "sun",
    "2": "dawn",
    "3": "rain",
    "4": "frost",
    "5": "temp",
    "6": "tempOut",
    "f": "battery"
  };

  final _calcMap = {
    "0": (int val) => "${_findClosestIndex(windMap, val)} / 11",
    "1": (int val) => "${_findClosestIndex(sunMap, val)} / 15",
    "2": (int val) => "${_findClosestIndex(duskMap, val)} / 15",
    "3": (int val) => val > 0 ? "Regen" : "Kein Regen",
    "4": (int val) => double.parse((val / 256 - 100).toStringAsFixed(1)) > 4 ? "Kein Frost" : "Frost",
    "5": (int val) => "${(val / 256 - 100).toStringAsFixed(1)} °C",
    "6": (int val) => "${(val / 256 - 100).toStringAsFixed(1)} °C",
    "f": (int val) => "${(val / 65535 * 100).round()} %",
  };

  static const sunMap = [
    0,
    500,
    1800,
    3200,
    4500,
    5800, // -> 
          // -> 7100
    7200, // -> 
    8500,
    9800,
    11200,
    12500,
    15000,
    17500,
    20000,
    22500,
    25000,
  ];

  static int toSunLevel (int sunValue) {
    return _findClosestIndex(sunMap, sunValue);
  }

  static List<int> fromSunLevel (int level) {
    return fromInt16(sunMap[level]);
  }

  static const windMap = [
    0,
    512,
    1024,
    1536,
    2048,
    2560,
    3072,
    3584,
    4096,
    4608,
    5120,
    5632,
  ];

  static int toWindLevel (int windValue) {
    return _findClosestIndex(windMap, windValue);
  }

  static List<int> fromWindLevel (int level) {
    return fromInt16(windMap[level]);
  }

  static const duskMap = [
    0,
    2560,
    5120,
    7680,
    10240,
    12800,
    15360,
    17920,
    20480,
    23040,
    25600,
    28160,
    30720,
    33280,
    35840,
    38400,
  ];

  static int toDuskLevel (int duskValue) {
    return _findClosestIndex(duskMap, duskValue);
  }

  static List<int> fromDuskLevel (int level) {
    return fromInt16(duskMap[level]);
  }

  static List<int> fromInt16(int intval) {
    if(intval < 256) {
      return [intval, 0];
    } else {
      return [intval & 0xFF, intval >> 8];
    }
  }

  final List<int> raw;
  final Map<String, dynamic> values = {};
  final Map<String, dynamic> unmappedValues = {};
  bool downLock = false;
  bool upLock   = false;
  // double? value;

  AnalogValues({
    required this.raw
  }) {
    values["value"] = ((raw[0] | (raw[1] << 8)) / 0xFFFF) * 100;

    int startByte = 2;
    int endByte = 4;

    while(raw.length > startByte) {
      final dtv       = Mutators.toHexByte(raw[startByte]);
      final valueList = raw.sublist(startByte + 1, endByte + 1);
      final value     = valueList[1] << 8 | valueList[0];
      startByte       = endByte + 1;
      endByte         = startByte + 2;

      final hi = dtv[0].toLowerCase();
      final lo = dtv[1].toLowerCase();

      if(dtv == "08") {
        sensorLoss = checkBit(valueList[0], 0);
      }

      if(dtv == "ff") {
        values["matrix"] = value;
      } else if(dtv == "09") {
        values["runtime"] = value * 100;
      } else if(dtv == "0a") {
        values["turntime"] = value * 100;
      } else if(dtv == "0b") {
        values["pulsetime"] = value * 100;
      } else if(hi == "0" && lo == "2") {
        if(checkBit(value, 6)) downLock = true;
        if(checkBit(value, 5)) upLock   = true;
      } else if(dtv == "e0") {
        sxdResetCount = value;
      } else {
        if(lo == "0") {
          values["${typeMap[hi]}"] = _calcMap[hi]?.call(value);
          unmappedValues["${typeMap[hi]}"] = value;
        } else if(lo == "1") {
          values["${typeMap[hi]}-thres-hi"] = value;
          unmappedValues["${typeMap[hi]}-thres-hi"] = value;
        } else if(lo == "2") {
          values["${typeMap[hi]}-thres-lo"] = value;
          unmappedValues["${typeMap[hi]}-thres-lo"] = value;
        } else if(lo == "3") {
          values["${typeMap[hi]}-delay-hi"] = value;
          unmappedValues["${typeMap[hi]}-delay-hi"] = value;
        } else if(lo == "4") {
          values["${typeMap[hi]}-delay-lo"] = value;
          unmappedValues["${typeMap[hi]}-delay-lo"] = value;
        } else if(lo == "5") {
          values["${typeMap[hi]}-delay-err"] = value;
          unmappedValues["${typeMap[hi]}-delay-err"] = value;
        } else if(lo == "6") {
          values["${typeMap[hi]}-priority"] = value;
          unmappedValues["${typeMap[hi]}-priority"] = value;
        } else if(lo == "7") {
          values["${typeMap[hi]}-safety"] = value;
          unmappedValues["${typeMap[hi]}-safety"] = value;
        } else if(lo == "8") {
          values["${typeMap[hi]}-automatic"] = value;
          unmappedValues["${typeMap[hi]}-automatic"] = value;
        } else if(lo == "f") {
          values["slat"] = (value  / 0xFFFF) * 100;
          unmappedValues["slat"] = value;
        }
      }
    }
  }

  @override
  toString() {
    return values.toString();
  }
}

/// Drive states are set as bitmaps
class DriveStateFlags {

  bool get hasWarning => hasObstacle == true
    || thermoPill == true
    || locked == true
    || windAlert == true
    || rain == true
    || sensorValueOverride == true
    || sunProtectionPosition == true;

  int get warningCount => [
    locked,
    thermoPill,
    hasObstacle,
    windAlert,
    rain,
    sunProtectionPosition,
    sensorValueOverride,
  ].map((v) => v ? 1 : 0).reduce((a, b) => a + b);

  bool get hasCriticalState => windAlert == true
    || thermoPill == true
    || hasObstacle == true;

  // Actual value
  final List<int> value;

  // Byte 1
  late bool drivesUp;
  late bool drivesDown;
  late bool inUpperEndPosition;
  late bool inLowerEndPosition;
  late bool endPositionInstalled;
  late bool locked;
  late bool thermoPill;
  late bool hasObstacle;

  // Byte 2
  late bool windAlert;
  late bool sunProtectionPosition;
  late bool rain;
  late bool sensorValueOverride;
  late bool freezeProtectEnabled;
  late bool flyScreenEnabled;
  late bool memoAutoEnabled;
  late bool sunAutoEnabled;

  @override
  toString() {
    return """BITMAP OF $value: 
    b0 : drivesUp: $drivesUp
    b1 : drivesDown: $drivesDown
    b2 : inUpperEndPosition: $inUpperEndPosition
    b3 : inLowerEndPosition: $inLowerEndPosition
    b4 : endPositionInstalled: $endPositionInstalled
    b5 : locked: $locked
    b6 : thermoPill: $thermoPill
    b7 : hasObstacle: $hasObstacle
    b8 : windAlert: $windAlert
    b9 : sunProtectionPosition: $sunProtectionPosition
    b10: rain: $rain
    b11: sensorValueOverride: $sensorValueOverride
    b12: freezeProtectEnabled: $freezeProtectEnabled
    b13: flyScreenEnabled: $flyScreenEnabled
    b14: memoAutoEnabled: $memoAutoEnabled
    b15: sunAutoEnabled: $sunAutoEnabled""";
  }

  DriveStateFlags({
    required this.value
  }):
    drivesUp              = checkBit(value[0], 0),
    drivesDown            = checkBit(value[0], 1),
    inUpperEndPosition    = checkBit(value[0], 2),
    inLowerEndPosition    = checkBit(value[0], 3),
    endPositionInstalled  = checkBit(value[0], 4),
    locked                = checkBit(value[0], 5),
    thermoPill            = checkBit(value[0], 6),
    hasObstacle           = checkBit(value[0], 7),
    windAlert             = checkBit(value[1], 0),
    sunProtectionPosition = checkBit(value[1], 1),
    rain                  = checkBit(value[1], 2),
    sensorValueOverride   = checkBit(value[1], 3),
    freezeProtectEnabled  = checkBit(value[1], 4),
    flyScreenEnabled      = checkBit(value[1], 5),
    memoAutoEnabled       = checkBit(value[1], 6),
    sunAutoEnabled        = checkBit(value[1], 7);
}
