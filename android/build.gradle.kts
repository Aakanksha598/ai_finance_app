plugins {
    // Google Services plugin (needed for Firebase)
    id("com.google.gms.google-services") version "4.4.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use a shared build directory at the project root
val sharedBuildDir = rootDir.resolve("build")
rootProject.buildDir = sharedBuildDir

subprojects {
    buildDir = File(sharedBuildDir, name)
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

