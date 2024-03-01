# cellscan

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Compilation

`flutter_cell_info` has problems when compiling, replace `android/build.gradle` with the following:

```
//package android

group 'com.sumanrajpathak.flutter_cell_info'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.9.22'
    repositories {
        google()
        jcenter()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        jcenter()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    compileSdkVersion 30

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 16
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlin_version"
    implementation 'com.google.code.gson:gson:2.8.7'

}

```