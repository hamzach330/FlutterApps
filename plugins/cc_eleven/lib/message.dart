import 'package:mt_interface/message.dart';
import 'const.dart';

class CCElevenMessage extends MTMessageInterface {
  final List<int> payload;
  final CCElevenCommand command;
  late final List<int> _id;
  late List<int> response;

  set id(int id) {
    this._id = [id & 0xFF, (id >> 8) & 0xFF];
  }

  int get id => _id[0] | (_id[1] << 8);

  CCElevenMessage({
    required this.command,
    this.payload = const <int>[],
  });

  static int getIdFromBuffer(List<int> data) {
    return (data[data.length - 3] & 0xFF) |
           ((data[data.length - 2] & 0xFF) << 8);
  }

  static List<int> unescape(List<int> data) {
    List<int> result = [];
    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0x1B) {
        i++;
        result.add(data[i] & 0x7F);
      } else {
        result.add(data[i]);
      }
    }
    return result;
  }

  static List<int> escape(List<int> data) {
    List<int> result = [];
    for (final byte in data) {
      if (byte == 0x02 || byte == 0x03 || byte == 0x1B) {
        result.add(0x1B);
        result.add(byte | 0x80);
      } else {
        result.add(byte);
      }
    }
    return result;
  }

  List<int> pack() {
    final len = payload.length;

    return [
      0x02,
      ...escape([
        command.command,
        len,
        ...payload,
        ..._id,
      ]),
      0x03,
    ];
  }

  List<int> unpack(List<int> telegram) {
    if (telegram.length < 6) {
      throw ArgumentError('Telegram too short');
    }

    if (telegram.first != 0x02 || telegram.last != 0x03) {
      throw ArgumentError('Invalid STX/ETX');
    }

    final id = getIdFromBuffer(telegram);

    if(id != this.id) {
      throw ArgumentError('ID MISMATCH: $id != ${this.id}');
    }

    final cmd = telegram[1];
    final len = telegram[2];

    if (cmd == 0xFF && len == 1) {
      throw CCElevenError(code: telegram[3]);
    } else if ((cmd & 0x80) == 0x80 && len == 0) {
      // Ack
      response = [];
      return response;
    } else {
      // Frame
      final payloadEscaped = telegram.sublist(3, 3 + len);
      response = payloadEscaped;

      assert(response.length == len, 'Length MISMATCH: ${response.length} != $len');

      return response;
    }
  }
}

class CCElevenError {
  final CCElevenErrors error;

  CCElevenError({
    required int code,
  }) : error = CCElevenErrors.values[code];
}
