# ─── Agora RTC Engine ────────────────────────────────────────
-keep class io.agora.** { *; }
-dontwarn io.agora.**

# ─── Flutter ─────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# ─── Keep all model classes ──────────────────────────────────
-keep class com.livehub.** { *; }

# ─── GetX ────────────────────────────────────────────────────
-keep class com.google.** { *; }
-dontwarn com.google.**

# ─── Kotlin ──────────────────────────────────────────────────
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings { <fields>; }

# ─── Multidex ────────────────────────────────────────────────
-keep class androidx.multidex.** { *; }

# ─── Remove debug logs in release ────────────────────────────
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
