import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

if (System.getProperty("os.name").lowercase().contains("win")) {
    val customBuildDir = File("C:/temp/exam_tracker_build")
    rootProject.layout.buildDirectory.set(customBuildDir)
    subprojects {
        val subDir = File(customBuildDir, project.name)
        project.layout.buildDirectory.set(subDir)
    }
} else {
    val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
    rootProject.layout.buildDirectory.value(newBuildDir)
    subprojects {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
