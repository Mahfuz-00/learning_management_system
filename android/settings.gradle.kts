pluginManagement {
    val flutterSdkPath = run {
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

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

// Correct Kotlin DSL syntax for subprojects configuration
gradle.projectsLoaded {
    rootProject.subprojects {
        val subProject = this
        subProject.afterEvaluate {
            val extension = subProject.extensions.findByName("android")
            if (extension != null) {
                try {
                    // Force compileSdk and targetSdk to 37 for any Android subproject
                    val compileSdkMethod = extension.javaClass.methods.find { it.name == "setCompileSdk" }
                    compileSdkMethod?.invoke(extension, 37)

                    val targetSdkMethod = extension.javaClass.methods.find { it.name == "setTargetSdk" }
                    targetSdkMethod?.invoke(extension, 37)
                } catch (e: Exception) {
                    // Fallback property assignment if available
                    try {
                        val compileSdkField = extension.javaClass.methods.find { it.name == "getCompileSdk" }
                        // If it's below 34, try setting via property
                    } catch (_: Exception) {}
                }
            }
        }
    }
}

include(":app")