import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatelessWidget {
  final bool german;
  final bool darkMode;
  final bool notificationSupported;
  final bool meetingModeSupported;

  final ValueChanged<bool>
      onLanguageChanged;

  final ValueChanged<bool>
      onThemeChanged;

  final Future<bool> Function()
      onNotificationPressed;

  final Future<bool> Function()
      onMeetingModePressed;

  const SettingsPage({
    super.key,
    required this.german,
    required this.darkMode,
    required this.notificationSupported,
    required this.meetingModeSupported,
    required this.onLanguageChanged,
    required this.onThemeChanged,
    required this.onNotificationPressed,
    required this.onMeetingModePressed,
  });

  String translate(
    String english,
    String deutsch,
  ) {
    return german ? deutsch : english;
  }

  Future<void> enableNotifications(
    BuildContext context,
  ) async {
    final result =
        await onNotificationPressed();

    if (!context.mounted) {
      return;
    }

    showMessage(
      context,
      result
          ? translate(
              'Notifications are enabled',
              'Benachrichtigungen sind aktiviert',
            )
          : translate(
              'Notification permission was not granted',
              'Die Benachrichtigungsberechtigung wurde nicht erteilt',
            ),
    );
  }

  Future<void> enableMeetingMode(
    BuildContext context,
  ) async {
    final result =
        await onMeetingModePressed();

    if (!context.mounted) {
      return;
    }

    showMessage(
      context,
      result
          ? translate(
              'Meeting mode permission is enabled',
              'Die Meeting-Modus-Berechtigung ist aktiviert',
            )
          : translate(
              'Allow access in the Android settings, then return to the app',
              'Erlauben Sie den Zugriff in den Android-Einstellungen und kehren Sie dann zur App zurück',
            ),
    );
  }

  void showMessage(
    BuildContext context,
    String message,
  ) {
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

        return ListView(
          padding: EdgeInsets.all(
            mobile ? 18 : 28,
          ),
          children: [
            Text(
              translate(
                'Settings',
                'Einstellungen',
              ),
              style:
                  GoogleFonts.playfairDisplay(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              translate(
                'Personalise language and appearance',
                'Sprache und Darstellung anpassen',
              ),
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.60),
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 760,
              ),
              child: Column(
                children: [
                  SettingCard(
                    icon:
                        Icons.translate_rounded,
                    title: translate(
                      'Language',
                      'Sprache',
                    ),
                    subtitle: german
                        ? 'Deutsch'
                        : 'English',
                    value: german,
                    onChanged:
                        onLanguageChanged,
                  ),
                  const SizedBox(height: 14),
                  SettingCard(
                    icon:
                        Icons.dark_mode_rounded,
                    title: translate(
                      'Dark mode',
                      'Dunkles Design',
                    ),
                    subtitle: translate(
                      'Switch to dark mode',
                      'Zum dunklen Modus wechseln',
                    ),
                    value: darkMode,
                    onChanged:
                        onThemeChanged,
                  ),
                  const SizedBox(height: 14),
                  ActionSettingCard(
                    icon: Icons
                        .notifications_active_outlined,
                    title: translate(
                      'Notifications',
                      'Benachrichtigungen',
                    ),
                    subtitle:
                        notificationSupported
                            ? translate(
                                'Enable reminders five minutes before meetings',
                                'Erinnerungen fünf Minuten vor Meetings aktivieren',
                              )
                            : translate(
                                'Notifications are unavailable on this platform',
                                'Benachrichtigungen sind auf dieser Plattform nicht verfügbar',
                              ),
                    buttonText: translate(
                      'Enable',
                      'Aktivieren',
                    ),
                    onPressed:
                        notificationSupported
                            ? () {
                                enableNotifications(
                                  context,
                                );
                              }
                            : null,
                  ),
                  const SizedBox(height: 14),
                  ActionSettingCard(
                    icon:
                        Icons.volume_off_outlined,
                    title: translate(
                      'Meeting mode permission',
                      'Meeting-Modus-Berechtigung',
                    ),
                    subtitle:
                        meetingModeSupported
                            ? translate(
                                'Allow automatic silent and vibrate mode',
                                'Automatischen Lautlos- und Vibrationsmodus erlauben',
                              )
                            : translate(
                                'Automatic sound mode is available on Android',
                                'Der automatische Tonmodus ist auf Android verfügbar',
                              ),
                    buttonText: translate(
                      'Open Settings',
                      'Einstellungen öffnen',
                    ),
                    onPressed:
                        meetingModeSupported
                            ? () {
                                enableMeetingMode(
                                  context,
                                );
                              }
                            : null,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          secondary: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 22,
              color: Theme.of(context)
                  .colorScheme
                  .surface,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class ActionSettingCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onPressed;

  const ActionSettingCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow =
                constraints.maxWidth < 520;

            final information = Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface,
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: Theme.of(context)
                        .colorScheme
                        .surface,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        title,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(subtitle),
                    ],
                  ),
                ),
              ],
            );

            final button = FilledButton(
              onPressed: onPressed,
              child: Text(buttonText),
            );

            if (narrow) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  information,
                  const SizedBox(
                    height: 14,
                  ),
                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: button,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: information,
                ),
                const SizedBox(width: 14),
                button,
              ],
            );
          },
        ),
      ),
    );
  }
}