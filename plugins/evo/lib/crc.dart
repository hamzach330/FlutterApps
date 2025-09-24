part of evo_protocol;


class EvoCRCResult {
  final List<int> data;
  final EvoCRC crc;

  EvoCRCResult({
    required this.data,
    required this.crc,
  });
}

/// CRC Prüfsummenbildung über ein Telegramm.
/// Die Klasse fügt zusätzlich die Länge hinzu.
/// Das generierte Telegramm kann unverändert ans Backend übergeben werden.
class EvoCRC {
  static const initValue   = 0xffff;
  static const resultValue = 0xf0b8;
  static const _bcsTab1 = [
                                      0 ,
                                 0x0810 ,
                        0x1020          ,
                        0x1020 | 0x0810 ,
              0x2040                    ,
              0x2040           | 0x0810 ,
              0x2040 | 0x1020           ,
              0x2040 | 0x1020  | 0x0810 ,
      0x4080                            ,
      0x4080                   | 0x0810 ,
      0x4080          | 0x1020          ,
      0x4080          | 0x1020 | 0x0810 ,
      0x4080 | 0x2040                   ,
      0x4080 | 0x2040          | 0x0810 ,
      0x4080 | 0x2040 | 0x1020          ,
      0x4080 | 0x2040 | 0x1020 | 0x0810
  ];

  static const _tmpTab1 = [
                                      0 ,
                                 0x0100 ,
                       0x0200           ,
                       0x0200 |  0x0100 ,
              0x0400                    ,
              0x0400          |  0x0100 ,
              0x0400 | 0x0200           ,
              0x0400 | 0x0200 |  0x0100 ,
      0x0800                            ,
      0x0800                   | 0x0100 ,
      0x0800          | 0x0200          ,
      0x0800          | 0x0200 | 0x0100 ,
      0x0800 | 0x0400                   ,
      0x0800 | 0x0400          | 0x0100 ,
      0x0800 | 0x0400 | 0x0200          ,
      0x0800 | 0x0400 | 0x0200 | 0x0100
  ];

  static const _bcsTab2 = [
                                      0 ,
                                 0x8100 ,
                        0x0200          ,
                        0x0200 | 0x8100 ,
              0x0400                    ,
              0x0400           | 0x8100 ,
              0x0400 | 0x0200           ,
              0x0400 | 0x0200  | 0x8100 ,
      0x0800                            ,
      0x0800                   | 0x8100 ,
      0x0800          | 0x0200          ,
      0x0800          | 0x0200 | 0x8100 ,
      0x0800 | 0x0400                   ,
      0x0800 | 0x0400          | 0x8100 ,
      0x0800 | 0x0400 | 0x0200          ,
      0x0800 | 0x0400 | 0x0200 | 0x8100
  ];

  static const _tmpTab2 = [
                                      0 ,
                                 0x1000 ,
                        0x2100          ,
                        0x2100 | 0x1000 ,
              0x4200                    ,
              0x4200           | 0x1000 ,
              0x4200 | 0x2100           ,
              0x4200 | 0x2100  | 0x1000 ,
      0x8400                            ,
      0x8400                   | 0x1000 ,
      0x8400          | 0x2100          ,
      0x8400          | 0x2100 | 0x1000 ,
      0x8400 | 0x4200                   ,
      0x8400 | 0x4200          | 0x1000 ,
      0x8400 | 0x4200 | 0x2100          ,
      0x8400 | 0x4200 | 0x2100 | 0x1000
  ];

  static _calculate(int data, List<int> param) {
    param[1] = (data ^ param[0]) & 0x0f;
    param[0] ^= _bcsTab1[param[1]];
    param[2]  = _tmpTab1[param[1]];

    param[1] = ( (data ^ param[0]) >> 4 ) & 0x0f;
    param[0] ^= _bcsTab2[param[1]];
    param[2] ^= _tmpTab2[param[1]];

    param[0] >>= 8;
    param[0] |= param[2];
  }

  static List<int> _escape (List<int> stream) {
    List<int> escaped = []; // Untyped array mit dynamischer Größe
    for (final byte in stream) {
      if (byte == 0x02 || byte == 0x03 || byte == 0x1b) {
        escaped.add(0x1b);
        escaped.add(byte ^ 0x80);
      } else {
        escaped.add(byte);
      }
    }
    return escaped;
  }

  static List<int> _unescape (List<int> stream) {
    List<int> unescaped = []; // Untyped array mit dynamischer Größe
    bool escape = false; // Byte in nächster Iteration unescapen
    for (final byte in stream) {
      if (byte == 0x1b) {
        escape = true;
      } else if (escape) {
        unescaped.add(byte ^ 0x80);
        escape = false;
      } else if (byte != 0x02 && byte != 0x03) {
        unescaped.add(byte);
        escape = false;
      }
    }
    return unescaped;
  }

  // Maskiert ein array entsprechend Stand D4
  static EvoCRCResult mask(List<int> data, bool escape) {
    data.insert(0, data.length); // Länge an Position 0 setzen
    final crc = _crc(data).invert(), // Invertierte Prüfsumme bilden
          lsb = crc.lo(),
          msb = crc.hi();
    
    // if ('LSB' == first) {
      data.add(lsb);
      data.add(msb);
    // } else {
      // data.add(msb);
      // data.add(lsb);
    // }

    if(escape) {
      final escaped = _escape(data);
      escaped.insert(0, 0x02);
      escaped.add(0x03);

      return EvoCRCResult(
        data: escaped,
        crc: crc
      );
    } else {
      return EvoCRCResult(
        data: data,
        crc: crc
      );
    }

  }

  // Wandelt maskierte Daten wieder zurück
  static EvoCRCResult unmask (List<int> data, bool escape) {
      List<int> unescaped;
      if(escape) {
        unescaped = _unescape(data);
      } else {
        unescaped = List<int>.from(data);
      }

      // CRC über das gesamte Datenpaket berechnen anschließend LEN, LSB und MSB entfernen
      final crc = _crc(List<int>.from(unescaped));
      unescaped.removeAt(0); // Das erste Element
      unescaped.removeAt(unescaped.length - 1); // Das letzte Element
      unescaped.removeAt(unescaped.length - 1); // Wieder das letzte Element

      return EvoCRCResult(
        data : unescaped,
        crc  : crc
      );
  }

  // Berechnet den CRC Wert eines übergebenen Uint8Arrays und gibt ein _result Objekt zurück
  static EvoCRC _crc (data) {
    final param = List.filled(3, 0);
    param[0] = initValue; // CRC mit initialem Wert
    for (final val in data) {
      _calculate(val, param);
    }
    return EvoCRC(
      res: param[0],
      data: data
    );
  }

  final int _res;
  final List<int> _data;

  EvoCRC({
    required int res,
    required List<int> data
  }):_res = res, _data = data;

  EvoCRC invert () {
    return EvoCRC(res: _res ^ 0xffff, data: _data);
  }

  result () {
    return _res;
  }

  String hex () {
    return (_res).toRadixString(16).padLeft(4, '0');
  }

  int lo () {
    return _res & 0xff;
  }

  int hi () {
    return _res >> 8;
  }

  bool valid () {
    return _res == resultValue;
  }
}
