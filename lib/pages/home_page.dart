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
        final desktop = constraints.maxWidth >= 950;
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
                const SizedBox(width: 14),
                Container(
                  width: mobile ? 60 : 78,
                  height: mobile ? 60 : 78,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.waving_hand_rounded,
                    color: Colors.white,
                    size: mobile ? 28 : 34,
                  ),
                ),
              ],
            ),
          ),
        );

        final statistics = Row(
          children: [
            Expanded(
              child: StatCard(
                number: '5',
                label: translate('world cities', 'Weltstädte'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                number: '2',
                label: translate('languages', 'Sprachen'),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: greetingCard,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: statistics,
                    ),
                  ],
                )
              else ...[
                greetingCard,
                const SizedBox(height: 16),
                statistics,
              ],
              const SizedBox(height: 30),
              Text(
                translate('Quick overview', 'Schnellübersicht'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, cardConstraints) {
                  final columns =
                      cardConstraints.maxWidth >= 760 ? 3 : 1;
                  const gap = 14.0;

                  final cardWidth = (cardConstraints.maxWidth -
                          gap * (columns - 1)) /
                      columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      OverviewCard(
                        width: cardWidth,
                        icon: Icons.public_rounded,
                        title: translate('World Clock', 'Weltuhr'),
                        text: translate(
                          'Live time for 5 major cities',
                          'Live-Zeit für 5 große Städte',
                        ),
                      ),
                      OverviewCard(
                        width: cardWidth,
                        icon: Icons.translate_rounded,
                        title: translate('Languages', 'Sprachen'),
                        text: translate(
                          'English and German',
                          'Englisch und Deutsch',
                        ),
                      ),
                      OverviewCard(
                        width: cardWidth,
                        icon: Icons.devices_rounded,
                        title: translate('Responsive', 'Responsiv'),
                        text: translate(
                          'Mobile, tablet and web',
                          'Mobil, Tablet und Web',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String number;
  final String label;

  const StatCard({
    super.key,
    required this.number,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String text;

  const OverviewCard({
    super.key,
    required this.width,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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