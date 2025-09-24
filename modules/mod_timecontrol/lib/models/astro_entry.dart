part of '../module.dart';

class AstroTableEntry {
  final DateTime sunrise;
  final DateTime sunset;
  final bool daylightSaving;
  final int thread;
  final Offset curveSunrise;
  final Offset curveSunset;
  int? offsetSunrise;
  int? offsetSunset;

  AstroTableEntry({
    required this.sunrise,
    required this.sunset,
    required this.daylightSaving,
    required this.curveSunrise,
    required this.curveSunset,
    this.offsetSunrise,
    this.offsetSunset,
    this.thread = -1,
  });
}