part of ui_common;

get _seedDefault => Color.fromARGB(255, 34, 84, 138);
get _seedSuccess => Color.fromARGB(255, 175,202,11);
get _seedWarn    => Color.fromARGB(255, 255, 149, 0);
get _seedError   => Color.fromARGB(255, 239,51,64);

get _lightScheme => ColorScheme.fromSeed(
  dynamicSchemeVariant: DynamicSchemeVariant.content,
  seedColor: _seedDefault
);

get _darkScheme => ColorScheme.fromSeed(
  dynamicSchemeVariant: DynamicSchemeVariant.content,
  brightness: Brightness.dark,
  seedColor: _seedDefault
);

extension ColorSchemeExtension on ColorScheme {
  ColorScheme get successVariant => brightness == Brightness.light
    ? ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      seedColor: _seedSuccess,
      // onPrimaryContainer: _seedSuccess.brighten(.6)
    )
    : ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      contrastLevel: .3,
      brightness: Brightness.dark,
      seedColor: _seedSuccess,
      // onPrimaryContainer: _seedSuccess.brighten(.6)
    );

  ColorScheme get warnVariant => brightness == Brightness.light
    ? ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      seedColor: _seedWarn,
      // onPrimaryContainer: _seedWarn.brighten(.45)
    )
    : ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      brightness: Brightness.dark,
      seedColor: _seedWarn,
      // onPrimaryContainer: _seedWarn.brighten(.45)
    );

  ColorScheme get errorVariant => brightness == Brightness.light
    ? ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      seedColor: _seedError,
      // onPrimaryContainer: _seedError.brighten(.4)
    )
    : ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.content,
      brightness: Brightness.dark,
      seedColor: _seedError,
      // onPrimaryContainer: _seedError.brighten(.4)
    );
}