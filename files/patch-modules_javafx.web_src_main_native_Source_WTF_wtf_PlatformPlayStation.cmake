--- modules/javafx.web/src/main/native/Source/WTF/wtf/PlatformPlayStation.cmake.orig	2020-07-17 10:21:33 UTC
+++ modules/javafx.web/src/main/native/Source/WTF/wtf/PlatformPlayStation.cmake
@@ -1,7 +1,6 @@
 list(APPEND WTF_SOURCES
     generic/MainThreadGeneric.cpp
     generic/MemoryFootprintGeneric.cpp
-    generic/MemoryPressureHandlerGeneric.cpp
     generic/RunLoopGeneric.cpp
     generic/WorkQueueGeneric.cpp
 
@@ -15,6 +14,7 @@ list(APPEND WTF_SOURCES
     text/unix/TextBreakIteratorInternalICUUnix.cpp
 
     unix/CPUTimeUnix.cpp
+    unix/MemoryPressureHandlerUnix.cpp
     unix/LanguageUnix.cpp
 )
 
