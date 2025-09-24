part of evo_protocol;

class EvoServiceInfoRequest extends EvoMessage {
  late final int? devState;
  late final int? bleVisibility;
  late final List<int>? articleID;
  late final int? swVersion;
  late final List<int>? swBuild;
  late final int? devType;
  late final String? serial;
  late final int? devInfo;

  EvoServiceInfoRequest({super.escape = false}) {
    request = [0x00];
  }

  @override
  decode () {
    if(checkLen(15)) {
      devState      = packedResponse?[1];
      bleVisibility = packedResponse?[2];
      articleID     = packedResponse?.sublist(3, 5);
      swVersion     = packedResponse?[5];
      swBuild       = packedResponse?.sublist(6, 8);
      devType       = packedResponse?[8];
      serial        = packedResponse?.sublist(9, 14).hexString;
      devInfo       = packedResponse?[14];
    } else {
      throw Exception("EvoInfoResponse: Invalid response length");
    }
  }
}

class EvoServiceRampConfigurationRead extends EvoMessage {
  late final EvoRampConfiguration configuration;

  EvoServiceRampConfigurationRead({super.escape = false}) {
    request = [
      EvoServiceCommandCodes.reqSettingRead.value,
      EvoSettingsAddress.rampConfiguration.value
    ];
  }

  @override
  decode () {
    configuration = EvoRampConfiguration.fromConfigurationData(
      configurationData: unpackedResponse!
    );
  }
}


class EvoServiceRampConfigurationWriteRequest extends EvoMessage {
  EvoServiceRampConfigurationWriteRequest({
    super.escape = false,
    required EvoRampConfiguration configuration
  }) {
    request = [
      EvoServiceCommandCodes.reqSettingWrite.value,        // Schreibe
      EvoSettingsAddress.rampConfiguration.value,          // Geschwindigkeitsprofil
      ...configuration.serialize()
    ];
  }
}

class EvoServiceWinkRequest extends EvoMessage {
  EvoServiceWinkRequest({super.escape = false}) {
    request = [0x20, 0x01];
  }

  @override
  EvoServiceWinkRequest? decode () {
    return this;
  }
}

class EvoServiceWriteSetting extends EvoMessage {
  EvoServiceWriteSetting({
    super.escape = false,
    required bool value,
    required EvoSettingsAddress setting
  }) {
    request = [
      EvoServiceCommandCodes.reqSettingWrite.value, // Write
      setting.value, // Funktion
      value == true ? 0x01 : 0x00 // Betriebsmodus
    ];
  }
}

class EvoServiceReadSetting extends EvoMessage {
  final EvoSettingsAddress setting;

  EvoServiceReadSetting({
    super.escape = false,
    required this.setting
  }) {
    request = [
      EvoServiceCommandCodes.reqSettingRead.value,
      setting.value,
    ];
  }
}