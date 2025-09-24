part of timecontrol_protocol;

enum TCPresets {
  shutterLiving, shutterSleeping, shutterAstro, awningShade, awningPermanent
}

enum TCOperationModeType {
  Shutter, Awning, Venetian
}

enum TCLearn {
  none(0x00),
  start(0x01),
  confirmLower(0x02),
  confirmRotary(0x03),
  confirmUpper(0x04),
  abort(0x05),
  responseTime(0x06); /// Whether the device is a fast moving device

  const TCLearn(this.value);
  final int value;

  static TCLearn getByValue(int i){
    return TCLearn.values.firstWhere((x) => x.value == i);
  }
}

enum TCPresetOption {
  startTeachin(1), stopTeachin(2), deletePosition(3);

  const TCPresetOption(this.value);
  final int value;

  static TCClockAction getByValue(int i){
    return TCClockAction.values.firstWhere((x) => x.value == i);
  }
}

class TCOperationModeParam {
  final List<int> _raw;

  bool get automatic => _raw[0] & 0x01 > 0;
  set automatic (bool val) {
    _raw[0] = val
      ? _raw[0] | 0x01
      : _raw[0] & ~0x01;
  }

  bool get random => _raw[0] & 0x02 > 0;
  set random (bool val) {
    _raw[0] = val
      ? _raw[0] | (0x01 << 1)
      : _raw[0] & ~(0x01 << 1);
  }

  bool get direction => _raw[0] & 0x04 > 0;
  set direction (bool val) {
    _raw[0] = val
      ? _raw[0] | (0x01 << 2)
      : _raw[0] & ~(0x01 << 2);
  }

  /// Sensorloss pre 1.30
  /// Show sun / wind in display from 2.0.0
  bool get showSunWindInDisplay => _raw[0] & 0x08 > 0;
  set showSunWindInDisplay (bool val) {
    _raw[0] = val
      ? _raw[0] | (0x01 << 3)
      : _raw[0] & ~(0x01 << 3);
  }

  bool get memo => _raw[0] & 0x10 > 0;
  set memo (bool val) {
    _raw[0] = val
      ? _raw[0] | (0x01 << 4)
      : _raw[0] & ~(0x01 << 4);
  }

  bool get setupComplete => _raw[0] & 0x20 > 0;
  set setupComplete (bool val) {
    _raw[0] = val
      ? _raw[0] | (0x01 << 5)
      : _raw[0] & ~(0x01 << 5);
  }

  bool get amTimeDisplay => _raw[0] & 0x40 > 0;
  set amTimeDisplay (bool val) {
    _raw[0] = val
      ? _raw[0] | (0x01 << 6)
      : _raw[0] & ~(0x01 << 6);
  }

  bool get automaticTime => _raw[0] & 0x80 > 0;
  set automaticTime (bool val) {
    _raw[0] = val
      ? _raw[0] | (0x01 << 7)
      : _raw[0] & ~(0x01 << 7);
  }

  bool get winter => _raw[1] & 0x01> 0;
  set winter (bool val) {
    _raw[1] = val
      ? _raw[1] | 0x01
      : _raw[1] & ~0x01;
  }

  /// Enable internal light sensor
  /// exclusive either internal or external can be active
  bool get lightSensorInternal => _raw[1] & 0x02 > 0;
  set lightSensorInternal (bool val) {
    _raw[1] = _raw[1] & ~(0x01 << 2);
    _raw[1] = val
      ? _raw[1] | (0x01 << 1)
      : _raw[1] & ~(0x01 << 1);
  }

  /// Enable external light sensor
  /// exclusive either internal or external can be active
  bool get lightSensorExternal => _raw[1] & 0x04 > 0;
  set lightSensorExternal (bool val) {
    _raw[1] = _raw[1] & ~(0x01 << 1);
    _raw[1] = val
      ? _raw[1] | (0x01 << 2)
      : _raw[1] & ~(0x01 << 2);
  }

  bool get windSensor => _raw[1] & 0x08 > 0;
  set windSensor (bool val) {
    _raw[1] = val
      ? _raw[1] | (0x01 << 3)
      : _raw[1] & ~(0x01 << 3);
  }

  bool get dawnMode => _raw[1] & 0x10 > 0;
  set dawnMode (bool val) {
    _raw[1] = val
      ? _raw[1] | (0x01 << 4)
      : _raw[1] & ~(0x01 << 4);
  }

  bool get automaticSensor => _raw[1] & 0x20 > 0;
  set automaticSensor (bool val) {
    _raw[1] = val
      ? _raw[1] | (0x01 << 5)
      : _raw[1] & ~(0x01 << 5);
  }

  bool get temperatureActive => _raw[1] & 0x40 > 0;
  set temperatureActive (bool val) {
    _raw[1] = val
      ? _raw[1] | (0x01 << 6)
      : _raw[1] & ~(0x01 << 6);
  }

  bool get windDetected => _raw[1] & 0x80 > 0;
  set windDetected (bool val) {
    _raw[1] = val
      ? _raw[1] | (0x01 << 7)
      : _raw[1] & ~(0x01 << 7);
  }

  /// sensorLoss has compat toggle for clock versions lower 1.29!
  /// In that case _raw is 3 bytes long, where sensorLoss moved to bit 1
  /// Otherwise it's in the 3rd byte at bit 0
  bool get sensorLoss => !hasAlertStates ? _raw[0] & 0x08 > 0 : _raw[2] & 0x01 > 0;
  bool get windalert => !hasAlertStates ? false : _raw[2] & 0x02 > 0;
  bool get temperatureAlert => !hasAlertStates ? false : _raw[2] & 0x04 > 0;
  bool get rainAlert => !hasAlertStates ? false : _raw[2] & 0x08 > 0;

  update(List<int> raw) {
    if(raw.length < 2) throw Exception("OperationModeParam requires at least 2 bytes data (3 byte for TC72 ^1.30)!");
    _raw..clear()..addAll(raw);
  }

  bool initialized = false;
  bool get hasAlertStates => _raw.length > 2;

  TCOperationModeParam([List<int> raw = const [0x00, 0x00]])
    : _raw = [...raw];
}

class TCAstroOffsetParam {
  late final List<int> _raw;

  DateTime get startTimeUp {
    final minutes = Int16List.sublistView(Uint8List.fromList([_raw[0], _raw[1]]));
    return DateTime.utc(DateTime.now().year, 01, 01).add(Duration(minutes: minutes.first));
  }
  
  set startTimeUp (DateTime val) {
    final minutes = val.hour * 60 + val.minute;
    final data = Uint8List.sublistView(
      Int16List.fromList([ minutes ]));
    _raw[0] = data[0];
    _raw[1] = data[1];
  }

  DateTime get startTimeDown {
    final minutes = Int16List.sublistView(Uint8List.fromList([_raw[2], _raw[3]]));
    return DateTime.utc(DateTime.now().year, 01, 01).add(Duration(minutes: minutes.first));
  }

  set startTimeDown (DateTime val) {
    final minutes = val.hour * 60 + val.minute;
    final data = Uint8List.sublistView(
      Int16List.fromList([ minutes ]));
    _raw[2] = data[0];
    _raw[3] = data[1];
  }

  TCAstroOffsetParam([List<int>? raw]) {
    _raw = List.filled(4, 0x00);
    if(raw != null) {
      for(int i = 0; i < min(4, raw.length); i++) {
        _raw[i] = raw[i];
      }
    }
  }
}

enum TCClockAction {
  none(0x00),
  move(0x01),
  pos2(0x04),
  pos1(0x08),
  automaticOn(0x20),
  automaticOff(0x10);
  
  const TCClockAction(this.value);
  final int value;

  static TCClockAction getByValue(int i){
    return TCClockAction.values.firstWhere((x) => x.value == i);
  }
}

const TCMaxClocksPerDay = 10;

enum TCClockChannel {
  ch0(0x01),
  ch1(0x02),
  ch2(0x04),
  ch3(0x08),
  ch4(0x10),
  ch5(0x20),
  ch6(0x40),
  ch7(0x80),
  ch8(0x100),
  ch9(0x200),
  ch10(0x400),
  ch11(0x800),
  ch12(0x1000),
  ch13(0x2000),
  ch14(0x4000),
  ch15(0x8000),
  wireless(0x10000),
  wired(0x20000),
  all(0x40000),
  clearAll(32);

  const TCClockChannel(this.value);
  final int value;

  List<int> toBytes() {
    final bytes = Uint8List(3);
    bytes[0] = value       & 0xFF;
    bytes[0] = value >> 8  & 0xFF;
    bytes[0] = value >> 16 & 0xFF;
    return bytes;
  }
}

enum TCClockTimeProgram {
  mon(0),
  tue(1),
  wed(2),
  thu(3),
  fri(4),
  sat(5),
  sun(6),
  week(7),
  blockWeek(8),
  blockWeekend(9);

  const TCClockTimeProgram(this.value);
  final int value;
}

class TCClockParam {
  List<bool> clockType = [true, false, false]; /// Time, Astro morning, Astro evening
  
  bool get blockTimeActive => (isAstroControlled) && (!isMidnight);

  TCClockChannel channel = TCClockChannel.wired;
  
  int astroOffset = 0;
  late final List<int> _raw;

  int get minute => _raw[0];
  set minute(int val) => _raw[0] = val;

  int get hour => _raw[1];
  set hour(int val) => _raw[1] = val;

  bool get isMidnight => hour == 0 && minute == 0;

  bool get active => _raw[3] > 0;

  DateTime get time => DateTime(0, 0, 0, hour, minute);

  int moveTo = 0;
  int moveSlatTo = 0;

  TCClockAction get action => TCClockAction.values.firstWhere((action) => action.index == _raw[2]);
  set action(TCClockAction action) => _raw[2] = action.index;

  List<bool> get days => [
    for(int i = 0; i < 7; i++)
      (_raw[3] & (1 << i)) > 0
  ];

  set days (List<bool> val) {
    _raw[3] = 0;
    for(int i = 0; i < 7; i++) {
      if(val[i]) _raw[3] |= 1 << i;
    }
  }

  TCClockParam([List<int>? raw]) {
    _raw = raw ?? List.filled(5, 0x00);
    action = TCClockAction.move;
    moveTo = 0;
  }

  factory TCClockParam.fromParameters({
    TCClockChannel channel = TCClockChannel.wired,
    required List<bool> days,
    required DateTime time,
    required TCClockAction action
  }) {
    final clock = TCClockParam()
      ..hour = time.hour
      ..minute = time.minute
      ..action = action
      ..channel = channel
      ..days = days;
    
    return clock;
  }

  factory TCClockParam.fromResponse({
    required List<int> result,
    required TCClockChannel channel,
    required int day
  }) {

    // result = [0x00, 0x14, 0x44, 0xA0];

    final minute     = result[2];
    final hour       = result[3];
    TCClockAction action = TCClockAction.none;
    try {
      action = TCClockAction.getByValue(result[4] & 0x3F);
    } catch(e) {
      dev.log("Error parsing action: ${result[4] & 0x3F}");
    }

    int switchType = 0;
    try {
      switchType = (result[4] & 0xC0) >> 6;
    } catch(e) {
      dev.log("Error parsing switchType: ${(result[4] & 0xC0) >> 6}");
    }
    if(switchType > 2) switchType = 0;
    
    final clockType  = [false, false, false]
      ..[switchType] = true;

    final days       = [false, false, false, false, false, false, false]
      ..[day]        = true;

    return TCClockParam()
      ..hour        = hour
      ..minute      = minute
      ..action      = action
      ..clockType   = clockType
      ..astroOffset = Int8List.fromList([result[5]]).first
      ..moveTo      = result[6]
      ..moveSlatTo  = result[7]
      ..channel     = channel
      ..days        = days; // FIXME:
      // ..astroOffsetController.text = Int8List.fromList([result[6]]).first.toString();
  }

  bool get isAstroControlled => clockType[1] || clockType[2];
  bool get isAstroEvening => clockType[1] == true;
  bool get isAstroMorning => clockType[2] == true;

  bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;
  int setBit(int value, int bit)    => value | (1 << bit);
  int unsetBit(int value, int bit)  => value & ~(1 << bit);

  bool overlaps = false;

  /// This will check whether there is any other clock which has the same time on any day.
  /// The check includes astro offset and astro type.
  /// This is required because the clock cannot execute two actions at the same time.
  void isUniqueTimeSpec(List<TCClockParam> others) {
    bool _overlaps = false;
    for(final other in others) {
      if(other == this) continue;
      bool overlapsDays = false;
      for (int i = 0; i < 7; i++) {
        if (days[i] && other.days[i]) {
          overlapsDays = true;
        }
      }

      if(overlapsDays) {
        if (isAstroControlled && other.isAstroControlled
          && isAstroEvening == other.isAstroEvening
          && isAstroMorning == other.isAstroMorning
          && astroOffset == other.astroOffset) {
            _overlaps = true;
            overlaps = _overlaps;
            return;
        } else if(isAstroControlled == false && hour == other.hour && minute == other.minute) {
          _overlaps = true;
          overlaps = _overlaps;
          return;
        }
      }
    }

    overlaps = false;
  }
}

class TCSunThresholdParam {
  late final List<int> _raw;

  int get thresOut => _raw[0];
  set thresOut(int val) => _raw[0] = val;

  int get thresIn => _raw[1];
  set thresIn(int val) => _raw[1] = val;

  int get delayIn => (_raw[3] << 8) | _raw[2];
  set delayIn(int val) {
    _raw[2] = val & 0xFF;
    _raw[3] = (val >> 8) & 0xFF;
  }

  int get delayOut => _raw.length < 5 ? 0 : (_raw[5] << 8) | _raw[4];
  set delayOut(int val) {
    _raw[4] = val & 0xFF;
    _raw[5] = (val >> 8) & 0xFF;
  }

  TCSunThresholdParam([List<int>? raw]) {
    _raw = raw ?? List.filled(6, 0x00);
  }
}

