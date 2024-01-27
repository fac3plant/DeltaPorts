diff --git third_party/angle/src/common/platform.h third_party/angle/src/common/platform.h
index 5535a53ad5c..510a916e53d 100644
--- src/3rdparty/chromium/third_party/angle/src/common/platform.h
+++ src/3rdparty/chromium/third_party/angle/src/common/platform.h
@@ -34,8 +34,12 @@
 #    define ANGLE_PLATFORM_FREEBSD 1
 #    define ANGLE_PLATFORM_POSIX 1
 #    define ANGLE_PLATFORM_BSD 1
+#elif defined(__DragonFly__)
+#    define ANGLE_PLATFORM_DRAGONFLY 1
+#    define ANGLE_PLATFORM_POSIX 1
+#    define ANGLE_PLATFORM_BSD 1
 #elif defined(__NetBSD__) ||              \
-    defined(__DragonFly__) || defined(__sun) || defined(__GLIBC__) || defined(__GNU__) || \
+    defined(__sun) || defined(__GLIBC__) || defined(__GNU__) || \
     defined(__QNX__) || defined(__Fuchsia__) || defined(__HAIKU__)
 #    define ANGLE_PLATFORM_POSIX 1
 #else
