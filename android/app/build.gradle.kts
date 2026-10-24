import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "br.app.aurora.aurora"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Exigido pelo flutter_local_notifications (notificações agendadas).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "br.app.aurora.aurora"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Chave de lançamento: fica fora do projeto (C:\src\chaves) e a senha em
    // android/key.properties, que não vai para o Git. Sem o arquivo, o build
    // release usa a chave de debug (só para testes).
    val chave = Properties().apply {
        val arquivo = rootProject.file("key.properties")
        if (arquivo.exists()) arquivo.inputStream().use { load(it) }
    }
    signingConfigs {
        if (chave.getProperty("storeFile") != null) {
            create("lancamento") {
                storeFile = file(chave.getProperty("storeFile"))
                storePassword = chave.getProperty("storePassword")
                keyAlias = chave.getProperty("keyAlias")
                keyPassword = chave.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("lancamento") ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // FileProvider: entrega o APK baixado ao instalador do Android.
    implementation("androidx.core:core:1.13.1")
    // Tema AppCompat da abertura: exigido pelo local_auth no Android 8 e anteriores.
    implementation("androidx.appcompat:appcompat:1.7.0")
}
