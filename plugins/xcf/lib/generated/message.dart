part of xcf_protocol;

class XCFMessage extends MTMessageInterface {
  static const protoArr = [48, 49]; // 01 in ascii encoded hex (0x01)
  static const telegramType = 0x01;

  List<int>? packedRequest;
  List<int>? unpackedRequest;
  List<int>? packedResponse;
  List<int>? unpackedResponse;

  int? reqCommand;
  List<int>? reqPayload;

  int? rspProtocol;
  int? rspCommand;
  int? rspChecksum;
  int? rspLength;
  bool? rspChecksumValid;
  List<int>? rspPayload;

  bool withResponse;

  final Completer<List<int>> completer = Completer<List<int>>();
  final Completer<void> slot           = Completer<void>();

  XCFMessage({
    this.reqCommand,
    this.reqPayload,
    this.withResponse = true
  });

  @override
  List<int> pack() {
    final len = (reqPayload?.length ?? 0);
    unpackedRequest = [telegramType, reqCommand ?? 0, len, ...reqPayload ?? []];
    final int checksum = (unpackedRequest ?? []).fold(0, (previous, current) => previous + current);
    unpackedRequest?.add(checksum & 0xFF);

    final data = ascii.encode(HEX.encode((unpackedRequest) ?? []));
    final List<int> telegram = [0x02, ...data, 0x03]; // 48, 49 = 01 in ascii encoded hex
    packedRequest = telegram;
    return telegram;
  }
  
  @override
  List<MTMessageChunk> get packInfo => throw UnimplementedError();
  
  @override
  List<int> unpack(List<int> telegram) {
    final data = HEX.decode(ascii.decode(telegram));
    packedResponse = telegram;
    unpackedResponse = data;
    
    rspProtocol = data[0];
    rspCommand = data[1];
    rspLength = data[2];
    rspPayload = data.sublist(3, data.length - 1);
    rspChecksum = data[data.length - 1];

    final int calculatedChecksum = (rspProtocol ?? 0) +
      (rspCommand ?? 0) +
      (rspLength ?? 0) +
      (rspPayload ?? []).fold(0, (previous, current) => previous + current);

    rspChecksumValid = (calculatedChecksum & 0xFF) == rspChecksum;

    completer.complete(packedResponse ?? []);
    slot.complete();
    return packedResponse ?? [];
  }
  
  @override
  List<MTMessageChunk> get unpackInfo => throw UnimplementedError();
}
