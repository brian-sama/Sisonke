pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Android SDK 37 installs as "android-37.0" but AGP expects "android-37".
// Fix this before any project is configured.
run {
    val localProps = java.util.Properties()
    val localPropsFile = file("local.properties")
    if (localPropsFile.exists()) localPropsFile.inputStream().use { localProps.load(it) }
    val sdkDir = localProps.getProperty("sdk.dir")
        ?: System.getenv("ANDROID_SDK_ROOT")
        ?: System.getenv("ANDROID_HOME")
    if (sdkDir != null) {
        val src = file("$sdkDir/platforms/android-37.0")
        val dst = file("$sdkDir/platforms/android-37")
        if (src.exists()) {
            if (!dst.exists()) src.copyRecursively(dst)
            file("$dst/source.properties").let { f ->
                if (f.exists()) f.writeText(f.readText().replace("AndroidVersion.ApiLevel=37.0", "AndroidVersion.ApiLevel=37"))
            }
            file("$dst/package.xml").let { f ->
                if (f.exists()) f.writeText(f.readText().replace("platforms;android-37.0", "platforms;android-37"))
            }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
