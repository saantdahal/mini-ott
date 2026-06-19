plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("com.google.firebase.appdistribution")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.himalayancodeworks.miniott"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    flavorDimensions += "environment"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.himalayancodeworks.miniott"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationId = "com.himalayancodeworks.miniott.dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "DSM TV Dev")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
        create("prod") {
            dimension = "environment"
            applicationId = "com.himalayancodeworks.miniott"
            resValue("string", "app_name", "DSM TV")
            manifestPlaceholders["appIcon"] = "@mipmap/ic_launcher"
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Firebase App Distribution configuration (sample).
// To enable app distribution for the `prod` flavor, add a service account JSON
// or set the `FIREBASE_TOKEN` environment variable. Configure below as needed.
/*
firebaseAppDistribution {
    // Use the appId for the prod client from google-services.json
    appId = "1:71223241590:android:7e27e05413d240f384a857"
    // Authenticate using a service account JSON file or CLI token.
    // serviceCredentialsFile = file("/path/to/service-account.json")
    // Or export FIREBASE_TOKEN to authenticate with the Firebase CLI.
    // artifactType = "AAB" // or "APK"
    // groups = "beta"
    // releaseNotes = "Release via Gradle plugin"
}
*/

// The google-services plugin will process flavor-specific google-services.json files.

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
