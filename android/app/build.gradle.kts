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
            // === 核心HTTP和异步库 ===
            // 使用Chaquopy预编译版本,避免任何编译问题
            install("aiohttp==3.10.10")  // Chaquopy官方预编译
            install("aiofiles==24.1.0")   // 纯Python包
            install("httpx==0.27.2")      // 纯Python包
            install("certifi")             // CA证书
            install("idna")                // 国际化域名
            install("httpcore==1.0.6")    // httpx依赖
            install("h11==0.14.0")        // HTTP/1.1协议
            install("sniffio")             // 异步库检测
            
            // === 数据处理和验证 ===
            install("pydantic==1.10.18")  // v1版本纯Python,无需Rust
            install("typing-extensions")  // 类型扩展
            
            // === 日志和输出 ===
            install("loguru==0.7.2")      // 日志库
            install("rich==13.7.1")       // 终端美化
            install("markdown-it-py")     // rich依赖
            install("pygments")            // 语法高亮
            
            // === YAML和配置 ===
            install("pyyaml==6.0.2")      // Chaquopy预编译
            
            // === 工具库 ===
            install("tenacity==9.0.0")    // 重试机制
            install("click==8.1.7")       // CLI基础库
            install("typer==0.12.5")      // CLI框架(依赖click)
            
            // === 可选:如果需要图像处理 ===
            // install("pillow==10.4.0")  // Chaquopy预编译版本
        }
    }
}
