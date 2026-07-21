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

// Inject namespace into plugins that are missing it (Fix for AGP 8.0+)
subprojects {
    val subproject = this
    subproject.plugins.withId("com.android.library") {
        val android = subproject.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android?.namespace == null) {
            android?.namespace = "com.jitsi.meet." + subproject.name.replace("-", "_")
        }
    }
    subproject.plugins.withId("com.android.application") {
        val android = subproject.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android?.namespace == null) {
            android?.namespace = "com.jitsi.meet." + subproject.name.replace("-", "_")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
