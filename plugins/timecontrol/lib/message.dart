part of timecontrol_protocol;

class TimecontrolMessage extends MTMessageInterface {
  List<int>? packedRequest;
  List<int>? unpackedRequest;
  List<int>? packedResponse;
  List<int>? unpackedResponse;
  bool withResponse;

  final Completer<List<int>> completer = Completer<List<int>>();
  final Completer<void> slot           = Completer<void>();

  TimecontrolMessage(this.unpackedRequest, {this.withResponse = true});

  List<int> pack() {
    final List<int> telegram = [0x2F, 0x0B, 0x00, 0x00, ...(unpackedRequest ?? [])];
    telegram[2] = telegram.length & 0xFF;
    telegram[3] = telegram.length >> 8 & 0xFF;
    packedRequest = telegram;
    
    return packedRequest ?? [];
  }
  
  List<MTMessageChunk> get packInfo => throw UnimplementedError();
  
  List<int> unpack(List<int> telegram) {
    packedResponse = telegram;
    final result = [...telegram];
    unpackedResponse = result;
    if(result.length > 3) {
      result.removeRange(0, 5);
      unpackedResponse = result;
    }
    completer.complete(result);
    return result;
  }
  
  List<MTMessageChunk> get unpackInfo => throw UnimplementedError();
}
