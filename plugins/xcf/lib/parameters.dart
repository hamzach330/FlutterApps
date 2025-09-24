part of xcf_protocol;

class XCFParameterTypes {
  static const String SEK = 'SEK';
  static const String ZERO = '0';
  static const String BOOL = 'BOOL';
  static const String ZAHL = 'ZAHL';
  static const String AE_POS = 'AE_POS';
  static const String FAXX_AF = 'FAXX_AF';
  static const String FEXX_EF = 'FEXX_EF';
  static const String ZAEHLER = 'ZAEHLER';
  static const String ZEIT_MIN = 'ZEIT_MIN';
  static const String ZEIT_SEK = 'ZEIT_SEK';
  static const String PASSWORT = 'PASSWORT';
  static const String AE_OFFSET = 'AE_OFFSET';
  static const String ZEIT_10MS = 'ZEIT_10MS';
  static const String HISTINDEX = 'HISTINDEX';
  static const String EINGPROFIL = 'EINGPROFIL';
  static const String PT_ZEIT_SEK = 'PT_ZEIT_SEK';
  static const String EINSTELLWERT = 'EINSTELLWERT';
  static const String PT_ZEIT_10MS = 'PT_ZEIT_10MS';
  static const String PT_EINSTELLW = 'PT_EINSTELLW';

  static List<String> get all {
    return [
      SEK,
      ZERO,
      BOOL,
      ZAHL,
      AE_POS,
      FAXX_AF,
      FEXX_EF,
      ZAEHLER,
      ZEIT_MIN,
      ZEIT_SEK,
      PASSWORT,
      AE_OFFSET,
      ZEIT_10MS,
      HISTINDEX,
      EINGPROFIL,
      PT_ZEIT_SEK,
      EINSTELLWERT,
      PT_ZEIT_10MS,
      PT_EINSTELLW,
    ];
  }
}

class XCFUserType {
  static const int Torhersteller = 0;
  static const int Service = 1;
  static const int Monteur = 2;
  static const int Kunde = 3;

  static int fromString(String userType) {
    switch(userType) {
      case 'Torhersteller': return Torhersteller;
      case 'Service': return Service;
      case 'Monteur': return Monteur;
      case 'Kunde': return Kunde;
      default: return Kunde;
    }
  }

  static String asString(int userType) {
    switch(userType) {
      case Torhersteller: return 'Torhersteller';
      case Service: return 'Service';
      case Monteur: return 'Monteur';
      case Kunde: return 'Kunde';
      default: return 'Kunde';
    }
  }
}

class XCFParameterInfo {
  final String id;
  final String swName;
  final String funktion;
  final String beschreibung;
  final String paratyp;
  final int? min;
  final int? max;
  final String kurzTextBA;
  final String minMax;
  final Map<int, String> options;
  String value;
  bool obscure = false;

  XCFParameterInfo({
    required this.id,
    required this.swName,
    required this.funktion,
    required this.beschreibung,
    required this.paratyp,
    required this.min,
    required this.max,
    required this.kurzTextBA,
    required this.minMax,
    required this.value,
    required this.obscure,
    this.options = const {},
  });

  static Map<String, XCFParameterInfo> fromJsonList(String json) {
    final Iterable<XCFParameterInfo> paramList = jsonDecode(json)
      .firstWhere((p) => p["type"] == "table")["data"]
      .map((p) => XCFParameterInfo.fromJson(p))?.cast<XCFParameterInfo>();

    return Map.fromEntries(paramList.map((p) => MapEntry(p.id, p)));
  }

  static Map<int, String> parseOptions(String optionsString) {
    final Map<int, String> entries = {};

    for (final line in optionsString.split('\n')) {
      if(line.length > 0) {
        final parts = line.split(':');
        if(parts.length == 2) {
          entries[int.tryParse(parts[0]) ?? 0] = parts[1].trim();
        }
      }
    }
    
    return entries;
  }

  factory XCFParameterInfo.fromJson(Map<String, dynamic> json) {
    return XCFParameterInfo(
      id: json['ID']?.toString().toLowerCase() ?? '',
      swName: json['SW_name'],
      funktion: json['Funktion'],
      beschreibung: json['Beschreibung'],
      paratyp: json['Paratyp'],
      min: int.tryParse(json['Min']),
      max: int.tryParse(json['Max']),
      kurzTextBA: json['kurzTextBA'],
      minMax: json['min_max'],
      value: "",
      obscure: json['Paratyp'] == 'PASSWORT',
      options: parseOptions(json['kurzTextBA'] ?? ''),
    );
  }

  List<int> getPayload () {
    final code = HEX.decode(id.padLeft(4, '0'));
    List<int> payload = [];
    final algebraicSign = 0x00; // 0x00 = positive, 0x01 = negative

    if(paratyp == XCFParameterTypes.PASSWORT) {
      payload = ascii.encode(value);
    } else {
      final minVal = min ?? 0;
      final maxVal = max ?? 0;
      final intVal = int.tryParse(value) ?? minVal;
      payload = [(intVal >> 8) & 0xFF, intVal & 0xFF];
    }

    if(code == "000") {
      print("test");
    }

    return [code[0], code[1], algebraicSign, ...payload];
  }

  XCFParameterInfo copyWith({
    String? id,
    String? swName,
    String? funktion,
    String? beschreibung,
    String? paratyp,
    int? min,
    int? max,
    String? kurzTextBA,
    String? minMax,
    String? wzs,
    int? leserecht,
    int? schreibrecht,
    String? imProfilDeaktiv,
    List<int>? value,
    Map<int, String>? options,
    bool? obscure,
  }) {
    return XCFParameterInfo(
      id: id ?? this.id,
      swName: swName ?? this.swName,
      funktion: funktion ?? this.funktion,
      beschreibung: beschreibung ?? this.beschreibung,
      paratyp: paratyp ?? this.paratyp,
      min: min ?? this.min,
      max: max ?? this.max,
      kurzTextBA: kurzTextBA ?? this.kurzTextBA,
      minMax: minMax ?? this.minMax,
      value: value != null ? _decodeParameter(value) : this.value,
      options: options ?? this.options,
      obscure: obscure ?? this.obscure,
    );
  }

  String _decodeParameter (List<int> rawValue) {
    if(paratyp == XCFParameterTypes.PASSWORT) {
      try {
        return ascii.decode(rawValue);
      } catch (e) {
        return "";
      }
    } else {
      if(id == "846") {
        print("test");
      }
      return (rawValue[0] << 8 | rawValue[1]).toString();
    }
  }

  static String decodeParameterId (List<int> rawCode) {
    return HEX.encode(rawCode).replaceFirst(RegExp(r"^0+"), "").padLeft(3, "0");
  }
}
