allprojects {
    repositories {
        google()
        mavenCentral()
    }

    configurations.all {
        resolutionStrategy {
            force("androidx.browser:browser:1.8.0")
            force("androidx.core:core:1.15.0")
            force("androidx.core:core-ktx:1.15.0")
            force("androidx.glance:glance:1.1.1")
            force("androidx.glance:glance-appwidget:1.1.1")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("kotlin-android") {
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                languageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_8)
                apiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_1_8)
            }
        }
    }
}



subprojects {
    val setupAndroidProject = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android")
            try {
                // Set namespace if missing
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                    setNamespaceMethod.invoke(android, "com.example.${project.name.replace("-", "_")}")
                }
                
                // Force compileSdk to 36 for all plugins
                val setCompileSdkVersion = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType ?: Int::class.java)
                setCompileSdkVersion.invoke(android, 36)
            } catch (e: Exception) {
                // Fallback for different Gradle versions
                try {
                    val setCompileSdk = android.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType ?: Int::class.java)
                    setCompileSdk.invoke(android, 36)
                } catch (e2: Exception) {}
            }
        }
    }

    if (project.state.executed) {
        setupAndroidProject()
    } else {
        project.afterEvaluate {
            setupAndroidProject()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
