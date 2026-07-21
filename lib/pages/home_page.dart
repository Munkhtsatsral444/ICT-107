import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final bool german;

  const HomePage({
    super.key,
    required this.german,
  });

  String translate(String english, String deutsch) {
    return german ? deutsch : english;
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 4) {
      return translate('Good night', 'Gute Nacht');
    } else if (hour < 12) {
      return translate('Good morning', 'Guten Morgen');
    } else if (hour < 17) {
      return translate('Good afternoon', 'Guten Tag');
    } else if (hour < 23) {
      return translate('Good evening', 'Guten Abend');
    } else {
      return translate('Good night', 'Gute Nacht');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 600;
        final padding = mobile ? 18.0 : 28.0;

        final greetingCard = Card(
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getDate(german),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          getGreeting(),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              greetingCard,
            ],
          ),
        );
      },
    );
  }
}
String getDate(bool german) {
  final date = DateTime.now();

  final weekdays = german
      ? [
          'Montag',
          'Dienstag',
          'Mittwoch',
          'Donnerstag',
          'Freitag',
          'Samstag',
          'Sonntag',
        ]
      : [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday',
        ];

  return '${weekdays[date.weekday - 1]}  '
      '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}

String twoDigits(int number) {
  return number.toString().padLeft(2, '0');
}