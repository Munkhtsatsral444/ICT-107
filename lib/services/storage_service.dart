import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meeting.dart';

class StorageService {
  static const String settingsKey = 'meeting_mode_settings';
  static const String meetingsKey = 'meeting_mode_meetings';

  static Future<void> saveSettings({
    required bool german,
    required bool darkMode,
  }) async {
    final preferences =
        await SharedPreferences.getInstance();

    final settings = {
      'german': german,
      'darkMode': darkMode,
    };

    await preferences.setString(
      settingsKey,
      jsonEncode(settings),
    );
  }

  static Future<Map<String, bool>> loadSettings() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedSettings =
        preferences.getString(settingsKey);

    if (savedSettings == null) {
      return {
        'german': false,
        'darkMode': false,
      };
    }

    try {
      final decoded =
          jsonDecode(savedSettings) as Map<String, dynamic>;

      return {
        'german': decoded['german'] as bool? ?? false,
        'darkMode':
            decoded['darkMode'] as bool? ?? false,
      };
    } catch (_) {
      return {
        'german': false,
        'darkMode': false,
      };
    }
  }

  static Future<void> saveMeetings(
    List<Meeting> meetings,
  ) async {
    final preferences =
        await SharedPreferences.getInstance();

    final meetingData = meetings
        .map((meeting) => meeting.toJson())
        .toList();

    await preferences.setString(
      meetingsKey,
      jsonEncode(meetingData),
    );
  }

  static Future<List<Meeting>> loadMeetings() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedMeetings =
        preferences.getString(meetingsKey);

    if (savedMeetings == null) {
      return [];
    }

    try {
      final decoded =
          jsonDecode(savedMeetings) as List<dynamic>;

      return decoded
          .map(
            (item) => Meeting.fromJson(
              Map<String, dynamic>.from(
                item as Map,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}