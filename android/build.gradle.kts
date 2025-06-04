allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: move build output outside submodules
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    layout.buildDirectory.set(newBuildDir.dir(name))
}

// Force all Android library modules to use compileSdk 35
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                compileSdk = 35
            }
        }
    }
}

// Ensure proper dependency evaluation order
subprojects {
    evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
