import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/meeting.dart';

class AlarmService {
  static const MethodChannel channel =
      MethodChannel('meeting_mode/audio');

  static bool get isSupported {
    return !kIsWeb &&
        defaultTargetPlatform ==
            TargetPlatform.android;
  }

  static Future<void> scheduleMeeting(
    Meeting meeting,
  ) async {
    if (!isSupported || !meeting.enabled) {
      return;
    }

    try {
      await channel.invokeMethod(
        'scheduleMeeting',
        {
          'id': meeting.id,
          'startMillis':
              meeting.startTime.millisecondsSinceEpoch,
          'endMillis':
              meeting.endTime.millisecondsSinceEpoch,
          'mode': 'silent',
        },
      );
    } on PlatformException {
      // Ignore Android alarm errors.
    }
  }

  static Future<void> cancelMeeting(
    int meetingId,
  ) async {
    if (!isSupported) {
      return;
    }

    try {
      await channel.invokeMethod(
        'cancelMeeting',
        {
          'id': meetingId,
        },
      );
    } on PlatformException {
      // Ignore Android alarm errors.
    }
  }
}
