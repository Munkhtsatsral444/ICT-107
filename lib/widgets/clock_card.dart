import 'package:flutter/material.dart';
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
    final cityTime = currentTime
        .toUtc()
        .add(Duration(hours: city.utcOffset));

    final time =
        '${twoDigits(cityTime.hour)}:'
        '${twoDigits(cityTime.minute)}:'
        '${twoDigits(cityTime.second)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    city.countryName(german),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(
                  Icons.circle,
                  size: 12,
                ),
              ],
            ),
            const SizedBox(height: 28),
            FittedBox(
              child: Text(
                time,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const SizedBox(height: 8),
            Text(city.cityName(german)),
          ],
        ),
      ),
    );
  }
}

String twoDigits(int number) {
  return number.toString().padLeft(2, '0');
}