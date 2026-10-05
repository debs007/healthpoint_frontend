##---------------Begin: proguard configuration for Gson (Needed for flutter_local_notifications) ----------
# Gson uses generic type information stored in a class file when working with
# fields. Proguard/R8 can strip that generic signature metadata during
# shrinking, which is exactly what this crash is - the fix keeps the
# signature information without stopping R8 from still obfuscating/shrinking
# the class otherwise. Needed specifically because the boot receiver added
# earlier (ScheduledNotificationBootReceiver) uses this at runtime to restore
# scheduled reminders after a reboot.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
##---------------End: proguard configuration for Gson (Needed for flutter_local_notifications) ----------
