#
# Copyright (C) 2017 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This tool is prebuilt if we're doing an app-only build.

# ==========================================================
# Setup some common variables for the different build
# targets here.
# ==========================================================
LOCAL_PATH:= $(call my-dir)

aoptMain := Main.cpp
aoptSources := \
    AoptAssets.cpp \
    AoptConfig.cpp \
    AoptUtil.cpp \
    AoptXml.cpp \
    ApkBuilder.cpp \
    Command.cpp \
    CrunchCache.cpp \
    FileFinder.cpp \
    Images.cpp \
    Package.cpp \
    pseudolocalize.cpp \
    Resource.cpp \
    ResourceFilter.cpp \
    ResourceIdCache.cpp \
    ResourceTable.cpp \
    SourcePos.cpp \
    StringPool.cpp \
    WorkQueue.cpp \
    XMLNode.cpp \
    ZipEntry.cpp \
    ZipFile.cpp 

aoptTests := \
    tests/AoptConfig_test.cpp \
    tests/AoptGroupEntry_test.cpp \
    tests/Pseudolocales_test.cpp \
    tests/ResourceFilter_test.cpp \
    tests/ResourceTable_test.cpp

aoptStaticLibs := \
    libandroidfw-static \
    libpng \
    libexpat_static \
    libutils \
    libcutils \
    libziparchive \
    liblog \
    libbase \
    libm \
    libc \
    libz \
    libc++_static

CFLAGS := \
	-DHAVE_SYS_UIO_H \
	-DHAVE_PTHREADS \
	-DHAVE_SCHED_H \
	-DHAVE_IOCTL \
	-DHAVE_TM_GMTOFF \
	-DANDROID_SMP=1  \
	-DHAVE_ENDIAN_H \
	-DHAVE_POSIX_FILEMAP \
	-DHAVE_OFF64_T \
	-DHAVE_LITTLE_ENDIAN_H \
	-D__ANDROID__ \
	-DHAVE_ANDROID_OS=1 \
	-D_ANDROID_CONFIG_H \
	-DHAVE_ERRNO_H='1' \
	-DSTATIC_ANDROIDFW_FOR_TOOLS \

aoptcppFlags := \
		-std=gnu++1y \
		-Wno-missing-field-initializers \
		-fno-exceptions -fno-rtti -Os

aoptCflags := -D'AOPT_VERSION="android-$(PLATFORM_VERSION)-$(TARGET_BUILD_VARIANT)"'
aoptCflags += -Wno-format-y2k
aoptCflags += $(CFLAGS)

aoptLdLibs := -lc -lgcc -ldl -lz -lm

aoptIncludes := \
        $(LOCAL_PATH)/include \
        system/core/base/include \
        system/core/libutils \
        system/core/liblog \
        system/core/libcutils \
        $(LOCAL_PATH)/libpng \
        external/expat \
        external/zlib \
        external/libcxx/include \
        system/core/libziparchive \
        frameworks/base/libs/androidfw \
        frameworks/base/include/androidfw
        

FIND_HOSTOS := $(shell uname -s)
HOST_NAME := $(shell echo $(FIND_HOSTOS) |sed -e s/L/l/ |sed -e s/D/d/ |sed s/W/w/ )

# ==========================================================
# Build the target static library: libandroidfw-static
# ==========================================================
include $(CLEAR_VARS)

ANDROIDFW_PATH := ../../libs/androidfw
LOCAL_C_INCLUDES := $(LOCAL_PATH)/
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)

androidfw_srcs := \
    $(ANDROIDFW_PATH)/Asset.cpp \
    $(ANDROIDFW_PATH)/AssetDir.cpp \
    $(ANDROIDFW_PATH)/AssetManager.cpp \
    $(ANDROIDFW_PATH)/LocaleData.cpp \
    $(ANDROIDFW_PATH)/misc.cpp \
    $(ANDROIDFW_PATH)/ObbFile.cpp \
    $(ANDROIDFW_PATH)/ResourceTypes.cpp \
    $(ANDROIDFW_PATH)/StreamingZipInflater.cpp \
    $(ANDROIDFW_PATH)/TypeWrappers.cpp \
    $(ANDROIDFW_PATH)/ZipFileRO.cpp \
    $(ANDROIDFW_PATH)/ZipUtils.cpp \
    $(ANDROIDFW_PATH)/BackupData.cpp \
    $(ANDROIDFW_PATH)/BackupHelpers.cpp \
    $(ANDROIDFW_PATH)/CursorWindow.cpp \
    $(ANDROIDFW_PATH)/DisplayEventDispatcher.cpp

LOCAL_MODULE:= libandroidfw-static
LOCAL_MODULE_TAGS := optional
LOCAL_CFLAGS :=  $(aoptCflags)
LOCAL_CPPFLAGS := $(aoptCppFlags)
LOCAL_C_INCLUDES := external/zlib
LOCAL_STATIC_LIBRARIES := libziparchive libbase
LOCAL_SRC_FILES := $(androidfw_srcs)
include $(BUILD_STATIC_LIBRARY)


# ==========================================================
# Build the target executable: aopt
# ==========================================================
include $(CLEAR_VARS)

LOCAL_CFLAGS :=  $(aoptCflags)
LOCAL_CPPFLAGS := $(aoptCppFlags)
LOCAL_C_INCLUDES := $(aoptIncludes)
LOCAL_STATIC_LIBRARIES := $(aoptStaticLibs)
LOCAL_LDLIBS := $(aoptLdLibs)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_SRC_FILES := $(aoptMain) $(aoptSources)

LOCAL_UNSTRIPPED_PATH := $(PRODUCT_OUT)/symbols/utilities
LOCAL_LDFLAGS += -static
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_PACK_MODULE_RELOCATIONS := false
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk


LOCAL_MODULE := aopt

LOCAL_MODULE_STEM_32 := aopt
LOCAL_MODULE_STEM_64 := aopt64
LOCAL_MODULE_PATH_32 := $(ANDROID_PRODUCT_OUT)/system/bin
LOCAL_MODULE_PATH_64 := $(ANDROID_PRODUCT_OUT)/system/bin
LOCAL_MULTILIB := both

include $(BUILD_EXECUTABLE)


# ==========================================================
# Setup some common variables for the different build
# targets here.
# ==========================================================

include $(CLEAR_VARS)
aoptHostTests := \
    tests/AoptConfig_test.cpp \
    tests/AoptGroupEntry_test.cpp \
    tests/Pseudolocales_test.cpp \
    tests/ResourceFilter_test.cpp \
    tests/ResourceTable_test.cpp

aoptHostStaticLibs := \
    libandroidfw \
    libpng \
    libutils \
    liblog \
    libcutils \
    libexpat \
    libziparchive-host \
    libbase

aoptHostCFlags := -D'AOPT_VERSION="android-$(PLATFORM_VERSION)-$(TARGET_BUILD_VARIANT)"'
aoptHostCFlags += -Wall -Werror

aoptHostLdLibs_linux := -lrt -ldl -lpthread

# Statically link libz for MinGW (Win SDK under Linux),
# and dynamically link for all others.
aoptHostStaticLibs_windows := libz
aoptHostLdLibs_linux += -lz
aoptHostLdLibs_darwin := -lz


# ==========================================================
# Build the host static library: libaopt
# ==========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := libaopt
LOCAL_MODULE_HOST_OS := $(HOST_NAME)
LOCAL_CFLAGS := -Wno-format-y2k -DSTATIC_ANDROIDFW_FOR_TOOLS $(aoptHostCFlags)
LOCAL_CPPFLAGS := $(aoptHostCppFlags)
LOCAL_CFLAGS_darwin := -D_DARWIN_UNLIMITED_STREAMS
LOCAL_SRC_FILES := $(aoptSources)
LOCAL_STATIC_LIBRARIES := $(aoptHostStaticLibs)
LOCAL_STATIC_LIBRARIES_windows := $(aoptHostStaticLibs_windows)

include $(BUILD_HOST_STATIC_LIBRARY)

# ==========================================================
# Build the host executable: aopt
# ==========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := aopt
LOCAL_MODULE_HOST_OS := $(HOST_NAME)
LOCAL_CFLAGS := $(aoptHostCFlags)
LOCAL_CPPFLAGS := $(aoptHostCppFlags)
LOCAL_LDLIBS_darwin := $(aoptHostLdLibs_darwin)
LOCAL_LDLIBS_linux := $(aoptHostLdLibs_linux)
LOCAL_SRC_FILES := $(aoptMain)
LOCAL_STATIC_LIBRARIES := libaopt $(aoptHostStaticLibs)
LOCAL_STATIC_LIBRARIES_windows := $(aoptHostStaticLibs_windows)

include $(BUILD_HOST_EXECUTABLE)


# ==========================================================
# Build the host tests: libaopt_tests
# ==========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := libaopt_tests
LOCAL_CFLAGS := $(aoptHostCFlags)
LOCAL_CPPFLAGS := $(aoptHostCppFlags)
LOCAL_LDLIBS_darwin := $(aoptHostLdLibs_darwin)
LOCAL_LDLIBS_linux := $(aoptHostLdLibs_linux)
LOCAL_SRC_FILES := $(aoptTests)
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_STATIC_LIBRARIES := libaopt $(aoptHostStaticLibs)
LOCAL_STATIC_LIBRARIES_windows := $(aoptHostStaticLibs_windows)

include $(BUILD_HOST_NATIVE_TEST)
