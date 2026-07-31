package com.example.meeting_mode

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioManager
import android.os.Build

class MeetingAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(
        context: Context,
        intent: Intent
    ) {
        val mode =
            intent.getStringExtra(EXTRA_MODE) ?: "normal"

        val notificationManager =
            context.getSystemService(
                Context.NOTIFICATION_SERVICE
            ) as NotificationManager

        val hasAccess =
            Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                notificationManager
                    .isNotificationPolicyAccessGranted

        if (!hasAccess) {
            return
        }

        val audioManager =
            context.getSystemService(
                Context.AUDIO_SERVICE
            ) as AudioManager

        try {
            when (mode) {
                "silent" -> {
                    notificationManager.setInterruptionFilter(
                        NotificationManager.INTERRUPTION_FILTER_NONE
                    )

                    audioManager.ringerMode =
                        AudioManager.RINGER_MODE_SILENT
                }

                "vibrate" -> {
                    notificationManager.setInterruptionFilter(
                        NotificationManager.INTERRUPTION_FILTER_ALL
                    )

                    audioManager.ringerMode =
                        AudioManager.RINGER_MODE_VIBRATE
                }

                else -> {
                    notificationManager.setInterruptionFilter(
                        NotificationManager.INTERRUPTION_FILTER_ALL
                    )

                    audioManager.ringerMode =
                        AudioManager.RINGER_MODE_NORMAL
                }
            }
        } catch (_: SecurityException) {
            // Permission was not granted.
        }
    }

    companion object {
        const val ACTION_START =
            "com.example.meeting_mode.MEETING_START"

        const val ACTION_END =
            "com.example.meeting_mode.MEETING_END"

        const val EXTRA_MODE = "meeting_mode"
    }
}