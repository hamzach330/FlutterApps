part of '../module.dart';

class TCAstroCalculator {
  static const double _minToMilli             = 60 * 1000;
  static const double _hourToMin              = 60;
  static const _maxDays                       = 47 * 8; /// TC72 specific - Astro curve consists of 47 segments, 8 days each
  static const _granularity                   = 8;      /// Size of 1 segment [_maxDays]
  static final DateTime now                   = DateTime.now();
  static final DateTime yearFirstDay     = DateTime(now.year, 1, 1, 0, 0);
  static final DateTime yearFirstDayUTC  = DateTime.utc(now.year, 1, 1, 0, 0);
  static final firstOfNextYearUTC        = DateTime.utc(now.year + 1, 1, 1, 0, 0);
  static final timezoneOffset            = Duration(hours: yearFirstDay.timeZoneOffset.inHours);
  static final yearDuration              = firstOfNextYearUTC.difference(yearFirstDayUTC);

  Future<(List<int>, List<int>, TCAstroOffsetParam)> updateTable (Position geoLocation, bool enableSummerTime) async {
    final astroData = await getAstroTableFromPosition(geoLocation, enableSummerTime);
    final sunriseWrite = astroData.where((e) => e.offsetSunrise != null).map((e) => e.offsetSunrise ?? 0).toList();
    final sunsetWrite  = astroData.where((e) => e.offsetSunset != null).map((e) => e.offsetSunset ?? 0).toList();
    final astroOffset  = TCAstroOffsetParam()
      ..startTimeUp    = astroData.first.sunrise
      ..startTimeDown  = astroData.first.sunset;

    return (sunriseWrite, sunsetWrite, astroOffset);
  }

  static List<AstroTableEntry> _calculateAstroTable ((int, double, double, bool) params) {
    final results = <AstroTableEntry>[],
          id = params.$1,
          lat = params.$2,
          lon = params.$3,
          enableSummerTime = params.$4;

    for(int day = id * 100; day < id * 100 + 100; day++) {
      if(day > _maxDays) break;
      if(day % _granularity == 0) {
        final dayDate = yearFirstDayUTC.add(Duration(days: day));
        final isSummerTime = yearFirstDay.add(Duration(days: day)).hour != 0;

        // Melbourne
        // Lat: -37.837988
        // Lon: 145.006527
        // Trondheim
        // Lat: 63.432856
        // Lon: 10.400867
        // final result = getSunriseSunset(67.85572, 20.22513, timezoneOffset, yearFirstDayUTC.add(Duration(days: day)));
        // final result = getSunriseSunset(lat, lon, timezoneOffset, yearFirstDayUTC.add(Duration(days: day)));
        
        /// Hammerfest
        // final result = calculateCivilDawn(yearFirstDayUTC.add(Duration(days: day)), 70.66336, 23.68209, 0);
        
        /// Trondheim
        // final result = calculateSunriseSunset(yearFirstDayUTC.add(Duration(days: day)), 63.432856, 10.400867, 0);
        
        /// User Location
        final result = calculateSunriseSunset(yearFirstDayUTC.add(Duration(days: day)), lat, lon, 0);

        final sunriseCurvePoint = Offset(
          day / yearDuration.inDays,
          1 - result.$1.add(timezoneOffset).difference(dayDate).inMinutes / (24 * _hourToMin)
        );

        final sunsetCurvePoint = Offset(
          day / yearDuration.inDays,
          1 - result.$2.add(timezoneOffset).difference(dayDate).inMinutes / (24 * _hourToMin)
        );

        results.add(AstroTableEntry(
          thread: id,
          daylightSaving: !enableSummerTime ? false : isSummerTime,
          sunrise: result.$1.add(timezoneOffset),
          sunset: result.$2.add(timezoneOffset),
          curveSunrise: sunriseCurvePoint,
          curveSunset: sunsetCurvePoint,
        ));
      }
    }
    return results;
  }

  static List<AstroTableEntry> _calculateAstroTableOffsets (List<List<AstroTableEntry>> astroData) {
    final astroTable       = astroData.expand((e) => e).toList(),
          astroBaseSunrise = astroTable.first.sunrise,
          astroBaseSunset  = astroTable.first.sunset;
    int prevSunriseOffset  = 0,
        prevSunsetOffset   = 0;

    for(int i = 0; i < astroTable.length; i++) {
      astroTable[i].offsetSunrise = DateTime.utc(
        now.year, 1, 1,
        astroTable[i].sunrise.hour,
        astroTable[i].sunrise.minute - prevSunriseOffset,
      ).difference(astroBaseSunrise).inMinutes;
      prevSunriseOffset += astroTable[i].offsetSunrise!;

      astroTable[i].offsetSunset = DateTime.utc(
        now.year, 1, 1,
        astroTable[i].sunset.hour,
        astroTable[i].sunset.minute - prevSunsetOffset,
      ).difference(astroBaseSunset).inMinutes;
      prevSunsetOffset += astroTable[i].offsetSunset!;
    }

    return astroTable;
  }

  Future<List<AstroTableEntry>> getAstroTableFromPosition(Position position, bool enableSummerTime) async {
    int threads = 4;
    final List<List<AstroTableEntry>> results = List.filled(threads, []);
    final completer = Completer<List<AstroTableEntry>>();

    for(int threadId = 0; threadId < threads; threadId++) {
      compute(_calculateAstroTable, (threadId, position.latitude, position.longitude, enableSummerTime)).then((sunriseSunset) async {
        results[sunriseSunset.first.thread] = sunriseSunset;
        threads--;
        if(threads == 0) {
          final astroTable = await compute(_calculateAstroTableOffsets, results);
          completer.complete(astroTable);
        }
      });
    }
    return completer.future;
  }

  List<AstroTableEntry> getAstroTableFromOffsets({
    required List<int> sunrise,
    required List<int> sunset,
    required int sunriseBaseHours,
    required int sunriseBaseMinutes,
    required int sunsetBaseHours,
    required int sunsetBaseMinutes,
    required bool enableSummerTime
  }) {
    double sunriseBaseMillis = (sunriseBaseHours * _hourToMin + sunriseBaseMinutes) * _minToMilli,
            sunsetBaseMillis = (sunsetBaseHours  * _hourToMin + sunsetBaseMinutes)  * _minToMilli;

    final result = <AstroTableEntry>[];
    for(int i = 0; i < sunrise.length - 1; i++) {
      final offsetSunriseMillis = sunrise[i + 1] * _minToMilli / _granularity,
            offsetSunsetMillis  = sunset[i + 1]  * _minToMilli / _granularity;

      for(int day = 0; day < _granularity; day++) {
        final dayDate     = yearFirstDayUTC.add(Duration(days: i * _granularity + day)),
              sunriseDate = yearFirstDayUTC.add(Duration(milliseconds: sunriseBaseMillis.toInt())),
              sunsetDate  = yearFirstDayUTC.add(Duration(milliseconds: sunsetBaseMillis.toInt()));

        final sunriseCurvePoint = Offset(
          (i * _granularity + day) / yearDuration.inDays,
          1 - sunriseDate.difference(dayDate).inMinutes / (24 * _hourToMin)
        );

        final sunsetCurvePoint = Offset(
          (i * _granularity + day) / yearDuration.inDays,
          1 - sunsetDate.difference(dayDate).inMinutes / (24 * _hourToMin)
        );

        result.add(AstroTableEntry(
          sunrise: sunriseDate,
          sunset: sunsetDate,
          thread: 0,
          daylightSaving: !enableSummerTime ? false : yearFirstDay.add(Duration(days: i * _granularity + day)).hour != 0,
          offsetSunrise: day == 0 ? sunrise[i] : null,
          offsetSunset: day == 0 ? sunset[i] : null,
          curveSunrise: sunriseCurvePoint,
          curveSunset: sunsetCurvePoint
        ));

        sunriseBaseMillis += offsetSunriseMillis + 24 * _hourToMin * _minToMilli;
        sunsetBaseMillis += offsetSunsetMillis + 24 * _hourToMin * _minToMilli;
      }
    }

    return result;
  }


  ///
  ///
  ///
  /// ACTUAL ASTRO FUNCTIONS
  ///
  ///

  static double timeToJulian(DateTime ts) {
    return ts.millisecondsSinceEpoch / 1000 / 86400.0 + 2440587.5;
  }

  static double julianToTime(double j) {
    return (j - 2440587.5) * 86400;
  }

  static (DateTime, DateTime) calculateCivilDawn(
      DateTime timestamp,
      double latitude,
      double longitude,
      [double elevation = 0]
  ) {
    return calculateSunriseSunset(timestamp, latitude, longitude, elevation, -6);
  }

  static (DateTime, DateTime) calculateNauticalDawn(
      DateTime timestamp,
      double latitude,
      double longitude,
      [double elevation = 0]
  ) {
    return calculateSunriseSunset(timestamp, latitude, longitude, elevation, -12);
  }

  static (DateTime, DateTime) calculateSunriseSunset(
      DateTime timestamp,
      double latitude,
      double longitude,
      [
        double elevation = 0,
        double phase = -0.833
      ]
  ) {
    double julianDate    = timeToJulian(timestamp);
    int julianDay        = (julianDate - (2451545.0 + 0.0009) + 69.184 / 86400.0).ceil();
    double meanSolarTime = julianDay + 0.0009 - longitude / 360.0;
    double meanDeg       = (357.5291 + 0.98560028 * meanSolarTime) % 360;
    double meanRad       = radians(meanDeg);
    double centerDeg     = 1.9148 * sin(meanRad) + 0.02 * sin(2 * meanRad) + 0.0003 * sin(3 * meanRad);
    double longitudeDeg  = (meanDeg + centerDeg + 180.0 + 102.9372) % 360;
    double lambdaRad     = radians(longitudeDeg);
    double julianTransit = 2451545.0 + meanSolarTime + 0.0053 * sin(meanRad) - 0.0069 * sin(2 * lambdaRad);
    double sinD          = sin(lambdaRad) * sin(radians(23.4397));
    double cosD          = cos(asin(sinD));
    double hourAngle     = (sin(radians(phase - 2.076 * sqrt(elevation) / 60.0)) - sin(radians(latitude)) * sinD) / (cos(radians(latitude)) * cosD);
    double w0Radians     = acos(hourAngle);
    DateTime sunrise;
    DateTime sunset;
    if(w0Radians.isNaN && hourAngle >= 0) {
      throw("No Sunrise");
    } else if(w0Radians.isNaN && hourAngle < 0) {
      throw("No Sunset");
    } else {
      double w0Degrees   = degrees(w0Radians);
      double jRise       = julianTransit - w0Degrees / 360;
      double jSet        = julianTransit + w0Degrees / 360;
      sunrise = DateTime.fromMillisecondsSinceEpoch((julianToTime(jRise) * 1000).toInt(), isUtc: true);
      sunset = DateTime.fromMillisecondsSinceEpoch((julianToTime(jSet) * 1000).toInt(), isUtc: true);
    }
    return (sunrise, sunset);
  }
}


