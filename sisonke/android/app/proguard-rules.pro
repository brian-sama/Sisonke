# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Deferred Components & Google Play Core optional classes
-dontwarn com.google.android.play.core.**

# Isar database
-keep class dev.isar.** { *; }
-keep class * extends dev.isar.IsarCollection { *; }

# Sentry crash reporting
-keepattributes LineNumberTable,SourceFile
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# HomeWidget
-keep class es.antonborri.home_widget.** { *; }
-keep class com.example.sisonke.SisonkeHomeWidgetProvider { *; }
