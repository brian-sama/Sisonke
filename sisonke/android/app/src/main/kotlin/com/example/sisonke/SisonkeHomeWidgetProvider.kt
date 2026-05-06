package com.example.sisonke

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class SisonkeHomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            val moodKey = widgetData.getString("mood", "breeze")
            val companionText = widgetData.getString(
                "companion_text",
                "Take a slow, comforting breath. I am nearby."
            )
            val gratitudeStars = widgetData.getInt("gratitude_stars", 0).coerceAtLeast(0)

            views.setTextViewText(R.id.companion_text, companionText)
            views.setTextViewText(R.id.gratitude_stats, "$gratitudeStars gratitude stars")

            val moodLabel = when (moodKey) {
                "sunlight" -> "Bright"
                "breeze" -> "Calm"
                "rain" -> "Gentle"
                "cloud" -> "Pause"
                "storm" -> "Breathe"
                else -> "Calm"
            }
            views.setTextViewText(R.id.mood_icon, moodLabel)

            val exitIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_APP_CALCULATOR)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            val safeIntent = if (exitIntent.resolveActivity(context.packageManager) != null) {
                exitIntent
            } else {
                Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
            }

            val pendingExitIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                safeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_quick_exit, pendingExitIntent)

            val pendingAppIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            views.setOnClickPendingIntent(R.id.widget_root, pendingAppIntent)
            views.setOnClickPendingIntent(R.id.widget_title, pendingAppIntent)
            views.setOnClickPendingIntent(R.id.companion_text, pendingAppIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
