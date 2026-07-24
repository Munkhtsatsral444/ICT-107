import 'package:flutter_test/flutter_test.dart';

import '../lib/models/meeting.dart';

void main() {
  test(
    'Meeting converts to JSON and back',
    () {
      final meeting = Meeting(
        id: 1,
        title: 'Team Meeting',
        startTime: DateTime(
          2026,
          8,
          10,
          10,
        ),
        endTime: DateTime(
          2026,
          8,
          10,
          11,
        ),
        mode: 'silent',
      );

      final json = meeting.toJson();
      final restored =
          Meeting.fromJson(json);

      expect(restored.id, meeting.id);
      expect(
        restored.title,
        meeting.title,
      );
      expect(
        restored.startTime,
        meeting.startTime,
      );
      expect(
        restored.endTime,
        meeting.endTime,
      );
      expect(
        restored.mode,
        meeting.mode,
      );
      expect(
        restored.enabled,
        meeting.enabled,
      );
    },
  );

  test(
    'Meeting is active during its scheduled time',
    () {
      final meeting = Meeting(
        id: 2,
        title: 'Class',
        startTime: DateTime(
          2026,
          8,
          10,
          10,
        ),
        endTime: DateTime(
          2026,
          8,
          10,
          11,
        ),
        mode: 'vibrate',
      );

      final currentTime = DateTime(
        2026,
        8,
        10,
        10,
        30,
      );

      expect(
        meeting.isActiveAt(currentTime),
        true,
      );
    },
  );

  test(
    'Disabled meeting is not active',
    () {
      final meeting = Meeting(
        id: 3,
        title: 'Disabled Meeting',
        startTime: DateTime(
          2026,
          8,
          10,
          10,
        ),
        endTime: DateTime(
          2026,
          8,
          10,
          11,
        ),
        mode: 'silent',
        enabled: false,
      );

      final currentTime = DateTime(
        2026,
        8,
        10,
        10,
        30,
      );

      expect(
        meeting.isActiveAt(currentTime),
        false,
      );
    },
  );
}