import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/schedule_page.dart';
import 'pages/settings_page.dart';
import 'pages/world_clock_page.dart';

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
          final desktop = constraints.maxWidth >= 850;

          final pages = [
            HomePage(german: german),
            SchedulePage(german: german),
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
            translate('Add Meeting', 'Meeting hinzufügen'),
            translate('World Clock', 'Weltuhr'),
            translate('Settings', 'Einstellungen'),
          ];

          final icons = [
            CupertinoIcons.house,
            Icons.add_circle_outline,
            CupertinoIcons.globe,
            CupertinoIcons.gear,
          ];

          if (desktop) {
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DesktopNavigation(
                        icons: icons,
                        labels: labels,
                        selectedIndex: selectedIndex,
                        onSelected: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: IndexedStack(
                          index: selectedIndex,
                          children: pages,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: selectedIndex,
                children: pages,
              ),
            ),
            bottomNavigationBar: MobileNavigation(
              icons: icons,
              labels: labels,
              selectedIndex: selectedIndex,
              onSelected: (index) {
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
    final dark = brightness == Brightness.dark;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: brightness,
    ).copyWith(
      primary: dark ? Colors.white : Colors.black,
      onPrimary: dark ? Colors.black : Colors.white,
      secondary: dark ? Colors.white : Colors.black,
      onSecondary: dark ? Colors.black : Colors.white,
      surface: dark ? const Color(0xff151515) : Colors.white,
      onSurface: dark ? Colors.white : Colors.black,
      surfaceContainerHighest:
          dark ? const Color(0xff242424) : const Color(0xfff3f3f5),
      outline: dark ? Colors.white30 : Colors.black26,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xff101010) : Colors.white,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return dark ? Colors.white : Colors.black;
          }

          return dark ? Colors.white24 : Colors.black26;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return dark ? Colors.black : Colors.white;
          }

          return dark ? Colors.white70 : Colors.white;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(
          Colors.transparent,
        ),
      ),
    );
  }
}

class DesktopNavigation extends StatelessWidget {
  final List<IconData> icons;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DesktopNavigation({
    super.key,
    required this.icons,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(6, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 34),
          ...List.generate(icons.length, (index) {
            final selected = selectedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Tooltip(
                message: labels[index],
                child: InkWell(
                  onTap: () {
                    onSelected(index);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icons[index],
                      size: 19,
                      color: selected
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MobileNavigation extends StatelessWidget {
  final List<IconData> icons;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const MobileNavigation({
    super.key,
    required this.icons,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: List.generate(icons.length, (index) {
              final selected = selectedIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    onSelected(index);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 20,
                        color: selected
                            ? Colors.white
                            : Colors.white60,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        labels[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? Colors.white
                              : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}