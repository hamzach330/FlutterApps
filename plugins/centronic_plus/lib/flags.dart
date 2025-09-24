part of 'centronic_plus.dart';

class StatusFlags {
  int _b0 = 0;
  int _b1 = 0;
  List<int> get raw => [_b0, _b1];

  StatusFlags({
    bool movesUp = false,
    bool movesDown = false,
    bool inUpperEndPosition = false,
    bool inLowerEndPosition = false,
    bool setupComplete = false,
    bool locked = false,
    bool overheated = false,
    bool obstacleDetected = false,
    bool windAlert = false,
    bool sunProtectionPosition = false,
    bool rainAlert = false,
    bool sensorValueOverride = false,
    bool freezeProtectEnabled = false,
    bool flyScreenEnabled = false,
    bool memoAutoEnabled = false,
    bool sunAutoEnabled = false,
    List<int>? raw,
  }) {
    if (raw != null && raw.length >= 2) {
      _b0 = raw[0];
      _b1 = raw[1];
    }
    if (movesUp) _b0 |= (1 << 0);
    if (movesDown) _b0 |= (1 << 1);
    if (inUpperEndPosition) _b0 |= (1 << 2);
    if (inLowerEndPosition) _b0 |= (1 << 3);
    if (setupComplete) _b0 |= (1 << 4);
    if (locked) _b0 |= (1 << 5);
    if (overheated) _b0 |= (1 << 6);
    if (obstacleDetected) _b0 |= (1 << 7);

    if (windAlert) _b1 |= (1 << 0);
    if (sunProtectionPosition) _b1 |= (1 << 1);
    if (rainAlert) _b1 |= (1 << 2);
    if (sensorValueOverride) _b1 |= (1 << 3);
    if (freezeProtectEnabled) _b1 |= (1 << 4);
    if (flyScreenEnabled) _b1 |= (1 << 5);
    if (memoAutoEnabled) _b1 |= (1 << 6);
    if (sunAutoEnabled) _b1 |= (1 << 7);
  }

  bool get movesUp => (_b0 & (1 << 0)) != 0;
  bool get movesDown => (_b0 & (1 << 1)) != 0;
  bool get inUpperEndPosition => (_b0 & (1 << 2)) != 0;
  bool get inLowerEndPosition => (_b0 & (1 << 3)) != 0;
  bool get setupComplete => (_b0 & (1 << 4)) != 0;
  bool get locked => (_b0 & (1 << 5)) != 0;
  bool get overheated => (_b0 & (1 << 6)) != 0;
  bool get obstacleDetected => (_b0 & (1 << 7)) != 0;

  bool get windAlert => (_b1 & (1 << 0)) != 0;
  bool get sunProtectionPosition => (_b1 & (1 << 1)) != 0;
  bool get rainAlert => (_b1 & (1 << 2)) != 0;
  bool get sensorValueOverride => (_b1 & (1 << 3)) != 0;
  bool get freezeProtectEnabled => (_b1 & (1 << 4)) != 0;
  bool get flyScreenEnabled => (_b1 & (1 << 5)) != 0;
  bool get memoAutoEnabled => (_b1 & (1 << 6)) != 0;
  bool get sunAutoEnabled => (_b1 & (1 << 7)) != 0;

  String get hexValue => Mutators.toHexString([_b0, _b1]);

  bool get hasWarning =>
      obstacleDetected ||
      overheated ||
      locked ||
      windAlert ||
      rainAlert ||
      sensorValueOverride ||
      sunProtectionPosition;

  int get warningCount => [
        locked,
        overheated,
        obstacleDetected,
        windAlert,
        rainAlert,
        sunProtectionPosition,
        sensorValueOverride,
      ].where((x) => x).length;

  bool get hasCriticalState => windAlert || overheated || obstacleDetected;

  @override
  String toString() {
    final ret = [
      if (movesUp) "UP",
      if (movesDown) "DOWN",
      if (inUpperEndPosition) "UPPER_END",
      if (inLowerEndPosition) "LOWER_END",
      if (setupComplete) "SETUP_COMPLETE",
      if (locked) "LOCKED",
      if (overheated) "OVERHEATED",
      if (obstacleDetected) "OBSTACLE_DETECTED",
      if (windAlert) "WIND_ALERT",
      if (sunProtectionPosition) "SUN_PROTECTION_POSITION",
      if (rainAlert) "RAIN_ALERT",
      if (sensorValueOverride) "SENSOR_VALUE_OVERRIDE",
      if (freezeProtectEnabled) "FREEZE_PROTECT_ENABLED",
      if (flyScreenEnabled) "FLY_SCREEN_ENABLED",
      if (memoAutoEnabled) "MEMO_AUTO_ENABLED",
      if (sunAutoEnabled) "SUN_AUTO_ENABLED",
    ].join(' ');
    return ret.isEmpty ? "NONE" : ret;
  }
}

class ControlFlags {
  int _b0 = 0;
  int _b1 = 0;

  ControlFlags({
    bool installationKey = false,
    bool factoryKey = false,
    bool deadman = false,
    bool statusChange1 = false,
    bool bit16 = false,
    bool digital = false,
    bool analog = false,
    bool read = false,
    bool statusChange9 = false,
    bool statusChange8 = false,
    bool statusChange7 = false,
    bool statusChange6 = false,
    bool statusChange5 = false,
    bool statusChange4 = false,
    bool statusChange3 = false,
    bool statusChange2 = false,
    List<int>? raw,
  }) {
    if (raw != null && raw.length >= 2) {
      _b0 = raw[0];
      _b1 = raw[1];
    }
    if (installationKey) _b0 |= (1 << 0);
    if (factoryKey) _b0 |= (1 << 1);
    if (deadman) _b0 |= (1 << 2);
    if (statusChange1) _b0 |= (1 << 3);
    if (bit16) _b0 |= (1 << 4);
    if (digital) _b0 |= (1 << 5);
    if (analog) _b0 |= (1 << 6);
    if (read) _b0 |= (1 << 7);

    if (statusChange9) _b1 |= (1 << 0);
    if (statusChange8) _b1 |= (1 << 1);
    if (statusChange7) _b1 |= (1 << 2);
    if (statusChange6) _b1 |= (1 << 3);
    if (statusChange5) _b1 |= (1 << 4);
    if (statusChange4) _b1 |= (1 << 5);
    if (statusChange3) _b1 |= (1 << 6);
    if (statusChange2) _b1 |= (1 << 7);
  }

  bool get installationKey => (_b0 & (1 << 0)) != 0;
  bool get factoryKey => (_b0 & (1 << 1)) != 0;
  bool get deadman => (_b0 & (1 << 2)) != 0;
  bool get statusChange1 => (_b0 & (1 << 3)) != 0;
  bool get bit16 => (_b0 & (1 << 4)) != 0;
  bool get digital => (_b0 & (1 << 5)) != 0;
  bool get analog => (_b0 & (1 << 6)) != 0;
  bool get read => (_b0 & (1 << 7)) != 0;

  bool get statusChange9 => (_b1 & (1 << 0)) != 0;
  bool get statusChange8 => (_b1 & (1 << 1)) != 0;
  bool get statusChange7 => (_b1 & (1 << 2)) != 0;
  bool get statusChange6 => (_b1 & (1 << 3)) != 0;
  bool get statusChange5 => (_b1 & (1 << 4)) != 0;
  bool get statusChange4 => (_b1 & (1 << 5)) != 0;
  bool get statusChange3 => (_b1 & (1 << 6)) != 0;
  bool get statusChange2 => (_b1 & (1 << 7)) != 0;

  String get hex => Mutators.toHexString([_b0, _b1]);
  List<int> get value => [_b0, _b1];

  @override
  String toString() {
    final ret = [
      if (installationKey) "INSTALLATION_KEY",
      if (factoryKey) "FACTORY_KEY",
      if (deadman) "DEADMAN",
      if (statusChange1) "STATUS_CHANGE_1",
      if (bit16) "BIT16",
      if (digital) "DIGITAL",
      if (analog) "ANALOG",
      if (read) "READ",
      if (statusChange9) "STATUS_CHANGE_9",
      if (statusChange8) "STATUS_CHANGE_8",
      if (statusChange7) "STATUS_CHANGE_7",
      if (statusChange6) "STATUS_CHANGE_6",
      if (statusChange5) "STATUS_CHANGE_5",
      if (statusChange4) "STATUS_CHANGE_4",
      if (statusChange3) "STATUS_CHANGE_3",
      if (statusChange2) "STATUS_CHANGE_2",
    ].join(' ');
    return ret.isEmpty ? "NONE" : ret;
  }
}

class CommandFlags {
  int _b0 = 0;
  int _b1 = 0;

  CommandFlags({
    bool sec3 = false,
    bool sec6 = false,
    bool sec9 = false,
    bool doubleClick = false,
    bool memo = false,
    bool stop = false,
    bool up = false,
    bool down = false,
    bool prog = false,
    bool sun = false,
    bool timeClock = false,
    bool dawn = false,
    bool rain = false,
    bool temperature = false,
    bool upLock = false,
    bool downLock = false,
    bool handAuto = false,
    List<int>? raw,
  }) {
    if (raw != null && raw.length >= 2) {
      _b0 = raw[0];
      _b1 = raw[1];
    }
    if (sec3) _b0 |= (1 << 0);
    if (sec6) _b0 |= (1 << 1);
    if (sec9) _b0 |= 0x03;
    if (doubleClick) _b0 |= (1 << 2);
    if (memo) _b0 |= (1 << 3);
    if (stop) _b0 |= (1 << 4);
    if (up) _b0 |= (1 << 5);
    if (down) _b0 |= (1 << 6);
    if (prog) _b0 |= (1 << 7);

    if (sun) _b1 |= (1 << 0);
    if (timeClock) _b1 |= (1 << 1);
    if (dawn) _b1 |= (1 << 2);
    if (rain) _b1 |= (1 << 3);
    if (temperature) _b1 |= (1 << 4);
    if (upLock) _b1 |= (1 << 5);
    if (downLock) _b1 |= (1 << 6);
    if (handAuto) _b1 |= (1 << 7);
  }

  bool get sec3 => (_b0 & (1 << 0)) != 0;
  bool get sec6 => (_b0 & (1 << 1)) != 0;
  bool get doubleClick => (_b0 & (1 << 2)) != 0;
  bool get memo => (_b0 & (1 << 3)) != 0;
  bool get stop => (_b0 & (1 << 4)) != 0;
  bool get up => (_b0 & (1 << 5)) != 0;
  bool get down => (_b0 & (1 << 6)) != 0;
  bool get prog => (_b0 & (1 << 7)) != 0;

  bool get sun => (_b1 & (1 << 0)) != 0;
  bool get timeClock => (_b1 & (1 << 1)) != 0;
  bool get dawn => (_b1 & (1 << 2)) != 0;
  bool get rain => (_b1 & (1 << 3)) != 0;
  bool get temperature => (_b1 & (1 << 4)) != 0;
  bool get upLock => (_b1 & (1 << 5)) != 0;
  bool get downLock => (_b1 & (1 << 6)) != 0;
  bool get handAuto => (_b1 & (1 << 7)) != 0;

  String get hex => Mutators.toHexString([_b0, _b1]);
  List<int> get value => [_b0, _b1];

  @override
  String toString() {
    final ret = [
      if (sec3) "SEC3",
      if (sec6) "SEC6",
      if (doubleClick) "DOUBLE_CLICK",
      if (memo) "MEMO",
      if (stop) "STOP",
      if (up) "UP",
      if (down) "DOWN",
      if (prog) "PROG",
      if (sun) "SUN",
      if (timeClock) "TIME_CLOCK",
      if (dawn) "DAWN",
      if (rain) "RAIN",
      if (temperature) "TEMPERATURE",
      if (upLock) "UP_LOCK",
      if (downLock) "DOWN_LOCK",
      if (handAuto) "HAND_AUTO",
    ].join(' ');
    return ret.isEmpty ? "NONE" : ret;
  }
}
