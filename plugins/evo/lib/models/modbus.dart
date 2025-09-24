part of evo_protocol;

class EvoModbusWriteMoveCommand extends EvoMessage {
  EvoModbusWriteMoveCommand({
    super.escape = false,
    required EvoModbusMoveCommandCodes command
  }) {
    request = [
        EvoServiceCommandCodes.reqModbusOverBle.value,
        EvoModbusAddressCodes.moveCommand.value | kEvoModbusWriteFlag,
        command.value, // Fahrbefehl auf
        0x00,
        0x00,
        0x00,
        0x00,
    ];
  }
}

class EvoModbusUpStep extends EvoMessage {
  EvoModbusUpStep({
    super.escape = false,
    required EvoModbusMoveCommandCodes command
  }) {
    request = [
        EvoServiceCommandCodes.reqModbusOverBle.value,
        EvoModbusAddressCodes.upStep.value,
        0x01, // Anything but zero
        0x00,
        0x00,
        0x00,
        0x00,
    ];
  }
}

class EvoModbusDownStep extends EvoMessage {
  EvoModbusDownStep({
    super.escape = false,
    required EvoModbusMoveCommandCodes command
  }) {
    request = [
        EvoServiceCommandCodes.reqModbusOverBle.value,
        EvoModbusAddressCodes.downStep.value,
        0x01, // Anything but zero
        0x00,
        0x00,
        0x00,
        0x00,
    ];
  }
}

class EvoModbusSetupFunction extends EvoMessage {
  EvoModbusSetupFunction({
    super.escape = false,
    required EvoModbusSetupFunctionCodes option
  }) {
    request = [
      EvoServiceCommandCodes.reqModbusOverBle.value,
      EvoModbusAddressCodes.progSetupParameters.value | kEvoModbusWriteFlag,
      option.value,
      0x00,
      0x00,
      0x00,
    ];
  }
}

class EvoModbusReadEndPositionStatus extends EvoMessage {
  late final int point;
  late final EvoModbusReadEndPositionType type;

  EvoModbusReadEndPositionStatus({
    required super.escape,
    required EvoModbusReadEndPositionStatusX endPosition
  }) {
    request = [
      EvoServiceCommandCodes.reqModbusOverBle.value,
      EvoModbusAddressCodes.readStatusEndPositionX.value,
      endPosition.value,
      0x00,
      0x00,
      0x00,
    ];
  }

  @override
  void decode() {
    if(checkLen(6)) {
      final typeVal = unpackedResponse![5];
      point = unpackedResponse!.sublist(2, 5).asUInt24LSB;
      type = typeVal.bitGet(1)
          ? EvoModbusReadEndPositionType.endPositionPoint
          : typeVal.bitGet(2)
          ? EvoModbusReadEndPositionType.endPositionStop
          : typeVal.bitGet(3)
          ? EvoModbusReadEndPositionType.endPositionSwing
          : EvoModbusReadEndPositionType.none;
    } else {
      throw Exception("EvoReadEndPosition: Invalid response length");
    }
  }
}


class EvoModbusReadPositionX extends EvoMessage {
  late final int point;
  /// Will be set if the command is [EvoModbusGetPositionXCommandCodes.currentPosition] AND the drive is currently in intermediate position 1, 2 or 3
  late final EvoModbusGetPositionXCommandCodes? name;
  final EvoModbusGetPositionXCommandCodes _reqCommand;

  EvoModbusReadPositionX({
    required super.escape,
    required EvoModbusGetPositionXCommandCodes command
  }): _reqCommand = command {
    request = [
      EvoServiceCommandCodes.reqModbusOverBle.value,
      EvoModbusAddressCodes.readPositionX.value,
      command.value,
      0x00,
      0x00,
      0x00,
    ];
  }

  @override
  void decode() {
    if(checkLen(6)) {
      point = unpackedResponse!.sublist(2, 5).asUInt24LSB;
    } else {
      throw Exception("EvoReadEndPosition: Invalid response length");
    }
    if(_reqCommand == EvoModbusGetPositionXCommandCodes.currentPosition) {
      int posName = unpackedResponse![5];
      if(posName == 0xFF) {
        name = EvoModbusGetPositionXCommandCodes.currentPosition;
      } else if(posName == 0x00) {
        name = EvoModbusGetPositionXCommandCodes.position1;
      } else if(posName == 0x01) {
        name = EvoModbusGetPositionXCommandCodes.position2;
      } else if(posName == 0x02) {
        name = EvoModbusGetPositionXCommandCodes.position3;
      }
    }
  }
}

class EvoModbusSetPositionX extends EvoMessage {
  late final int point;

  EvoModbusSetPositionX({
    super.escape = false,
    required EvoModbusSetPositionXAdressCodes address,
    position = EvoModbusSetPositionXPosition.position1,
    required int point
  }) {
    request = [
      EvoServiceCommandCodes.reqModbusOverBle.value,
      address.value | kEvoModbusWriteFlag,
      ...point.asInt24LSB,
      position.value, /// 
    ];
  }
}
