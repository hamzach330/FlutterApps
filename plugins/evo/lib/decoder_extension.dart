part of evo_protocol;

extension EvoDecoder on int {
  List<int> get asInt16MSB => [
    (this >> 8) & 0xFF,  // MSB first
    (this & 0xFF)
  ];

  List<int> get asInt16LSB => [
    (this & 0xFF),       // LSB first
    (this >> 8) & 0xFF
  ];

  List<int> get asInt24MSB => [
    (this >> 16) & 0xFF,  // MSB first
    (this >> 8) & 0xFF,
    (this & 0xFF)
  ];

  List<int> get asInt24LSB => [
    (this & 0xFF),        // LSB first
    (this >> 8) & 0xFF,
    (this >> 16) & 0xFF
  ];

  List<int> get asInt32MSB => [
    (this >> 24) & 0xFF,  // MSB first
    (this >> 16) & 0xFF,
    (this >> 8) & 0xFF,
    (this & 0xFF)
  ];

  List<int> get asInt32LSB => [
    (this & 0xFF),        // LSB first
    (this >> 8) & 0xFF,
    (this >> 16) & 0xFF,
    (this >> 24) & 0xFF
  ];

  bool bitGet(int n) => (this & (1 << n)) != 0;

  int bitSet(int bit) => this | (1 << bit);

  int bitClear(int bit) => this & ~(1 << bit);

  int bitToggle(int bit) => this ^ (1 << bit);

  String get bitView => this.toRadixString(2).padLeft(32, '0');
}

extension EvoListDecoder on List<int> {
  int get intView => this.fold(0, (prev, value) => (prev << 8) | value);

  int get asUInt16MSB => (this[0] << 8) | this[1]; // MSB first

  int get asUInt16LSB => (this[1] << 8) | this[0]; // LSB first

  int get asUInt24MSB => (this[0] << 16) | (this[1] << 8) | this[2]; // MSB first

  int get asUInt24LSB => (this[2] << 16) | (this[1] << 8) | this[0]; // LSB first
  
  int get asUInt32MSB => (this[0] << 24) | (this[1] << 16) | (this[2] << 8) | this[3]; // MSB first

  int get asUInt32LSB => (this[3] << 24) | (this[2] << 16) | (this[1] << 8) | this[0]; // LSB first

  String get hexString => this.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');

  String get asciiString => String.fromCharCodes(this);
}

extension EvoStringEncoder on String {
  List<int> get asAscii => utf8.encode(this);

  List<int> get hex => this.split(' ').map((e) => int.parse(e, radix: 16)).toList();
}