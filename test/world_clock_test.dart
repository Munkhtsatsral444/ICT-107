import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_mode/models/city.dart';
import 'package:timezone/data/latest.dart'
    as timezone_data;
import 'package:timezone/timezone.dart'
    as timezone;

void main() {
  setUpAll(() {
    timezone_data.initializeTimeZones();
  });

  test(
    'World clock calculates correct city times',
    () {
      final utcTime = DateTime.utc(
        2026,
        7,
        30,
        12,
      );

      final sydney = timezone.TZDateTime.from(
        utcTime,
        timezone.getLocation(
          'Australia/Sydney',
        ),
      );

      final london = timezone.TZDateTime.from(
        utcTime,
        timezone.getLocation(
          'Europe/London',
        ),
      );

      final tokyo = timezone.TZDateTime.from(
        utcTime,
        timezone.getLocation(
          'Asia/Tokyo',
        ),
      );

      expect(sydney.hour, 22);
      expect(london.hour, 13);
      expect(tokyo.hour, 21);
    },
  );

  test(
    'City names switch between English and German',
    () {
      final berlin = majorCities.firstWhere(
        (city) => city.englishCity == 'Berlin',
      );

      expect(
        berlin.countryName(false),
        'Germany',
      );

      expect(
        berlin.countryName(true),
        'Deutschland',
      );
    },
  );
}