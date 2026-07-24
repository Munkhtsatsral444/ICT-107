import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/link.dart';

import '../models/meeting.dart';

class HomePage extends StatelessWidget {
  final bool german;
  final Meeting? nextMeeting;
  final List<Meeting> meetings;

  const HomePage({
    super.key,
    required this.german,
    required this.nextMeeting,
    required this.meetings,
  });

  String translate(String english, String deutsch) {
    return german ? deutsch : english;
  }

  tz.TZDateTime get sydneyNow {
    return tz.TZDateTime.now(
      tz.getLocation('Australia/Sydney'),
    );
  }

  String getGreeting() {
    final hour = sydneyNow.hour;

    if (hour < 4) {
      return translate(
        'Good night!',
        'Gute Nacht!',
      );
    } else if (hour < 12) {
      return translate(
        'Good morning!',
        'Guten Morgen!',
      );
    } else if (hour < 17) {
      return translate(
        'Good afternoon!',
        'Guten Tag!',
      );
    } else if (hour < 23) {
      return translate(
        'Good evening!',
        'Guten Abend!',
      );
    }

    return translate(
      'Good night!',
      'Gute Nacht!',
    );
  }

  List<Meeting> get upcomingMeetings {
    final now = DateTime.now();

    final futureMeetings = meetings.where(
      (meeting) {
        return meeting.enabled &&
            meeting.endTime.isAfter(now);
      },
    ).toList();

    futureMeetings.sort(
      (first, second) {
        return first.startTime.compareTo(
          second.startTime,
        );
      },
    );

    return futureMeetings.take(3).toList();
  }

  int get meetingsToday {
    final today = sydneyNow;

    return meetings.where(
      (meeting) {
        final date = meeting.startTime;

        return meeting.enabled &&
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
      },
    ).length;
  }

  bool get silentModeActive {
    final now = DateTime.now();

    return meetings.any(
      (meeting) => meeting.isActiveAt(now),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 800;

        final padding = constraints.maxWidth < 600
            ? 16.0
            : 24.0;
        
        final meetingModeHeader = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                translate(
                  'MEETING MODE',
                  'MEETING-MODUS',
                ),
                maxLines: 1,
                softWrap: false,
                style: GoogleFonts.playfairDisplay(
                  fontSize: mobile ? 40 : 50,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.5,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                translate(
                  'SCHEDULE • SILENT MODE • WORLD CLOCK',
                  'ZEITPLAN • LAUTLOSMODUS • WELTUHR',
                ),
                maxLines: 1,
                softWrap: false,
                style: GoogleFonts.montserrat(
                  fontSize: mobile ? 10 : 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.7,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.60),
                ),
              ),
            ),
          ],
        );

        final greetingCard = Card(
          child: Padding(
            padding: EdgeInsets.all(
              mobile ? 20 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  getDate(
                    german,
                    sydneyNow,
                  ),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(
                          alpha: 0.70,
                        ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    getGreeting(),
                    style:
                        GoogleFonts.playfairDisplay(
                      fontSize: mobile ? 38 : 50,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.5,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        final platformsCard = Card(
          child: Padding(
            padding: EdgeInsets.all(
              mobile ? 20 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        .withValues(
                          alpha: 0.70,
                        ),
                  ),
                ),

                const SizedBox(height: 18),

                MeetingLinkButton(
                  url: 'https://meet.google.com/',
                  icon: Icons.video_call_outlined,
                  label: translate(
                    'Open Google Meet',
                    'Google Meet öffnen',
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    MeetingLinkButton(
                      url: 'https://teams.microsoft.com/',
                      icon: Icons.groups_outlined,
                      label: translate(
                        'Open Teams',
                        'Teams öffnen',
                      ),
                    ),
                    MeetingLinkButton(
                      url: 'https://zoom.us/',
                      icon: Icons.videocam_outlined,
                      label: translate(
                        'Open Zoom',
                        'Zoom öffnen',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        final reminderCard = Card(
          child: Padding(
            padding: EdgeInsets.all(
              mobile ? 20 : 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  translate(
                    'Upcoming Reminder',
                    'Anstehende Erinnerung',
                  ).toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(
                          alpha: 0.70,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                if (nextMeeting == null)
                  Text(
                    translate(
                      'No upcoming reminders',
                      'Keine anstehenden Erinnerungen',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha: 0.55,
                          ),
                    ),
                  )
                else ...[
                  Text(
                    nextMeeting!.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${homeDate(nextMeeting!.startTime)}  '
                    '${homeTime(nextMeeting!.startTime)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha: 0.55,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        final overviewCard = Card(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: mobile ? 20 : 24,
              vertical: mobile ? 18 : 22,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  translate(
                    'Today\'s Overview',
                    'Heutige Übersicht',
                  ).toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(
                          alpha: 0.70,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                OverviewRow(
                  icon: Icons.schedule_outlined,
                  title: translate(
                    'Sydney time',
                    'Sydney-Uhrzeit',
                  ),
                  value: formatSydneyTime(
                    sydneyNow,
                  ),
                ),
                const SizedBox(height: 16),
                OverviewRow(
                  icon:
                      Icons.calendar_today_outlined,
                  title: translate(
                    'Meetings today',
                    'Meetings heute',
                  ),
                  value: meetingsToday.toString(),
                ),
                const SizedBox(height: 16),
                OverviewRow(
                  icon:
                      Icons.volume_off_outlined,
                  title: translate(
                    'Silent mode',
                    'Lautlosmodus',
                  ),
                  value: silentModeActive
                      ? translate(
                          'Active',
                          'Aktiv',
                        )
                      : translate(
                          'Ready',
                          'Bereit',
                        ),
                ),
              ],
            ),
          ),
        );

        final upcomingMeetingsCard = Card(
          child: Padding(
            padding: EdgeInsets.all(
              mobile ? 20 : 24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  translate(
                    'Upcoming Meetings',
                    'Anstehende Meetings',
                  ).toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(
                          alpha: 0.70,
                        ),
                  ),
                ),
                const SizedBox(height: 18),
                if (upcomingMeetings.isEmpty)
                  Text(
                    translate(
                      'No meetings scheduled',
                      'Keine Meetings geplant',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha: 0.55,
                          ),
                    ),
                  )
                else
                  ...List.generate(
                    upcomingMeetings.length,
                    (index) {
                      final meeting =
                          upcomingMeetings[index];

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index ==
                                  upcomingMeetings
                                          .length -
                                      1
                              ? 0
                              : 14,
                        ),
                        child: UpcomingMeetingRow(
                          meeting: meeting,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );

        final Widget content;
          if (mobile) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              greetingCard,
              const SizedBox(height: 20),

              meetingModeHeader,
              const SizedBox(height: 20),

              overviewCard,
              const SizedBox(height: 14),

              platformsCard,
              const SizedBox(height: 14),

              reminderCard,
              const SizedBox(height: 14),

              upcomingMeetingsCard,
            ],
          );
        } else {
            content = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      greetingCard,
                      const SizedBox(height: 14),

                      reminderCard,
                      const SizedBox(height: 14),

                      upcomingMeetingsCard,
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      meetingModeHeader,
                      const SizedBox(height: 24),

                      overviewCard,
                      const SizedBox(height: 14),

                      platformsCard,
                    ],
                  ),
                ),
              ],
            );
          }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
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

class OverviewRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const OverviewRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurface,
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context)
                .colorScheme
                .surface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class UpcomingMeetingRow extends StatelessWidget {
  final Meeting meeting;

  const UpcomingMeetingRow({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurface,
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            Icons.event_outlined,
            size: 18,
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
                meeting.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                homeDate(meeting.startTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(
                        alpha: 0.55,
                      ),
                ),
              ),
            ],
          ),
        ),
        Text(
          homeTime(meeting.startTime),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }
}

String getDate(
  bool german,
  DateTime date,
) {
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

String formatSydneyTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String homeDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String homeTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}