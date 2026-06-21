# ProGuard rules for JARVIS AI Flutter App
# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Dart/Flutter JNI
-keep class io.flutter.embedding.engine.** { *; }

# Keep HTTP client classes
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**

# Keep app classes
-keep class com.jarvis.jarvis_ai.** { *; }

# Keep Google Fonts (loaded from network)
-keepattributes *Annotation*
-keepattributes Signature
