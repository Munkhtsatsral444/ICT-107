import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/world_clock_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const MeetingModeApp());
}

class MeetingModeApp extends StatefulWidget {
  const MeetingModeApp({super.key});

  @override
  State<MeetingModeApp> createState() => _MeetingModeAppState();
}

class _MeetingModeAppState extends State<MeetingModeApp> {
  int selectedIndex = 0;
  bool german = false;
  bool darkMode = false;

  String translate(String english, String deutsch) {
    return german ? deutsch : english;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: createTheme(Brightness.light),
      darkTheme: createTheme(Brightness.dark),
      home: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 850;

          final pages = [
            HomePage(german: german),
            WorldClockPage(german: german),
            SettingsPage(
              german: german,
              darkMode: darkMode,
              onLanguageChanged: (value) {
                setState(() {
                  german = value;
                });
              },
              onThemeChanged: (value) {
                setState(() {
                  darkMode = value;
                });
              },
            ),
          ];

          final labels = [
            translate('Home', 'Startseite'),
            translate('World Clock', 'Weltuhr'),
            translate('Settings', 'Einstellungen'),
          ];

          final icons = [
            Icons.home,
            Icons.public,
            Icons.settings,
          ];

          return Scaffold(
            body: SafeArea(
              child: isWeb
                  ? Row(
                      children: [
                        NavigationRail(
                          selectedIndex: selectedIndex,
                          labelType: NavigationRailLabelType.all,
                          destinations: List.generate(
                            labels.length,
                            (index) => NavigationRailDestination(
                              icon: Icon(icons[index]),
                              label: Text(labels[index]),
                            ),
                          ),
                          onDestinationSelected: (index) {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: pages[selectedIndex],
                        ),
                      ],
                    )
                  : pages[selectedIndex],
            ),
            bottomNavigationBar: isWeb
                ? null
                : NavigationBar(
                    selectedIndex: selectedIndex,
                    destinations: List.generate(
                      labels.length,
                      (index) => NavigationDestination(
                        icon: Icon(icons[index]),
                        label: labels[index],
                      ),
                    ),
                    onDestinationSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
          );
        },
      ),
    );
  }

  ThemeData createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: Colors.grey,
      scaffoldBackgroundColor:
          isDark ? const Color(0xff111111) : const Color(0xfff5f5f5),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xff1d1d1d) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
      ),
    );
  }
}