import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as timezone;

import '../models/city.dart';

class ClockCard extends StatelessWidget {
  final City city;
  final bool german;
  final DateTime currentTime;

  const ClockCard({
    super.key,
    required this.city,
    required this.german,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final location = timezone.getLocation(city.timeZoneId);

    final cityTime = timezone.TZDateTime.from(
      currentTime,
      location,
    );

    final time =
        '${twoDigits(cityTime.hour)}:'
        '${twoDigits(cityTime.minute)}:'
        '${twoDigits(cityTime.second)}';

    final offset = formatOffset(
      cityTime.timeZoneOffset,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .surface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.countryName(german),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        city.cityName(german),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    offset,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                time,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatOffset(Duration duration) {
  final totalMinutes = duration.inMinutes;
  final negative = totalMinutes < 0;
  final absoluteMinutes = totalMinutes.abs();

  final hours = absoluteMinutes ~/ 60;
  final minutes = absoluteMinutes % 60;
  final sign = negative ? '-' : '+';

  if (minutes == 0) {
    return 'UTC$sign$hours';
  }

  return 'UTC$sign$hours:${twoDigits(minutes)}';
}

String twoDigits(int number) {
  return number.toString().padLeft(2, '0');
}