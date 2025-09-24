part of xcf_protocol;

class XCFFault {
  int priority;
  String code;
  int index;
  int cycleCount;
  int frequency;
  int cause;

  XCFFault({
    required this.priority,
    required this.code,
    required this.index,
    required this.cycleCount,
    required this.cause,
    required this.frequency,
  });

  factory XCFFault.fromPayload(List<int> payload) {
    dev.log(payload.length.toString());

    if(payload.length < 7) return XCFFault(
      index: payload[0],
      priority: 0,
      code: '00',
      cycleCount: 0,
      cause: 0,
      frequency: 0
    );


    dev.log(ascii.decode(payload.sublist(2,5)));

    final fault = XCFFault(
      index: payload[0],
      priority: payload[1],
      code: ascii.decode(payload.sublist(2,5)),
      cycleCount: payload[5] << 24 | payload[6] << 16 | payload[7] << 8 | payload[8],
      cause: payload[9],
      frequency: payload[10] << 8 | payload[11]
    );

    if(fault.code == '766') {
      print("FAULT: $fault");
    }

    return fault;
  }
}

