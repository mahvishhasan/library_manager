import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin **must** be last.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
        val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(keystorePropertiesFile.inputStream())
    }

    signingConfigs {
        create("release") {
storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            enableV1Signing = true
            enableV2Signing = true
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    namespace  = "com.mishi.library_manager"          // <- the package name seen by Android
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"                      // keep just **one** declaration

    defaultConfig {
        applicationId = "com.mishi.library_manager"   // must match namespace
        minSdk        = 23
        targetSdk     = flutter.targetSdkVersion
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    }



flutter {   // do NOT touch
    source = "../.."
}
