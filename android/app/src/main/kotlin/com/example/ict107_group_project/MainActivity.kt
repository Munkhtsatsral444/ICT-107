package com.example.meeting_mode

import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "meeting_mode/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPolicyAccess" -> {
                    result.success(hasPolicyAccess())
                }

                "requestPolicyAccess" -> {
                    openPolicyAccessSettings()
                    result.success(true)
                }

                "setMode" -> {
                    val mode = call.argument<String>("mode") ?: "normal"
                    result.success(applyRingerMode(mode))
                }

                "scheduleMeeting" -> {
                    val id = call.argument<Int>("id")
                    val startMillis = call.argument<Number>("startMillis")?.toLong()
                    val endMillis = call.argument<Number>("endMillis")?.toLong()
                    val mode = call.argument<String>("mode") ?: "vibrate"

                    if (id == null || startMillis == null || endMillis == null) {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Meeting id, start time and end time are required.",
                            null
                        )
                    } else {
                        scheduleMeeting(id, startMillis, endMillis, mode)
                        result.success(true)
                    }
                }

                "cancelMeeting" -> {
                    val id = call.argument<Int>("id")
                    if (id == null) {
                        result.error("INVALID_ID", "Meeting id is required.", null)
                    } else {
                        cancelMeeting(id)
                        result.success(true)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun hasPolicyAccess(): Boolean {
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            notificationManager.isNotificationPolicyAccessGranted
    }

    private fun openPolicyAccessSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun applyRingerMode(mode: String): Boolean {
        if (!hasPolicyAccess()) {
            return false
        }

        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.ringerMode = when (mode) {
            "silent" -> AudioManager.RINGER_MODE_SILENT
            "vibrate" -> AudioManager.RINGER_MODE_VIBRATE
            else -> AudioManager.RINGER_MODE_NORMAL
        }
        return true
    }

    private fun scheduleMeeting(
        id: Int,
        startMillis: Long,
        endMillis: Long,
        mode: String
    ) {
        cancelMeeting(id)

        val now = System.currentTimeMillis()
        if (endMillis <= now) {
            return
        }

        if (startMillis <= now) {
            applyRingerMode(mode)
        } else {
            scheduleAlarm(
                requestCode = startRequestCode(id),
                triggerAtMillis = startMillis,
                action = MeetingAlarmReceiver.ACTION_START,
                mode = mode
            )
        }

        scheduleAlarm(
            requestCode = endRequestCode(id),
            triggerAtMillis = endMillis,
            action = MeetingAlarmReceiver.ACTION_END,
            mode = "normal"
        )
    }

    private fun scheduleAlarm(
        requestCode: Int,
        triggerAtMillis: Long,
        action: String,
        mode: String
    ) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = alarmPendingIntent(
            requestCode = requestCode,
            action = action,
            mode = mode,
            flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        ) ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        } else {
            alarmManager.set(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
        }
    }

    private fun cancelMeeting(id: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val startIntent = alarmPendingIntent(
            requestCode = startRequestCode(id),
            action = MeetingAlarmReceiver.ACTION_START,
            mode = "vibrate",
            flags = PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )
        val endIntent = alarmPendingIntent(
            requestCode = endRequestCode(id),
            action = MeetingAlarmReceiver.ACTION_END,
            mode = "normal",
            flags = PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        )

        if (startIntent != null) {
            alarmManager.cancel(startIntent)
            startIntent.cancel()
        }
        if (endIntent != null) {
            alarmManager.cancel(endIntent)
            endIntent.cancel()
        }
    }

    private fun alarmPendingIntent(
        requestCode: Int,
        action: String,
        mode: String,
        flags: Int
    ): PendingIntent? {
        val intent = Intent(this, MeetingAlarmReceiver::class.java).apply {
            this.action = action
            putExtra(MeetingAlarmReceiver.EXTRA_MODE, mode)
        }

        return PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            flags
        )
    }

    private fun startRequestCode(id: Int): Int = id * 2

    private fun endRequestCode(id: Int): Int = id * 2 + 1
}
