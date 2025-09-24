enum CCElevenCommand {
  // Sysinfo
  getDeviceInfo(0x00),
  getDeviceInfoResponse(0x80),
  getTime(0x01),
  getTimeResponse(0x81),
  setTime(0x02),
  setTimeResponse(0x82),
  getTimezone(0x03),
  getTimezoneResponse(0x83),
  setTimezone(0x04),
  setTimezoneResponse(0x84),
  getPos(0x05),
  getPosResponse(0x85),
  setPos(0x06),
  setPosResponse(0x86),
  setDeviceName(0x07),
  setDeviceNameResponse(0x87),
  factoryReset(0x08),
  factoryResetResponse(0x88),
  getLedIntensity(0x09),
  getLedIntensityResponse(0x89),
  setLedIntensity(0x0A),
  setLedIntensityResponse(0x8A),
  getBleAlwaysConnectable(0x0B),
  getBleAlwaysConnectableResponse(0x8B),
  setBleAlwaysConnectable(0x0C),
  setBleAlwaysConnectableResponse(0x8C),

  // Timers
  setTimers(0x10),
  setTimersResponse(0x90),
  clearAllTimers(0x11),
  clearAllTimersResponse(0x91),
  readTimer(0x12),
  readTimerResponse(0x92),
  readActiveTimers(0x13),
  readActiveTimersResponse(0x93),
  getTimersStatus(0x14),
  getTimersStatusResponse(0x94),
  saveTimers(0x15),
  saveTimersResponse(0x95),
  setTimeAutomaticTime(0x16),
  setZeitautomatikResponse(0x96),
  getAutomaticTime(0x17),
  getZeitautomatikResponse(0x97),

  // Button configuration
  getButtonInfo(0x20),
  getButtonInfoResponse(0xA0),
  setButtonInfo(0x21),
  setButtonInfoResponse(0xA1),

  // OTA
  otaStart(0x60),
  otaStartResponse(0xE0),
  otaWrite(0x61),
  otaWriteResponse(0xE1),

  // Userdata
  readUserdata(0x70),
  readUserdataResponse(0xF0),
  writeUserdata(0x71),
  writeUserdataResponse(0xF1),
  deleteUserdata(0x72),
  lockUserdata(0x73),
  commitUserdata(0x74),
  deleteUserdataResponse(0xF2),

  // Error
  errorResponse(0xFF);

  final int command;
  const CCElevenCommand(this.command);
}

enum CCElevenErrors {
  unknownCommand,
  badLength,
  badFile,
  badSeek,
  badIndex,
  badLockState,
}

enum CCElevenButtonId {
  up,
  stop,
  down,
}

enum CCElevenTimerType {
  unused,
  fixedTime,
  astroMorning,
  astroAfternoon,
}

enum CCElevenEvoProfile {
  currentProfile,
  ignored,
  standard,
  quiet,
  automatic, // actually dynamic -> dart keyword
  alarm,
  slowest,
}

enum CPAvailableCommands {
  up(0),
  down(1),
  pos1(2),
  pos2(3),
  sunProtectionOn(4),
  sunProtectionOff(5),
  moveTo(6),
  stop(7),
  on(0),
  off(7);

  const CPAvailableCommands(this.value);
  final int value;
}
