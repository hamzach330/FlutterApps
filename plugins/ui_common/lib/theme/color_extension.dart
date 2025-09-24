part of ui_common;

extension DarkenBrighten on Color {
  // Color darken (double amount) {
  //   return Color.fromARGB(alpha,
  //     max(0, red - (red * amount).toInt()),
  //     max(0, green - (green * amount).toInt()),
  //     max(0, blue - (blue * amount).toInt()),
  //   );
  // }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color brighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
