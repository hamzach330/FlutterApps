part of xcf_protocol;

/// Collection of functions to convert between integer values and Dart types
abstract class XCFMutators {
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
        return utf8.decode(listintval.sublist(0, end));
      } catch(e) {
        return "Malformed utf8";
      }
    } else {
      return utf8.decode(listintval);
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

  static List<int> fromSync (int intval) {
    return [intval & 0xFF, (intval >> 8) & 0xFF];
  }

  static int toSync (List<int> listval) {
    return listval[0] | (listval[1] << 8);
  }


}

/// Return true if [bit] at position is set for [value]
bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;
