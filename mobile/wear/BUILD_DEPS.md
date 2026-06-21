// Add these to your mobile/android/app/build.gradle.kts
// under dependencies { } block for WearOS support:

dependencies {
    // Wearable Data Layer API (companion sync)
    implementation("com.google.android.gms:play-services-wearable:18.2.0")

    // gRPC for native WearOS service
    implementation("io.grpc:grpc-okhttp:1.68.0")
    implementation("io.grpc:grpc-protobuf:1.68.0")
    implementation("io.grpc:grpc-stub:1.68.0")

    // Protobuf for gRPC messages
    implementation("com.google.protobuf:protobuf-javalite:3.25.5")
}

// Add to android { } block:
android {
    defaultConfig {
        minSdk = 26  // WearOS 2.0+
        // If targeting WearOS 3.0+, use minSdk = 30
    }

    // For protobuf codegen (generates Java classes from .proto)
    // Apply plugin: id("com.google.protobuf") version "0.9.4"
    // protobuf {
    //     protoc { artifact = "com.google.protobuf:protoc:3.25.5" }
    //     plugins {
    //         create("grpc") {
    //             artifact = "io.grpc:protoc-gen-grpc-java:1.68.0"
    //         }
    //     }
    //     generateProtoTasks {
    //         all().forEach {
    //             it.plugins { create("grpc") }
    //         }
    //     }
    // }
}

// Add to settings.gradle.kts for WearOS support:
// (if building as a separate WearOS module)
// include(":wear")
// project(":wear").projectDir = file("wear/android")
