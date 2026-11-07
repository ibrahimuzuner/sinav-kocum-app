import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val customBuildDir = File("C:/temp/exam_tracker_build")
rootProject.layout.buildDirectory.set(customBuildDir)

subprojects {
    val subDir = File(customBuildDir, project.name)
    project.layout.buildDirectory.set(subDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
