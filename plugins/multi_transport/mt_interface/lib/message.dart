abstract class MTMessageInterface {

}

class MTMessageInfoInterface {

  final String? name;
  final String telegram;
  final String tag;
  final DateTime time;
  final List<MTMessageChunk>? chunks;
  int byteCounter = 0;

  MTMessageInfoInterface({
    required this.telegram,
    required this.time,
    required this.tag,
    this.chunks,
    this.name
  });
}

class MTMessageChunk {
  int?    start;
  int?    end;
  final int?    length;
  final String  name;
  final dynamic value;

  MTMessageChunk({
    required this.name,
    required this.value,
    this.start,
    this.end,
    this.length,
  });
}