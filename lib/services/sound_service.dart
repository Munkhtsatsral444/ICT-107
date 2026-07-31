import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static const MethodChannel _channel =
      MethodChannel('meeting_mode/audio');

  static bool get isSupported {
    return !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<bool> requestPermission() async {
    if (!isSupported) {
      return false;
    }

    try {
      final permissionGranted =
          await _channel.invokeMethod<bool>(
                'hasPolicyAccess',
              ) ??
              false;

      if (permissionGranted) {
        return true;
      }

      await _channel.invokeMethod<void>(
        'requestPolicyAccess',
      );

      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> setMeetingMode(
    String mode,
  ) async {
    if (!isSupported) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>(
            'setMode',
            {
              'mode':
                  mode == 'vibrate' ? 'vibrate' : 'silent',
            },
          ) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> restoreNormalMode() async {
    if (!isSupported) {
      return false;
    }

    try {
      return await _channel.invokeMethod<bool>(
            'setMode',
            {
              'mode': 'normal',
            },
          ) ??
          false;
    } on PlatformException {
      return false;
    }
  }
}
