import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool german;
  final bool darkMode;
  final ValueChanged<bool> onLanguageChanged;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.german,
    required this.darkMode,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  String translate(String english, String deutsch) {
    return german ? deutsch : english;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 600;

        return ListView(
          padding: EdgeInsets.all(mobile ? 18 : 28),
          children: [
            Text(
              translate('Settings', 'Einstellungen'),
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
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
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                children: [
                  SettingCard(
                    icon: Icons.translate_rounded,
                    title: translate('Language', 'Sprache'),
                    subtitle: german ? 'Deutsch' : 'English',
                    value: german,
                    onChanged: onLanguageChanged,
                  ),
                  const SizedBox(height: 14),
                  SettingCard(
                    icon: Icons.dark_mode_rounded,
                    title: translate('Dark mode', 'Dunkles Design'),
                    subtitle: translate(
                      'Use a dark black and grey theme',
                      'Dunkles Schwarz-Grau-Design verwenden',
                    ),
                    value: darkMode,
                    onChanged: onThemeChanged,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          secondary: Container(
            width: 48,
            height: 48,
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