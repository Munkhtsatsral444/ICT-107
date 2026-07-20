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

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    String greeting;

    if (hour < 4) {
      greeting = translate('Good night ⏾⋆', 'Gute Nacht ⏾⋆');
    } else if (hour < 12) {
      greeting = translate('Good morning ☀︎☕︎', 'Guten Morgen ☀︎☕︎');
    } else if (hour < 17) {
      greeting = translate('Good afternoon ☁︎', 'Guten Tag ☁︎');
    } else if (hour < 23) {
      greeting = translate('Good evening ⋆.⏾', 'Guten Abend ⋆.⏾');
    } else {
      greeting = translate('Good night ☾⋆', 'Gute Nacht ☾⋆');
    }

    return Align(
      alignment: Alignment.topCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mobile = constraints.maxWidth < 600;
          final padding = mobile ? 16.0 : 24.0;
          final titleSize = mobile ? 36.0 : 50.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getDate(german),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        greeting,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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