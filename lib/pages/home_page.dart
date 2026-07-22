import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';
import 'package:google_fonts/google_fonts.dart';

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
      return translate('Good night!', 'Gute Nacht!');
    } else if (hour < 12) {
      return translate('Good morning!', 'Guten Morgen!');
    } else if (hour < 17) {
      return translate('Good afternoon!', 'Guten Tag!');
    } else if (hour < 23) {
      return translate('Good evening!', 'Guten Abend!');
    } else {
      return translate('Good night!', 'Gute Nacht!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 800;
        final padding = constraints.maxWidth < 600 ? 16.0 : 24.0;

        final greetingCard = SizedBox(
          height: mobile ? 155 : 165,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(mobile ? 20 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getDate(german),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.70),
                    ),
                  ),
                  const SizedBox(height: 0),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      getGreeting(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: mobile ? 44 : 58,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final platformsCard = Card(
          child: Padding(
            padding: EdgeInsets.all(mobile ? 20 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate(
                    'Online Meeting Suggestions',
                    'Vorschläge für Online-Meetings',
                  ).toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    MeetingLinkButton(
                      url: 'https://zoom.us/',
                      icon: Icons.videocam_outlined,
                      label: translate(
                        'Open Zoom',
                        'Zoom öffnen',
                      ),
                    ),
                    MeetingLinkButton(
                      url: 'https://meet.google.com/',
                      icon: Icons.video_call_outlined,
                      label: translate(
                        'Open Google Meet',
                        'Google Meet öffnen',
                      ),
                    ),
                    MeetingLinkButton(
                      url: 'https://teams.microsoft.com/',
                      icon: Icons.groups_outlined,
                      label: translate(
                        'Open Teams',
                        'Teams öffnen',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        final reminderCard = SizedBox(
          height: mobile ? 130 : 145,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate(
                            'Upcoming Reminder',
                            'Anstehende Erinnerung',
                          ),
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          translate(
                            'No upcoming reminders',
                            'Keine anstehenden Erinnerungen',
                          ),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
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
        Widget content;

        if (mobile) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              greetingCard,
              const SizedBox(height: 14),
              platformsCard,
              const SizedBox(height: 14),
              reminderCard,
            ],
          );
        } else {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    greetingCard,
                    const SizedBox(height: 14),
                    platformsCard,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: reminderCard,
              ),
            ],
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1120,
              ),
              child: content,
            ),
          ),
        );
      },
    );
  }
}

class MeetingLinkButton extends StatelessWidget {
  final String url;
  final IconData icon;
  final String label;

  const MeetingLinkButton({
    super.key,
    required this.url,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse(url),
      target: LinkTarget.blank,
      builder: (context, openLink) {
        return FilledButton.icon(
          onPressed: openLink,
          icon: Icon(
            icon,
            size: 17,
          ),
          label: Text(
            label,
            style: const TextStyle(fontSize: 13),
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

  final months = german
      ? [
          'Januar',
          'Februar',
          'März',
          'April',
          'Mai',
          'Juni',
          'Juli',
          'August',
          'September',
          'Oktober',
          'November',
          'Dezember',
        ]
      : [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];

  return '${weekdays[date.weekday - 1]} '
          '${date.day} '
          '${months[date.month - 1]}'
      .toUpperCase();
}