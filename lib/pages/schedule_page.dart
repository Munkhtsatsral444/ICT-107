import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/meeting.dart';

class SchedulePage extends StatefulWidget {
  final bool german;
  final List<Meeting> meetings;

  final Future<void> Function(Meeting meeting)
      onAddMeeting;

  final Future<void> Function(Meeting meeting)
      onDeleteMeeting;

  final Future<void> Function(
    Meeting meeting,
    bool enabled,
  ) onToggleMeeting;

  const SchedulePage({
    super.key,
    required this.german,
    required this.meetings,
    required this.onAddMeeting,
    required this.onDeleteMeeting,
    required this.onToggleMeeting,
  });

  @override
  State<SchedulePage> createState() {
    return _SchedulePageState();
  }
}

class _SchedulePageState
    extends State<SchedulePage> {
  final TextEditingController titleController =
      TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  int durationMinutes = 60;

  String translate(
    String english,
    String deutsch,
  ) {
    return widget.german
        ? deutsch
        : english;
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
    }
  }

  Future<void> chooseTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (result != null) {
      setState(() {
        selectedTime = result;
      });
    }
  }

  Future<void> addMeeting() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      showMessage(
        translate(
          'Please enter a meeting title',
          'Bitte geben Sie einen Meeting-Titel ein',
        ),
      );

      return;
    }

    final startTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (!startTime.isAfter(DateTime.now())) {
      showMessage(
        translate(
          'Please select a future date and time',
          'Bitte wählen Sie ein zukünftiges Datum und eine zukünftige Uhrzeit',
        ),
      );

      return;
    }

    final meetingId = DateTime.now()
        .millisecondsSinceEpoch
        .remainder(2147483647);

    final meeting = Meeting(
      id: meetingId,
      title: title,
      startTime: startTime,
      endTime: startTime.add(
        Duration(minutes: durationMinutes),
      ),
      mode: 'silent',
    );

    await widget.onAddMeeting(meeting);

    titleController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
      durationMinutes = 60;
    });

    showMessage(
      translate(
        'Meeting added successfully',
        'Meeting wurde erfolgreich hinzugefügt',
      ),
    );
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile =
            constraints.maxWidth < 600;

        final sortedMeetings = [
          ...widget.meetings,
        ]..sort(
            (first, second) {
              return first.startTime.compareTo(
                second.startTime,
              );
            },
          );

        return SingleChildScrollView(
          padding: EdgeInsets.all(
            mobile ? 16 : 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1120,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    translate(
                      'Add Meeting',
                      'Meeting hinzufügen',
                    ),
                    style: GoogleFonts
                        .playfairDisplay(
                      fontSize: 40,
                      fontWeight:
                          FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    translate(
                      'Create a meeting schedule with silent mode',
                      'Erstellen Sie einen Meeting-Zeitplan mit Lautlosmodus',
                    ),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(
                            alpha: 0.60,
                          ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .stretch,
                        children: [
                          TextField(
                            controller:
                                titleController,
                            textInputAction:
                                TextInputAction
                                    .done,
                            decoration:
                                InputDecoration(
                              labelText: translate(
                                'Meeting title',
                                'Meeting-Titel',
                              ),
                              prefixIcon:
                                  const Icon(
                                Icons
                                    .edit_calendar_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              OutlinedButton.icon(
                                onPressed: chooseDate,
                                icon: const Icon(
                                  Icons.calendar_today_outlined,
                                ),
                                label: Text(
                                  formatMeetingDate(selectedDate),
                                ),
                              ),

                              OutlinedButton.icon(
                                onPressed: chooseTime,
                                icon: const Icon(
                                  Icons.schedule_outlined,
                                ),
                                label: Text(
                                  selectedTime.format(context),
                                ),
                              ),
                              MenuAnchor(
                                menuChildren: [
                                  MenuItemButton(
                                    onPressed: () {
                                      setState(() {
                                        durationMinutes = 30;
                                      });
                                    },
                                    child: Text(
                                      translate('30 minutes', '30 Minuten'),
                                    ),
                                  ),
                                  MenuItemButton(
                                    onPressed: () {
                                      setState(() {
                                        durationMinutes = 60;
                                      });
                                    },
                                    child: Text(
                                      translate('60 minutes', '60 Minuten'),
                                    ),
                                  ),
                                  MenuItemButton(
                                    onPressed: () {
                                      setState(() {
                                        durationMinutes = 90;
                                      });
                                    },
                                    child: Text(
                                      translate('90 minutes', '90 Minuten'),
                                    ),
                                  ),
                                  MenuItemButton(
                                    onPressed: () {
                                      setState(() {
                                        durationMinutes = 120;
                                      });
                                    },
                                    child: Text(
                                      translate('120 minutes', '120 Minuten'),
                                    ),
                                  ),
                                ],
                                builder: (
                                  BuildContext context,
                                  MenuController controller,
                                  Widget? child,
                                ) {
                                  return InkWell(
                                    onTap: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: mobile ? double.infinity : 190,
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.timer_outlined,
                                            size: 18,
                                          ),

                                          const SizedBox(width: 8),

                                          Expanded(
                                            child: Text(
                                              translate(
                                                '$durationMinutes minutes',
                                                '$durationMinutes Minuten',
                                              ),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),

                                          const Icon(
                                            Icons.arrow_drop_down,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment:
                                Alignment
                                    .centerLeft,
                            child:
                                FilledButton.icon(
                              onPressed:
                                  addMeeting,
                              icon: const Icon(
                                Icons.add,
                              ),
                              label: Text(
                                translate(
                                  'Add Meeting',
                                  'Meeting hinzufügen',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    translate(
                      'Scheduled Meetings',
                      'Geplante Meetings',
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (sortedMeetings.isEmpty)
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(24),
                        child: SizedBox(
                          width:
                              double.infinity,
                          child: Text(
                            translate(
                              'The meeting will appear here',
                              'Das Meeting wird hier angezeigt',
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    ...sortedMeetings.map(
                      (meeting) {
                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),
                          child: MeetingCard(
                            meeting: meeting,
                            german:
                                widget.german,
                            onDelete:
                                () async {
                              await widget
                                  .onDeleteMeeting(
                                meeting,
                              );
                            },
                            onToggle:
                                (value) async {
                              await widget
                                  .onToggleMeeting(
                                meeting,
                                value,
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final bool german;
  final Future<void> Function() onDelete;
  final Future<void> Function(bool value)
      onToggle;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.german,
    required this.onDelete,
    required this.onToggle,
  });

  String translate(
    String english,
    String deutsch,
  ) {
    return german ? deutsch : english;
  }

  @override
  Widget build(BuildContext context) {
    final modeText = translate(
      'Silent mode',
      'Lautlosmodus',
    );

    final expired =
        meeting.endTime.isBefore(
      DateTime.now(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow =
                constraints.maxWidth < 520;

            final information = Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    Icons.volume_off_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .surface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        meeting.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '${formatMeetingDate(meeting.startTime)}  '
                        '${formatMeetingTime(meeting.startTime)} – '
                        '${formatMeetingTime(meeting.endTime)}',
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        expired
                            ? translate(
                                'Completed',
                                'Abgeschlossen',
                              )
                            : modeText,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          )
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
              ],
            );

            final actions = Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Switch(
                  value:
                      meeting.enabled &&
                          !expired,
                  onChanged: expired
                      ? null
                      : (value) {
                          onToggle(value);
                        },
                ),
                IconButton(
                  tooltip: translate(
                    'Delete',
                    'Löschen',
                  ),
                  onPressed: () {
                    onDelete();
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ],
            );

            if (narrow) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  information,
                  const SizedBox(
                    height: 10,
                  ),
                  Align(
                    alignment:
                        Alignment.centerRight,
                    child: actions,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: information,
                ),
                const SizedBox(width: 12),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }
}

String formatMeetingDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

String formatMeetingTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}