# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Kotlin specific
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Image library (for image processing)
-keep class com.image.** { *; }

# For plugins
-keep class io.flutter.plugins.** { *; }

# File picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Gallery saver
-keep class carnegietechnologies.gallery_saver.** { *; }

# Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Keep your custom model classes
-keep class com.example.logo_matic.models.** { *; }

# For native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep the R class and its fields
-keep class **.R
-keep class **.R$* {
    <fields>;
}

# Android support libraries
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-keep class com.google.android.material.** { *; }
-dontwarn com.google.android.material.**
-dontnote com.google.android.material.** 