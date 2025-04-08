plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tesst1"
    compileSdk = 35// ✅ Corrected
    ndkVersion = "29.0.13113456" // 👈 AJOUT ICI
    defaultConfig {
        applicationId = "com.example.tesst1"
        minSdk = 24// ✅ Corrected
        targetSdk = 35 // ✅ Set target SDK version manually
        versionCode = 1 // ✅ Set versionCode manually
        versionName = "1.0.0" // ✅ Set versionName manually
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
