import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.chaquo.python")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 读取签名配置
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.kimi.kfc.kfc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kimi.kfc.kfc"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24  // Chaquopy requires minSdk 21+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Chaquopy requires ndk.abiFilters to be set
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

chaquopy {
    defaultConfig {
        version = "3.13"
        buildPython("python3")
        pip {
            // kimi-cli 的所有依赖包
            install("agent-client-protocol==0.6.3")
            install("aiofiles==25.1.0")
            install("aiohttp==3.13.2")
            install("typer==0.20.0")
            install("kosong==0.25.0")
            install("loguru==0.7.3")
            install("patch-ng==1.19.0")
            install("prompt-toolkit==3.0.52")
            install("pillow==12.0.0")
            install("pyyaml==6.0.3")
            install("rich==14.2.0")
            install("ripgrepy==2.2.0")
            install("streamingjson==0.0.5")
            install("trafilatura==2.0.0")
            install("tenacity==9.1.2")
            install("fastmcp==2.12.5")
            install("pydantic==2.12.4")
            install("httpx[socks]==0.28.1")
        }
    }
}
