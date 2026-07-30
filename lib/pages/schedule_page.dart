import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/meeting.dart';

class SchedulePage extends StatefulWidget {
  final bool german;
  final List<Meeting> meetings;

  final Future<void> Function(Meeting meeting)
      onAddMeeting;

  final Future<void> Function(Meeting meeting)
      onUpdateMeeting;

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
    required this.onUpdateMeeting,
    required this.onDeleteMeeting,
    required this.onToggleMeeting,
  });

  @override
  State<SchedulePage> createState() {
    return _SchedulePageState();
  }
}

class _SchedulePageState extends State<SchedulePage> {
  final TextEditingController titleController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  int durationMinutes = 60;
  String selectedMode = 'silent';

  Meeting? editingMeeting;

  String translate(
    String english,
    String deutsch,
  ) {
    return widget.german ? deutsch : english;
  }

  @override
  void dispose() {
    titleController.dispose();
    scrollController.dispose();
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
      helpText: translate(
        'Select time',
        'Uhrzeit auswählen',
      ),
      cancelText: translate(
        'Cancel',
        'Abbrechen',
      ),
      confirmText: 'OK',
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en'),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child!,
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedTime = result;
      });
    }
  }

  void startEditing(Meeting meeting) {
    final meetingDuration = meeting.endTime
        .difference(meeting.startTime)
        .inMinutes;

    setState(() {
      editingMeeting = meeting;
      titleController.text = meeting.title;
      selectedDate = meeting.startTime;
      selectedTime = TimeOfDay.fromDateTime(
        meeting.startTime,
      );
      durationMinutes = meetingDuration;
      selectedMode = meeting.mode == 'vibrate'
          ? 'vibrate'
          : 'silent';
    });

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(
          milliseconds: 350,
        ),
        curve: Curves.easeOut,
      );
    }
  }

  void resetForm() {
    titleController.clear();

    setState(() {
      editingMeeting = null;
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
      durationMinutes = 60;
      selectedMode = 'silent';
    });
  }

  Future<void> saveMeeting() async {
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

    final currentEditingMeeting = editingMeeting;

    final meetingId = currentEditingMeeting?.id ??
        DateTime.now()
            .millisecondsSinceEpoch
            .remainder(2147483647);

    final meeting = Meeting(
      id: meetingId,
      title: title,
      startTime: startTime,
      endTime: startTime.add(
        Duration(minutes: durationMinutes),
      ),
      mode: selectedMode,
      enabled:
          currentEditingMeeting?.enabled ?? true,
    );

    if (currentEditingMeeting == null) {
      await widget.onAddMeeting(meeting);
    } else {
      await widget.onUpdateMeeting(meeting);
    }

    if (!mounted) {
      return;
    }

    final message = currentEditingMeeting == null
        ? translate(
            'Meeting added successfully',
            'Meeting wurde erfolgreich hinzugefügt',
          )
        : translate(
            'Meeting updated successfully',
            'Meeting wurde erfolgreich aktualisiert',
          );

    resetForm();
    showMessage(message);
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

  MenuItemButton durationButton(int minutes) {
    return MenuItemButton(
      onPressed: () {
        setState(() {
          durationMinutes = minutes;
        });
      },
      child: Text(
        translate(
          '$minutes minutes',
          '$minutes Minuten',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 600;

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
          controller: scrollController,
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
                    editingMeeting == null
                        ? translate(
                            'Add Meeting',
                            'Meeting hinzufügen',
                          )
                        : translate(
                            'Edit Meeting',
                            'Meeting bearbeiten',
                          ),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: mobile ? 34 : 40,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    editingMeeting == null
                        ? translate(
                            'Create a meeting with silent or vibration mode',
                            'Erstellen Sie ein Meeting mit Lautlos- oder Vibrationsmodus',
                          )
                        : translate(
                            'Update the meeting information',
                            'Aktualisieren Sie die Meeting-Informationen',
                          ),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.60),
                    ),
                  ),
                  const SizedBox(height: 22),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: titleController,
                            textInputAction:
                                TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: translate(
                                'Meeting title',
                                'Meeting-Titel',
                              ),
                              prefixIcon: const Icon(
                                Icons.edit_calendar_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

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
                                  formatMeetingDate(
                                    selectedDate,
                                  ),
                                ),
                              ),

                              OutlinedButton.icon(
                                onPressed: chooseTime,
                                icon: const Icon(
                                  Icons.schedule_outlined,
                                ),
                                label: Text(
                                  selectedTime.format(
                                    context,
                                  ),
                                ),
                              ),

                              MenuAnchor(
                                menuChildren: [
                                  durationButton(30),
                                  durationButton(60),
                                  durationButton(90),
                                  durationButton(120),
                                ],
                                builder: (
                                  context,
                                  controller,
                                  child,
                                ) {
                                  return InkWell(
                                    onTap: () {
                                      if (controller.isOpen) {
                                        controller.close();
                                      } else {
                                        controller.open();
                                      }
                                    },
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    child: Container(
                                      width: mobile
                                          ? double.infinity
                                          : 190,
                                      height: 40,
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                          12,
                                        ),
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
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SegmentedButton<String>(
                                segments: [
                                  ButtonSegment<String>(
                                    value: 'silent',
                                    icon: const Icon(
                                      Icons.volume_off_outlined,
                                    ),
                                    label: Text(
                                      translate(
                                        'Silent',
                                        'Lautlos',
                                      ),
                                    ),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'vibrate',
                                    icon: const Icon(
                                      Icons.vibration,
                                    ),
                                    label: Text(
                                      translate(
                                        'Vibrate',
                                        'Vibrieren',
                                      ),
                                    ),
                                  ),
                                ],
                                selected: {
                                  selectedMode,
                                },
                                onSelectionChanged:
                                    (selection) {
                                  setState(() {
                                    selectedMode =
                                        selection.first;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              FilledButton.icon(
                                onPressed: saveMeeting,
                                icon: Icon(
                                  editingMeeting == null
                                      ? Icons.add
                                      : Icons.save_outlined,
                                ),
                                label: Text(
                                  editingMeeting == null
                                      ? translate(
                                          'Add Meeting',
                                          'Meeting hinzufügen',
                                        )
                                      : translate(
                                          'Update Meeting',
                                          'Meeting aktualisieren',
                                        ),
                                ),
                              ),

                              if (editingMeeting != null)
                                TextButton(
                                  onPressed: resetForm,
                                  child: Text(
                                    translate(
                                      'Cancel Edit',
                                      'Bearbeiten abbrechen',
                                    ),
                                  ),
                                ),
                            ],
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (sortedMeetings.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: SizedBox(
                          width: double.infinity,
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
                          padding: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: MeetingCard(
                            meeting: meeting,
                            german: widget.german,
                            onEdit: () {
                              startEditing(meeting);
                            },
                            onDelete: () async {
                              await widget.onDeleteMeeting(
                                meeting,
                              );
                            },
                            onToggle: (value) async {
                              await widget.onToggleMeeting(
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
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final Future<void> Function(bool value)
      onToggle;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.german,
    required this.onEdit,
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
    final vibrateMode =
        meeting.mode == 'vibrate';

    final modeText = vibrateMode
        ? translate(
            'Vibrate mode',
            'Vibrationsmodus',
          )
        : translate(
            'Silent mode',
            'Lautlosmodus',
          );

    final modeIcon = vibrateMode
        ? Icons.vibration
        : Icons.volume_off_outlined;

    final expired = meeting.endTime.isBefore(
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
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    modeIcon,
                    color: Theme.of(context)
                        .colorScheme
                        .surface,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.title,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatMeetingDate(meeting.startTime)}  '
                        '${formatMeetingTime(meeting.startTime)} – '
                        '${formatMeetingTime(meeting.endTime)}',
                      ),
                      const SizedBox(height: 3),
                      Text(
                        expired
                            ? translate(
                                'Completed',
                                'Abgeschlossen',
                              )
                            : modeText,
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
            );

            final actions = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value:
                      meeting.enabled && !expired,
                  onChanged: expired
                      ? null
                      : (value) {
                          onToggle(value);
                        },
                ),
                IconButton(
                  tooltip: translate(
                    'Edit',
                    'Bearbeiten',
                  ),
                  onPressed: onEdit,
                     
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
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
                    CrossAxisAlignment.stretch,
                children: [
                  information,
                  const SizedBox(height: 10),
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