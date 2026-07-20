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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          german ? 'Einstellungen' : 'Settings',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: german,
                    onChanged: onLanguageChanged,
                    secondary: const Icon(Icons.language),
                    title: Text(
                      german
                          ? 'Deutsche Sprache'
                          : 'German language',
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: darkMode,
                    onChanged: onThemeChanged,
                    secondary: const Icon(
                      Icons.dark_mode_outlined,
                    ),
                    title: Text(
                      german
                          ? 'Dunkles Design'
                          : 'Dark mode',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}