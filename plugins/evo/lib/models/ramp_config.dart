part of evo_protocol;

class EvoRampConfiguration {
  String? model;
  EvoOperationMode? mode;
  int? speedSlow;
  int? speedFast;
  int? rampBottom;
  int? rampTop;
  int? standardSlowDown;
  int? standardSlowUp;
  int? standardFastDown;
  int? standardFastUp;
  int? quietSlow;
  int? quietFast;
  int? dynamicSlow;
  int? dynamicFast;

  EvoRampConfiguration({
    required this.speedSlow,
    required this.speedFast,
    required this.rampBottom,
    required this.rampTop,
    this.mode,
    this.model,
    this.standardSlowDown,
    this.standardSlowUp,
    this.standardFastDown,
    this.standardFastUp,
    this.quietSlow,
    this.quietFast,
    this.dynamicSlow,
    this.dynamicFast,
  });

  factory EvoRampConfiguration.fromConfigurationData({
    required List<int> configurationData,
  }) {
    if(configurationData.length == 7) {
      return EvoRampConfiguration(
        model: "gen.1",
        mode: EvoOperationMode.fromInt(configurationData[2]),
        speedSlow: configurationData[3],
        speedFast: configurationData[4],
        rampBottom: configurationData[5],
        rampTop: configurationData[6],
      );
    } else if(configurationData.length == 15) {
      return EvoRampConfiguration(
        model: "gen.2",
        mode: EvoOperationMode.fromInt(configurationData[2]),
        speedSlow: configurationData[3],
        speedFast: configurationData[4],
        rampBottom: configurationData[5],
        rampTop: configurationData[6],
        standardSlowDown: configurationData[7],
        standardSlowUp: configurationData[8],
        standardFastDown: configurationData[9],
        standardFastUp: configurationData[10],
        quietSlow: configurationData[11],
        quietFast: configurationData[12],
        dynamicSlow: configurationData[13],
        dynamicFast: configurationData[14],
      );
    } else {
      throw Exception("EvoRampConfiguration: Invalid configuration data length");
    }
  }

  factory EvoRampConfiguration.empty() => EvoRampConfiguration(
    speedSlow: 0,
    speedFast: 0,
    rampBottom: 0,
    rampTop: 0,
  );

  List<int> serialize() => [
    // model?.value ?? 0,
    mode?.value ?? 0,
    speedSlow ?? 0,
    speedFast ?? 0,
    rampBottom ?? 0,
    rampTop ?? 0,
    if(model == "gen.2") standardSlowDown ?? 0,
    if(model == "gen.2") standardSlowUp ?? 0,
    if(model == "gen.2") standardFastDown ?? 0,
    if(model == "gen.2") standardFastUp ?? 0,
    if(model == "gen.2") quietSlow ?? 0,
    if(model == "gen.2") quietFast ?? 0,
    if(model == "gen.2") dynamicSlow ?? 0,
    if(model == "gen.2") dynamicFast ?? 0
  ];
}
