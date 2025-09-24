part of evo_protocol;

abstract class EvoMessage extends MTMessageInterface {
  List<int>? request;
  List<int>? packedRequest;
  List<int>? packedResponse;
  List<int>? unpackedResponse;
  final int? modbusProtocolLength;
  final completer = Completer<EvoMessage>();
  final Completer<void> slot = Completer<void>();

  bool escape = false;

  EvoMessage({
    this.packedRequest,
    this.request,
    this.packedResponse,
    this.unpackedResponse,
    this.modbusProtocolLength,
    required this.escape
  });

  void ensureProtoLen() {
    if(request == null) {
      throw Exception("unpackedRequest is null");
    }
    if (modbusProtocolLength == null) return;
    if (request!.length > modbusProtocolLength! + 2) {
      throw Exception("Array length exceeds protoLen");
    }
    while (request!.length < modbusProtocolLength! + 2) {
      request!.add(0x00);
    }
  }

  List<int> pack() {
    ensureProtoLen();
    final maskedRequest = EvoCRC.mask(request ?? [], escape);
    packedRequest = maskedRequest.data;
    return packedRequest ?? [];
  }

  List<int> unpack(List<int> telegram) {
    packedResponse = telegram;
    final crcResult = EvoCRC.unmask(packedResponse ?? [], escape);
    dev.log("CRC CHECK RESULT: ${crcResult.crc.valid()}");
    unpackedResponse = crcResult.data;
    decode();
    return unpackedResponse ?? [];
  }

  void decode () {}

  List<int> getRequest () => packedRequest ?? [];

  bool checkLen(int len) {
    if((unpackedResponse?.length ?? 0) > len) {
      dev.log("Invalid response length: ${unpackedResponse?.length} != $len");
      return false;
    }
    return true;
  }
}
