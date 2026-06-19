import java.io.File

allprojects {
    repositories {
        google()
        mavenCentral()
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

fun packageNameFromManifest(manifestFile: File): String? {
    if (!manifestFile.exists()) return null
    val match = Regex("""package\s*=\s*\"([^\"]+)\"""").find(manifestFile.readText())
    return match?.groupValues?.getOrNull(1)
}

subprojects {
    plugins.withId("com.android.library") {
        val androidExtension = extensions.findByName("android") ?: return@withId
        val getNamespace = androidExtension.javaClass.methods.firstOrNull {
            it.name == "getNamespace" && it.parameterCount == 0
        }
        val setNamespace = androidExtension.javaClass.methods.firstOrNull {
            it.name == "setNamespace" && it.parameterCount == 1
        }

        if (setNamespace != null) {
            val currentNamespace = getNamespace?.invoke(androidExtension) as? String
            if (currentNamespace.isNullOrBlank()) {
                val manifestNamespace = packageNameFromManifest(project.file("src/main/AndroidManifest.xml"))
                val fallbackNamespace = manifestNamespace ?: project.group.toString()
                if (fallbackNamespace.isNotBlank() && fallbackNamespace != "unspecified") {
                    setNamespace.invoke(androidExtension, fallbackNamespace)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
