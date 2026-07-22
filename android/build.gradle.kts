allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Fix for AGP 8.0+ Namespace issues in plugins
subprojects {
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                // If it's the jitsi plugin, use its expected package name
                if (project.name.contains("jitsi_meet")) {
                    namespace = "org.jitsi.jitsi_meet_flutter_sdk"
                } else {
                    namespace = "com.lms.touch_and_solve." + project.name.replace("-", "_")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
