plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
    // Add this line to apply the Google Services plugin
    id 'com.google.gms.google-services'
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace "com.example.whatsapp_sender" // Make sure this matches your package name
    compileSdk 34

    defaultConfig {
        applicationId "com.example.whatsapp_sender" // Make sure this matches your package name
        minSdk 21
        targetSdk 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    // Add the Firebase BOM (Bill of Materials)
    implementation platform('com.google.firebase:firebase-bom:33.1.0')

    // Add the dependency for the Firebase Authentication library
    // (no version number needed because of the BOM)
    implementation 'com.google.firebase:firebase-auth'
}