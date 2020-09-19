# $FreeBSD$

# The following steps are needed for databases/sqldeveloper/scenebuilder:
# https://wiki.openjdk.java.net/display/OpenJFX/Building+OpenJFX
# Integration with OpenJDK
# With the module system in JDK 9 and later, it is not possible to easily overlay
# an OpenJFX build over an existing JDK as was possible with JDK 8. It is possible
# to build an OpenJDK that included the updated OpenJFX modules.
# To create an integrated OpenJDK with OpenJFX requires two builds:
#     OpenJFX for JDK
#     OpenJDK, with a configure reference that includes your OpenJFX build.
# Build OpenJFX first.
# Configure the JDK with the following addition:
#      --with-import-modules=_path_to_jfx-dev_/rt/build/modular-sdk
# Then build the JDK as normal.
# ie: make -C /usr/ports/java/openjfx14
# patch java/openjdk1X with --with-import-modules=/usr/ports/java/openjfx14/work/jfx-14.0.2.1-1/build/modular-sdk
# make -C /usr/ports/java/openjdk1X

PORTNAME=	openjfx
DISTVERSION=	14.0.2.1+1
CATEGORIES=	java x11-toolkits devel
PKGNAMESUFFIX=	14

MASTER_SITES=	https://repo.maven.apache.org/maven2/org/apache/lucene/lucene-core/7.7.1/:core \
		https://repo.maven.apache.org/maven2/org/apache/lucene/lucene-grouping/7.7.1/:grouping \
		https://repo.maven.apache.org/maven2/org/apache/lucene/lucene-queries/7.7.1/:queries \
		https://repo.maven.apache.org/maven2/org/apache/lucene/lucene-queryparser/7.7.1/:queryparser \
		https://repo.maven.apache.org/maven2/org/apache/lucene/lucene-sandbox/7.7.1/:sandbox \
		https://repo1.maven.org/maven2/org/antlr/antlr4/4.7.2/:antlr
DISTFILES=	lucene-core-7.7.1.jar:core \
		lucene-grouping-7.7.1.jar:grouping \
		lucene-queries-7.7.1.jar:queries \
		lucene-queryparser-7.7.1.jar:queryparser \
		lucene-sandbox-7.7.1.jar:sandbox \
		antlr4-4.7.2-complete.jar:antlr

MAINTAINER=	mikael@FreeBSD.org
COMMENT=	JavaFX SDK overlay for OpenJDK 11

LICENSE=	GPLv2
LICENSE_FILE=	${WRKSRC}/LICENSE

ONLY_FOR_ARCHS=	aarch64 amd64 powerpc64

BUILD_DEPENDS=	zip:archivers/zip \
		apache-ant>0:devel/apache-ant \
		gradle62>=6.2:devel/gradle62 \
		${JAVALIBDIR}/junit.jar:java/junit
LIB_DEPENDS=	libasound.so:audio/alsa-lib \
		libfontconfig.so:x11-fonts/fontconfig \
		libfreetype.so:print/freetype2

USES=		gettext-runtime gl gnome jpeg localbase:ldflags ninja pkgconfig \
		sqlite xorg

USE_GITHUB=	yes
GH_ACCOUNT=	openjdk
GH_PROJECT=	jfx
USE_GL=		gl
USE_GNOME=	atk cairo gdkpixbuf2 glib20 gtk20 gtk30 pango
USE_JAVA=	yes
JAVA_VERSION=	11
USE_LDCONFIG=	yes
USE_XORG=	x11 xtst xxf86vm

CFLAGS+=	-Wno-unused-command-line-argument

PLIST_SUB=	INSTALLDIR=${INSTALLDIR}

INSTALLDIR=     ${PREFIX}/${PKGBASE}

OPTIONS_DEFINE=	MEDIA SWT TEST WEBKIT
OPTIONS_DEFAULT=	MEDIA WEBKIT
OPTIONS_SUB=	yes

MEDIA_DESC=	Media module
SWT_DESC=	SWT support

MEDIA_LIB_DEPENDS=	libavcodec.so:multimedia/ffmpeg \
			libsndio.so:audio/sndio
MEDIA_USES=	gmake
MEDIA_VARS=	COMPILE_MEDIA=true

SWT_BUILD_DEPENDS=	swt>0:x11-toolkits/swt
SWT_RUN_DEPENDS=	swt>0:x11-toolkits/swt
SWT_VARS=	COMPILE_SWT=true

TEST_USES=	display:test
TEST_VARS=	AWT_TEST=true FULL_TEST=true

# Gradle calls CMake during the build
WEBKIT_IMPLIES=	MEDIA
WEBKIT_BUILD_DEPENDS=	cmake:devel/cmake
WEBKIT_LIB_DEPENDS=	libicui18n.so:devel/icu
WEBKIT_USES=	bison gmake gperf perl5 python:3.5+,build
WEBKIT_USE=	GNOME=libxslt,libxml2 \
		PERL5=build \
		RUBY=yes \
		XORG=xcomposite,xdamage,xfixes,xrender,xt
WEBKIT_VARS=	RUBY_NO_RUN_DEPENDS=yes COMPILE_WEBKIT=true

# Move Gradle's home below ${WRKDIR} instead of using ${HOME}/.gradle
_GRADLE_ENV=	CC=${WRKDIR}/bin/ccwrapper \
		CXX=${WRKDIR}/bin/cxxwrapper \
		GRADLE_USER_HOME=${WRKDIR}/gradle-home \
		JAVA_VERSION=${JAVA_VERSION}
_GRADLE_RUN=	${SETENV} ${_GRADLE_ENV} gradle62 --no-daemon

post-extract:
	${MKDIR} ${WRKDIR}/jars
.for f in core grouping queries queryparser sandbox
	${CP} ${DISTDIR}/lucene-${f}-7.7.1.jar ${WRKDIR}/jars
.endfor
	${CP} ${DISTDIR}/antlr4-4.7.2-complete.jar ${WRKDIR}/jars

# The BSD Makefiles for GStreamer-lite and Jfxmedia are based on the
# Linux versions.  Prepare the tree, so that we only see the changes
# from Linux's Makefile in our own patches.
pre-patch:
	@${CP} -r ${WRKSRC}/modules/javafx.media/src/main/native/jfxmedia/projects/linux \
		${WRKSRC}/modules/javafx.media/src/main/native/jfxmedia/projects/bsd
	@${CP} -r ${WRKSRC}/modules/javafx.media/src/main/native/gstreamer/projects/linux \
		${WRKSRC}/modules/javafx.media/src/main/native/gstreamer/projects/bsd

post-patch:
	@${MKDIR} ${WRKDIR}/bin
	@${PRINTF} '#!/bin/sh\nexec ${CCACHE_BIN} ${CC} ${CFLAGS} ${LDFLAGS} "$$@"\n' > ${WRKDIR}/bin/ccwrapper
	@${PRINTF} '#!/bin/sh\nexec ${CCACHE_BIN} ${CXX} ${CXXFLAGS} ${LDFLAGS} "$$@"\n' > ${WRKDIR}/bin/cxxwrapper
	@${CHMOD} +x ${WRKDIR}/bin/ccwrapper ${WRKDIR}/bin/cxxwrapper
	@${REINPLACE_CMD} -e 's|gcc|${WRKDIR}/bin/ccwrapper|g' \
			  -e 's|g\+\+|${WRKDIR}/bin/cxxwrapper|g' \
		${WRKSRC}/buildSrc/bsd.gradle
# Add a *BSD native audio sink to GStreamer-lite instead of using the
# bundled ALSA sink.  Currently we add an sndio sink, but this is an extension
# point for eventually adding an OSS backend (or others) as an option as well.
# If you add a new one make sure it registers itself as "bsdaudiosink" as defined
# in modules/media/src/main/native/jfxmedia/platform/gstreamer/GstPipelineFactory.cpp
	@${MKDIR} ${WRKSRC}/modules/javafx.media/src/main/native/gstreamer/gstreamer-lite/gst-plugins-base/ext/bsdaudio
	@${CP} ${FILESDIR}/gstsndio.* ${FILESDIR}/sndiosink.* \
		${WRKSRC}/modules/javafx.media/src/main/native/gstreamer/gstreamer-lite/gst-plugins-base/ext/bsdaudio
	@cd ${WRKSRC}/modules/javafx.media/src/main/native/gstreamer/gstreamer-lite/gst-plugins-base/ext/bsdaudio && \
		${LN} -s gstsndio.c gstbsdaudio.c && \
		${LN} -s sndiosink.c bsdaudiosink.c
# Pull Java dependencies from LOCALBASE
	@${REINPLACE_CMD} 's|/usr/local|${LOCALBASE}|g' \
		${WRKSRC}/build.gradle ${WRKSRC}/buildSrc/build.gradle
# Remove bundled libraries. We use the system's versions instead.
	@cd ${WRKSRC}/modules/javafx.web/src/main/native/Source/ThirdParty && \
		${RM} -r icu libxml libxslt sqlite
	@${RM} -r ${WRKSRC}/modules/javafx.web/src/main/native/Source/WTF/icu
	@cd ${WRKSRC}/modules/javafx.media/src/main/native/gstreamer/3rd_party && \
		${RM} -r glib libffi

do-configure:
	@${MKDIR} ${WRKDIR}/gradle-home
	@${ECHO_CMD} "NUM_COMPILE_THREADS = ${MAKE_JOBS_NUMBER}" > ${WRKSRC}/gradle.properties
	@${ECHO_CMD} "JFX_DEPS_URL = ${WRKDIR}/jars" > ${WRKSRC}/gradle.properties
.for prop in COMPILE_MEDIA COMPILE_WEBKIT AWT_TEST FULL_TEST
	@${ECHO_CMD} "${prop} = ${${prop}:Ufalse}" >> ${WRKSRC}/gradle.properties
.endfor
	@${ECHO_CMD} "BSD.compileSWT = ${COMPILE_SWT:Ufalse};" >> ${WRKSRC}/buildSrc/bsd.gradle

do-build:
	@cd ${WRKSRC} && ${SETENV} ${_GRADLE_RUN} zips --exclude-task javadoc

# it's not recommended to install openjfx inside openjdk directory
do-install:
	@${MKDIR} ${STAGEDIR}${INSTALLDIR} \
		${STAGEDIR}${INSTALLDIR}/lib \
		${STAGEDIR}${INSTALLDIR}/jmods
	(cd ${WRKSRC}/build/artifacts/javafx-sdk-14.0.2.1/lib && ${COPYTREE_SHARE} . ${STAGEDIR}${INSTALLDIR}/lib)
	@${MV} ${STAGEDIR}${INSTALLDIR}/lib/src.zip ${STAGEDIR}${INSTALLDIR}/lib/javafx-src.zip
	(cd ${WRKSRC}/build/artifacts/javafx-jmods-14.0.2.1 && ${COPYTREE_SHARE} . ${STAGEDIR}${INSTALLDIR}/jmods)
	@${FIND} ${STAGEDIR}${INSTALLDIR}/lib -name '*.so' -exec ${STRIP_CMD} \{\} \;

do-test-TEST-on:
	@cd ${WRKSRC} && ${_GRADLE_RUN} check test

.include <bsd.port.mk>
