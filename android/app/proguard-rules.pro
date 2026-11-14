# Flutter & Plugins Proguard Rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep all classes that implement FlutterPlugin
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.embedding.engine.plugins.activity.ActivityAware { *; }

# Printing Plugin
-keep class net.nfet.flutter.printing.** { *; }

# Apple Sign In Plugin
-keep class com.aboutyou.dart_packages.sign_in_with_apple.** { *; }

# Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
