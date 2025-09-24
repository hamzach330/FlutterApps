library evo_protocol;

import 'dart:math' show min, max;
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:mt_interface/protocol.dart';
import 'package:mt_interface/queue.dart';
import 'package:mt_interface/message.dart';
import 'package:mt_interface/endpoint.dart';

part 'package:evo_protocol/models/message.dart';
part 'package:evo_protocol/models/ramp_config.dart';
part 'package:evo_protocol/models/service.dart';
part 'package:evo_protocol/models/modbus.dart';
part 'package:evo_protocol/queue.dart';
part 'package:evo_protocol/crc.dart';
part 'package:evo_protocol/api.dart';
part 'package:evo_protocol/const.dart';
part 'package:evo_protocol/tunnel_endpoint.dart';
part 'package:evo_protocol/decoder_extension.dart';

class Evo<Message_T extends EvoMessage> extends MTReaderWriter<Message_T, List<int>, Evo> {
  Evo({
    this.escape = false /// escaping is required for ble connections
  });
  final _queue = EvoQueue();
  final _buffer = [];
  bool escape;

  EvoRampConfiguration rampConfiguration = EvoRampConfiguration.empty();
  bool freezeProtectEnabled = false;
  bool flyScreenEnabled = false;

  @override
  void read(data) {
    if(escape) {
      _buffer.addAll(data);
      if(data.contains(0x03)) {
        final telegram = List<int>.from(_buffer.sublist(_buffer.indexOf(0x02), _buffer.indexOf(0x03) + 1));
        _queue.unpack(telegram);
        _buffer.clear();
      }
    } else {
      _queue.unpack(data);
    }
  }

  @override
  Future<void> writeMessage(Message_T message) async {
    // throw UnimplementedError();
  }

  Future<T> writeMessageWithResponse<T extends Message_T>(T message) async {
    _queue.add(message);
    await message.slot.future;

    await endpoint.write(message.packedRequest ?? []);
    
    dev.log(">>> ${message.packedRequest?.map((e) => e.toRadixString(16).toUpperCase().padLeft(2, '0'))}");
    
    try {
      await message.completer.future.timeout(Duration(
        seconds: 7
      ));
    } catch(e) {
      _queue.wipe();
      rethrow;
      // if(!message.slot.isCompleted) {
      //   message.slot.complete();
      // }
      // rethrow;
    }

    return message;
  }
  
  @override
  void notifyListeners() => updateStream.add(this);
}
