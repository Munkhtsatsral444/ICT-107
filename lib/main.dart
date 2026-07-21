import 'package:flutter/material.dart';

import 'pages/home_page.dart';
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
            Icons.home_rounded,
            Icons.public_rounded,
            Icons.settings_rounded,
          ];

          if (desktop) {
            return Scaffold(
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 78,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            const Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 42),
                            ...List.generate(labels.length, (index) {
                              final selected = selectedIndex == index;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Tooltip(
                                  message: labels[index],
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        icons[index],
                                        color: selected
                                            ? Colors.black
                                            : Colors.white60,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: ColoredBox(
                            color: Theme.of(context).colorScheme.surface,
                            child: IndexedStack(
                              index: selectedIndex,
                              children: pages,
                            ),
                          ),
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
            bottomNavigationBar: Container(
              color: Colors.black,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 72,
                  child: Row(
                    children: List.generate(labels.length, (index) {
                      final selected = selectedIndex == index;

                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icons[index],
                                color: selected
                                    ? Colors.white
                                    : Colors.white54,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                labels[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selected
                                      ? Colors.white
                                      : Colors.white54,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
      surface: dark ? const Color(0xff171717) : Colors.white,
      surfaceContainerHighest:
          dark ? const Color(0xff252525) : const Color(0xfff4f4f6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xff0d0d0d) : const Color(0xffececef),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}