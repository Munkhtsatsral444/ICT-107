import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as timezone_data;

import 'models/meeting.dart';
import 'pages/home_page.dart';
import 'pages/schedule_page.dart';
import 'pages/settings_page.dart';
import 'pages/world_clock_page.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  timezone_data.initializeTimeZones();

  await NotificationService.initialise();

  runApp(const MeetingModeApp());
}

class MeetingModeApp extends StatefulWidget {
  const MeetingModeApp({
    super.key,
  });

  @override
  State<MeetingModeApp> createState() {
    return _MeetingModeAppState();
  }
}

class _MeetingModeAppState
    extends State<MeetingModeApp>
    with WidgetsBindingObserver {
  int selectedIndex = 0;

  bool german = false;
  bool darkMode = false;
  bool loading = true;

  List<Meeting> meetings = [];

  Timer? meetingTimer;
  int? activeMeetingId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    loadSavedData();

    meetingTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) {
        checkMeetingMode();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      checkMeetingMode();
    }
  }

  @override
  void dispose() {
    meetingTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> loadSavedData() async {
    final savedSettings =
        await StorageService.loadSettings();

    final savedMeetings =
        await StorageService.loadMeetings();

    savedMeetings.sort(
      (first, second) {
        return first.startTime.compareTo(
          second.startTime,
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      german =
          savedSettings['german'] ?? false;

      darkMode =
          savedSettings['darkMode'] ?? false;

      meetings = savedMeetings;

      loading = false;
    });

    await NotificationService.rescheduleAll(
      meetings: meetings,
      german: german,
    );

    await checkMeetingMode();
  }

  Future<void> changeLanguage(
    bool value,
  ) async {
    setState(() {
      german = value;
    });

    await saveSettings();

    await NotificationService.rescheduleAll(
      meetings: meetings,
      german: german,
    );
  }

  Future<void> changeTheme(
    bool value,
  ) async {
    setState(() {
      darkMode = value;
    });

    await saveSettings();
  }

  Future<void> saveSettings() async {
    await StorageService.saveSettings(
      german: german,
      darkMode: darkMode,
    );
  }

  Future<void> addMeeting(
    Meeting meeting,
  ) async {
    setState(() {
      meetings = [
        ...meetings,
        meeting,
      ];

      meetings.sort(
        (first, second) {
          return first.startTime.compareTo(
            second.startTime,
          );
        },
      );
    });

    await StorageService.saveMeetings(
      meetings,
    );

    await NotificationService.requestPermission();

    await NotificationService.scheduleMeeting(
      meeting: meeting,
      german: german,
    );

    await checkMeetingMode();
  }

  Future<void> deleteMeeting(
    Meeting meeting,
  ) async {
    setState(() {
      meetings = meetings.where(
        (item) {
          return item.id != meeting.id;
        },
      ).toList();
    });

    await StorageService.saveMeetings(
      meetings,
    );

    await NotificationService.cancelMeeting(
      meeting.id,
    );

    if (activeMeetingId == meeting.id) {
      activeMeetingId = null;

      await SoundService.restoreNormalMode();
    }

    await checkMeetingMode();
  }

  Future<void> toggleMeeting(
    Meeting meeting,
    bool enabled,
  ) async {
    final updatedMeeting =
        meeting.copyWith(
      enabled: enabled,
    );

    setState(() {
      meetings = meetings.map(
        (item) {
          if (item.id == meeting.id) {
            return updatedMeeting;
          }

          return item;
        },
      ).toList();
    });

    await StorageService.saveMeetings(
      meetings,
    );

    await NotificationService.cancelMeeting(
      meeting.id,
    );

    if (enabled) {
      await NotificationService.scheduleMeeting(
        meeting: updatedMeeting,
        german: german,
      );
    }

    if (!enabled &&
        activeMeetingId == meeting.id) {
      activeMeetingId = null;

      await SoundService.restoreNormalMode();
    }

    await checkMeetingMode();
  }

  Future<void> checkMeetingMode() async {
    final currentTime = DateTime.now();

    Meeting? activeMeeting;

    for (final meeting in meetings) {
      if (meeting.isActiveAt(currentTime)) {
        activeMeeting = meeting;
        break;
      }
    }

    if (activeMeeting != null) {
      if (activeMeetingId !=
          activeMeeting.id) {
        activeMeetingId =
            activeMeeting.id;

        await SoundService.setMeetingMode(
          activeMeeting.mode,
        );
      }

      return;
    }

    if (activeMeetingId != null) {
      activeMeetingId = null;

      await SoundService.restoreNormalMode();
    }
  }

  Meeting? get nextMeeting {
    final currentTime = DateTime.now();

    final availableMeetings =
        meetings.where(
      (meeting) {
        return meeting.enabled &&
            meeting.endTime.isAfter(
              currentTime,
            );
      },
    ).toList();

    availableMeetings.sort(
      (first, second) {
        return first.startTime.compareTo(
          second.startTime,
        );
      },
    );

    if (availableMeetings.isEmpty) {
      return null;
    }

    return availableMeetings.first;
  }

  Future<bool> enableNotifications() async {
    final permissionGranted =
        await NotificationService.requestPermission();

    if (!permissionGranted) {
      return false;
    }

    return NotificationService.showTestNotification(
      german: german,
    );
  }

  Future<bool> enableMeetingMode() async {
    return SoundService.requestPermission();
  }

  String translate(
    String english,
    String deutsch,
  ) {
    return german ? deutsch : english;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(
        german ? 'de' : 'en',
      ),
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations
            .delegate,
        GlobalWidgetsLocalizations
            .delegate,
        GlobalCupertinoLocalizations
            .delegate,
      ],
      themeMode: darkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      theme: createTheme(
        Brightness.light,
      ),
      darkTheme: createTheme(
        Brightness.dark,
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          final desktop =
              constraints.maxWidth >= 850;

          if (loading) {
            return const Scaffold(
              body: Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          final pages = [
            HomePage(
              german: german,
              nextMeeting: nextMeeting,
              meetings: meetings,
            ),
            SchedulePage(
              german: german,
              meetings: meetings,
              onAddMeeting: addMeeting,
              onDeleteMeeting:
                  deleteMeeting,
              onToggleMeeting:
                  toggleMeeting,
            ),
            WorldClockPage(
              german: german,
            ),
            SettingsPage(
              german: german,
              darkMode: darkMode,
              notificationSupported:
                  NotificationService
                      .isSupported,
              meetingModeSupported:
                  SoundService.isSupported,
              onLanguageChanged:
                  changeLanguage,
              onThemeChanged:
                  changeTheme,
              onNotificationPressed:
                  enableNotifications,
              onMeetingModePressed:
                  enableMeetingMode,
            ),
          ];

          final labels = [
            translate(
              'Home',
              'Startseite',
            ),
            translate(
              'Add Meeting',
              'Meeting hinzufügen',
            ),
            translate(
              'World Clock',
              'Weltuhr',
            ),
            translate(
              'Settings',
              'Einstellungen',
            ),
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
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      DesktopNavigation(
                        icons: icons,
                        labels: labels,
                        selectedIndex:
                            selectedIndex,
                        onSelected:
                            (index) {
                          setState(() {
                            selectedIndex =
                                index;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index:
                              selectedIndex,
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
            bottomNavigationBar:
                MobileNavigation(
              icons: icons,
              labels: labels,
              selectedIndex:
                  selectedIndex,
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
}

ThemeData createTheme(
  Brightness brightness,
) {
  final dark =
      brightness == Brightness.dark;

  final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF808080),
  brightness: brightness,
).copyWith(
  primary: dark ? Colors.white : Colors.black,
  onPrimary: dark ? Colors.black : Colors.white,

  secondary: dark ? Colors.white : Colors.black,
  onSecondary: dark ? Colors.black : Colors.white,

  surface: dark
      ? const Color(0xFF151515)
      : Colors.white,

  onSurface: dark
      ? Colors.white
      : Colors.black,

  surfaceContainerHighest: dark
      ? const Color(0xFF242424)
      : const Color(0xFFF3F3F3),

  onSurfaceVariant: dark
      ? Colors.white70
      : Colors.black54,

  outline: dark
      ? Colors.white30
      : Colors.black26,

  outlineVariant: dark
      ? Colors.white12
      : Colors.black12,

  surfaceTint: Colors.transparent,
);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    iconTheme: IconThemeData(
      color: dark ? Colors.white : Colors.black,
    ),
    scaffoldBackgroundColor: dark
        ? const Color(0xff101010)
        : Colors.white,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color:
          colorScheme.surfaceContainerHighest,
      surfaceTintColor:
          Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme:
        InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.onSurface,
          width: 1.2,
        ),
      ),
    ),
    outlinedButtonTheme:
        OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor:
            colorScheme.onSurface,
        side: BorderSide(
          color: colorScheme.outline,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    ),
    filledButtonTheme:
        FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return dark
                ? Colors.white
                : Colors.black;
          }

          return dark
              ? Colors.white24
              : Colors.black26;
        },
      ),
      thumbColor:
          WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(
            WidgetState.selected,
          )) {
            return dark
                ? Colors.black
                : Colors.white;
          }

          return Colors.white;
        },
      ),
      trackOutlineColor:
          const WidgetStatePropertyAll(
        Colors.transparent,
      ),
    ),
  );
}

class DesktopNavigation
    extends StatelessWidget {
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
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.20,
            ),
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(6, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 34),
          ...List.generate(
            icons.length,
            (index) {
              final selected =
                  selectedIndex == index;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 24,
                ),
                child: Tooltip(
                  message: labels[index],
                  child: InkWell(
                    onTap: () {
                      onSelected(index);
                    },
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 180,
                      ),
                      width: 42,
                      height: 42,
                      decoration:
                          BoxDecoration(
                        color: selected
                            ? Colors.white
                                .withValues(
                                alpha: 0.12,
                              )
                            : Colors
                                .transparent,
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
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
            },
          ),
        ],
      ),
    );
  }
}

class MobileNavigation
    extends StatelessWidget {
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
            children: List.generate(
              icons.length,
              (index) {
                final selected =
                    selectedIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      onSelected(index);
                    },
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          icons[index],
                          size: 20,
                          color: selected
                              ? Colors.white
                              : Colors
                                  .white60,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          labels[index],
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected
                                ? Colors
                                    .white
                                : Colors
                                    .white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}