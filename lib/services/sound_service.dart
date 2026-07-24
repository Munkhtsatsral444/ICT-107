import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class SoundService {
  static bool get isSupported {
    return !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<bool> requestPermission() async {
    if (!isSupported) {
      return false;
    }

    try {
      final bool? permissionGranted =
          await PermissionHandler.permissionsGranted;

      if (permissionGranted == true) {
        return true;
      }

      await PermissionHandler.openDoNotDisturbSetting();

      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setMeetingMode(
    String mode,
  ) async {
    if (!isSupported) {
      return;
    }

    try {
      final bool? permissionGranted =
          await PermissionHandler.permissionsGranted;

      if (permissionGranted != true) {
        return;
      }

      await SoundMode.setSoundMode(
        RingerModeStatus.silent,
      );
    } on PlatformException {
    } catch (_) {
    }
  }

  static Future<void> restoreNormalMode() async {
    if (!isSupported) {
      return;
    }

    try {
      final bool? permissionGranted =
          await PermissionHandler.permissionsGranted;

      if (permissionGranted == true) {
        await SoundMode.setSoundMode(
          RingerModeStatus.normal,
        );
      }
    } on PlatformException {
    } catch (_) {
    }
  }
}