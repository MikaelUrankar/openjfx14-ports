--- modules/javafx.web/src/main/native/Source/WTF/wtf/PlatformJSCOnly.cmake.orig	2020-07-17 10:21:33 UTC
+++ modules/javafx.web/src/main/native/Source/WTF/wtf/PlatformJSCOnly.cmake
@@ -82,10 +82,17 @@ elseif (CMAKE_SYSTEM_NAME MATCHES "Linux")
     list(APPEND WTF_SOURCES
         linux/CurrentProcessMemoryStatus.cpp
         linux/MemoryFootprintLinux.cpp
-        linux/MemoryPressureHandlerLinux.cpp
+
+        unix/MemoryPressureHandlerUnix.cpp
     )
     list(APPEND WTF_PUBLIC_HEADERS
         linux/CurrentProcessMemoryStatus.h
+    )
+elseif (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
+    list(APPEND WTF_SOURCES
+        generic/MemoryFootprintGeneric.cpp
+
+        unix/MemoryPressureHandlerUnix.cpp
     )
 else ()
     list(APPEND WTF_SOURCES
