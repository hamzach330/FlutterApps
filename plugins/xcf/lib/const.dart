// ignore_for_file: unused_field

part of xcf_protocol;

// ignore: unused_element
class _TEL_OLD {
  static const int TEL_REQUEST = 0x00;
  static const int TEL_BUSPROTOCOL = 0x01;
  static const int TEL_VERSION = 0x02;
  static const int TEL_NAME = 0x03;
  static const int TEL_QUERY_LEVEL = 0x04;
  static const int TEL_SET_LEVEL = 0x05;
  static const int TEL_PARAMETERISATION_ON = 0x06;
  static const int TEL_PARAMETERISATION_OFF = 0x07;
  static const int TEL_QUERY_BAUVORHABEN = 0x08;
  static const int TEL_SET_BAUVORHABEN = 0x09;

  static const int TEL_QUERY_MONTAGEORT = 0x0A;
  static const int TEL_SET_MONTAGEORT = 0x0B;
  static const int TEL_QUERY_MONTEUR = 0x0C;
  static const int TEL_SET_MONTEUR = 0x0D;
  static const int TEL_QUERY_FIRMA = 0x0E;
  static const int TEL_SET_FIRMA = 0x0F;
  static const int TEL_QUERY_PROJEKTNUMMER = 0x10;
  static const int TEL_SET_PROJEKTNUMMER = 0x11;
  
  static const int TEL_SET_PARAM = 0x20;
  static const int TEL_RESULT_SET_PARAM = 0x21;
  static const int TEL_START_STATE_PARAM = 0x22;
  static const int TEL_START_FIRST_PARAM = 0x23;
  static const int TEL_QUERY_PARAM = 0x24;
  static const int TEL_QUERY_PARAM_NEXT = 0x25;
  static const int TEL_SET_PASSWORD = 0x26;
  static const int TEL_FACTORY = 0x27;

  static const int TEL_QUERY_CYCLE_COUNT = 0x30;
  static const int TEL_QUERY_SERVICE_COUNT = 0x31;
  static const int TEL_SET_INPUTS = 0x32;
  static const int TEL_QUERY_INPUTS = 0x33;
  static const int TEL_QUERY_OUTPUTS = 0x34;
  static const int TEL_QUERY_FAULT = 0x35;
  static const int TEL_INPUTS_OUTPUTS = 0x36;
  static const int TEL_QUERY_FAULT_INFO = 0x37;
  static const int TEL_QUERY_LIMIT = 0x38;
  static const int TEL_SET_INPUT = 0x39;
  static const int TEL_QUERY_STATE = 0x3A;
  static const int TEL_SET_OUTPUT = 0x3B;
  static const int TEL_QUERY_ROTATION_SPEED = 0x3C;

  static const int TEL_QUERY_TIME = 0x50;

  static const int TEL_READPOSITION = 0x60;
  static const int TEL_READTEMPERATURE = 0x61;
}

class _TEL {
  static const int TEL_REQUEST = 0x00;
  static const int TEL_BUSPROTOCOL = 0x01;
  static const int TEL_VERSION = 0x02;
  static const int TEL_NAME = 0x03;
  static const int TEL_QUERY_LEVEL = 0x04;
  static const int TEL_SET_LEVEL = 0x05;
  static const int TEL_PARAMETERISATION_ON = 0x06;
  static const int TEL_PARAMETERISATION_OFF = 0x07;

  static const int TEL_QUERY_BAUVORHABEN=0x10;    // 0x10 Adresse / BAUVORHABEN lesen
  static const int TEL_QUERY_STRASSE=0x11;        // 0x11 Adresse / Strasse lesen
  static const int TEL_QUERY_ORT=0x12;            // 0x12 Adresse / Ort lesen
  static const int TEL_QUERY_LAND=0x13;           // 0x13 Adresse / Land lesen
  static const int TEL_QUERY_POSTLEITZAHL = 0x14;   // 0x14 Adresse / Postleitzahl lesen
  static const int TEL_QUERY_ZUSATZ_1 = 0x15;       // 0x15 Adresse / Zustaz 1 lesen
  static const int TEL_QUERY_ZUSATZ_2 = 0x16;       // 0x16 Adresse / Zusatz 2 lesen
  static const int TEL_QUERY_ZUSATZ_3 = 0x17;       // 0x17 Adresse / Zusatz 3 lesen
  static const int TEL_QUERY_MONTAGEORT = 0x18;     // 0x18 Adresse / Montageort lesen
  static const int TEL_QUERY_MONTEUR = 0x19;     // 0x18 Adresse / Montageort lesen
  static const int TEL_QUERY_FIRMA = 0x1A;          // 0x19 Adresse / Firma lesen
  static const int TEL_QUERY_PROJEKTNUMMER = 0x1B;  // 0x1A Adresse / Projektnummer lesen
  static const int TEL_QUERY_DATUM_ZEIT = 0x1C;     // 0x1B Adresse / Datu und Zeit lesen

  static const int TEL_SET_BAUVORHABEN=0x20;        // 0x20 Adresse / BAUVORHABEN setzen
  static const int TEL_SET_STRASSE = 0x21;          // 0x21 Adresse / Strasse setzen
  static const int TEL_SET_ORT = 0x22;              // 0x22 Adresse / Ort setzen
  static const int TEL_SET_LAND = 0x23;             // 0x23 Adresse / Land setzen
  static const int TEL_SET_POSTLEITZAHL = 0x24;     // 0x24 Adresse / Postleitzahl setzen
  static const int TEL_SET_ZUSATZ_1 = 0x25;         // 0x25 Adresse / Zustaz 1 setzen
  static const int TEL_SET_ZUSATZ_2 = 0x26;         // 0x26 Adresse / Zusatz 2 setzen
  static const int TEL_SET_ZUSATZ_3 = 0x27;         // 0x27 Adresse / Zusatz 3 setzen
  static const int TEL_SET_MONTAGEORT = 0x28;       // 0x28 Adresse / Montageort setzen
  static const int TEL_SET_MONTEUR = 0x29;          // 0x28 Adresse / Montageort setzen
  static const int TEL_SET_FIRMA = 0x2A;            // 0x29 Adresse / Firma setzen
  static const int TEL_SET_PROJEKTNUMMER = 0x2B;    // 0x2A Adresse / Projektnummer setzen
  static const int TEL_SET_DATUM_ZEIT = 0x2C;       // 0x2B Adresse / Datu und Zeit setzen

  static const int TEL_SET_PARAM = 0x30;     // 0x30 Parameter setzen
  static const int TEL_RESULT_SET_PARAM = 0x31;     // 0x31 Ergebnis Parameter setzen
  static const int TEL_START_STATE_PARAM = 0x32;    // 0x32 Parameter auslesen start = 0
  static const int TEL_START_FIRST_PARAM = 0x33;    // 0x33 Parameter auslesen start = 0
  static const int TEL_QUERY_PARAM = 0x34;          // 0x34 Parameter auslesen
  static const int TEL_QUERY_PARAM_NEXT = 0x35;     // 0x35 Naechsten Parameter auslesen
  static const int TEL_SET_PASSWORD = 0x36;         // 0x36 Passwort setzen  
  static const int TEL_FACTORY = 0x37;              // 0x37 Ausgangszustand setzen

  static const int TEL_QUERY_CYCLE_COUNT = 0x40; // 0x40 Takt auslesen
  static const int TEL_QUERY_SERVICE_COUNT = 0x41;  // 0x41 Wartung auslesen
  static const int TEL_SET_INPUTS = 0x42;           // 0x42 Eingang setzen
  static const int TEL_QUERY_INPUTS = 0x43;         // 0x43 Eingang abfragen
  static const int TEL_QUERY_OUTPUTS = 0x44;        // 0x44 Ausgang abfragen
  static const int TEL_QUERY_FAULT = 0x45;          // 0x45 Fehler abfragen
  static const int TEL_INPUTS_OUTPUTS = 0x46;       // 0x46 Ein- und Ausgaenge
  static const int TEL_QUERY_FAULT_INFO = 0x47;     // 0x47 Fehler Informationen und Zyklus abfragen  
  static const int TEL_QUERY_LIMIT = 0x48;          // 0x48 Zustand Endlagen
  static const int TEL_SET_INPUT = 0x49;            // 0x49 Eingang setzen
  static const int TEL_QUERY_STATE = 0x4A;          // 0x4A Einlernstatus abfragen
  static const int TEL_SET_OUTPUT = 0x4B;           // 0x4B Ausgang setzen
  static const int TEL_QUERY_ROTATION_SPEED = 0x4C; // 0x4C Geschwindigkeit lesen
  static const int TEL_SET_ROTATION_SPEED = 0x4E;   // 0x4E Geschwindigkeit kalibirieren

  static const int TEL_READPOSITION = 0x60;  // 0x60 Position des Multiturns lesen    
  static const int TEL_READTEMPERATURE = 0x61;      // 0x61 Temperatur des Multiturns lesen  
}




const Map<int, String> _TEL_DESCRIPTORS = {
  _TEL.TEL_REQUEST: "Anfrage",
  _TEL.TEL_BUSPROTOCOL: "Version Bus Protokoll",
  _TEL.TEL_VERSION: "Version",
  _TEL.TEL_NAME: "Name",
  _TEL.TEL_QUERY_LEVEL: "Level abfragen",
  _TEL.TEL_SET_LEVEL: "Level setzen",
  _TEL.TEL_PARAMETERISATION_ON: "Sprung in die Parametrisierung",
  _TEL.TEL_PARAMETERISATION_OFF: "Sprung in die Parametrisierung",
  _TEL.TEL_QUERY_BAUVORHABEN: "Adresse / BAUVORHABEN lesen",
  _TEL.TEL_SET_BAUVORHABEN: "Adresse / BAUVORHABEN setzen",
  _TEL.TEL_QUERY_MONTAGEORT: "Adresse / Montageort lesen",
  _TEL.TEL_SET_MONTAGEORT: "Adresse / Montageort setzen",
  // _TEL.TEL_QUERY_MONTEUR: "Adresse / Monteur lesen",
  // _TEL.TEL_SET_MONTEUR: "Adresse / Monteur setzen",
  _TEL.TEL_QUERY_FIRMA: "Adresse / Firma lesen",
  _TEL.TEL_SET_FIRMA: "Adresse / Firma setzen",
  _TEL.TEL_QUERY_PROJEKTNUMMER: "Adresse / Projektnummer lesen",
  _TEL.TEL_SET_PROJEKTNUMMER: "Adresse / Projektnummer setzen",
  _TEL.TEL_SET_PARAM: "Parameter setzen",
  _TEL.TEL_RESULT_SET_PARAM: "Ergebnis Parameter setzen",
  _TEL.TEL_START_STATE_PARAM: "Parameter auslesen start = 0",
  _TEL.TEL_START_FIRST_PARAM: "Parameter auslesen start = 0",
  _TEL.TEL_QUERY_PARAM: "Parameter auslesen",
  _TEL.TEL_QUERY_PARAM_NEXT: "Naechsten Parameter auslesen",
  _TEL.TEL_SET_PASSWORD: "Passwort setzen",
  _TEL.TEL_FACTORY: "Ausgangszustand setzen",
  _TEL.TEL_QUERY_CYCLE_COUNT: "Takt auslesen",
  _TEL.TEL_QUERY_SERVICE_COUNT: "Wartung auslesen",
  _TEL.TEL_SET_INPUTS: "Eingang setzen",
  _TEL.TEL_QUERY_INPUTS: "Eingang abfragen",
  _TEL.TEL_QUERY_OUTPUTS: "Ausgang abfragen",
  _TEL.TEL_QUERY_FAULT: "Fehler abfragen",
  _TEL.TEL_INPUTS_OUTPUTS: "Ein- und Ausgaenge",
  _TEL.TEL_QUERY_FAULT_INFO: "Fehler Informationen und Zyklus abfragen",
  // _TEL.TEL_QUERY_TIME: "Betriebszeit schreiben",
  _TEL.TEL_READPOSITION: "Position des Multiturns lesen",
  _TEL.TEL_READTEMPERATURE: "Temperatur des Multiturns lesen",
};

enum TEL_OUTPUT {
  DO_FA01_REL1,  // 0 
  DO_FA02_REL2,  // 1 
  DO_FA03_REL3,  // 2 
  DO_FA04_REL4,  // 3 
  DO_FA05_REL5,  // 4 
  DO_FA06_REL6,  // 5 
  DO_NOTAUS_DYN, // 6 
  DO_REL_AUF,    // 7 
  DO_REL_ZU,     // 8 
  DO_REL_SI,     // 9
  DO_TEST_HIGH,  // 10
  DO_TEST_LOW,   // 11
  DO_ATEST,      // 12
}

enum _TEL_INPUT {
  DI_AUF, // 0    
  DI_AB,  // 1
  DI_FE1, // 2
  DI_FE2, // 3
  DI_SE1, // 4
}

/// 0: Abbruch, es wird keine Endlage neu eingelernt.
/// 1: Endschalter Unten, Endschalter Oben, Vorendschalter und ggf. Bodenposition und ggf. Position Teilöffnung werden eingelernt. 
/// 2: Endschalter Oben und ggf. Position Teilöffnung werden eingelernt. 
/// 3: Endschalter Unten, Endschalter Oben werden eingelernt.
/// 4: Position Teilöffnung wird eingelernt. 
/// 5: Drehrichtung, Endschalter Unten, Endschalter Oben, Vorendschalter und ggf. Bodenposition und ggf. Position Teilöffnung werden eingelernt. 
/// 6: RWA-Position wird eingelernt.
/// 7: Position Ausblendung Lichtschranke wird eingelernt.
enum XCFEndPosition {
  abort,
  lower,
  upper,
  delete, // FIXME: False documentation
  unknown1,
  deleteUpperLower
}

/// 0: kein Zwischenhalt zugelassen, Zwischenhalt ist gleich Endlage ZU\
/// 1: halbe Behang-Öffnungsweite\
/// 2: 2\/3 Behang-Öffnungsweite\
/// 3: Zwischenhaltposition wird eingelernt / Frei wählbar",
enum XCFIntermediatePosition {
  none,
  half,
  twoThirds,
  free,
}
