$(info Detected OS: $(shell uname))

JAVA := /opt/java

ifeq ($(strip $(JAVA_HOME)),)
else
    JAVA := $(JAVA_HOME)
endif

ifeq ($(shell uname), Linux)
    INCLUDE_FLAGS=-I$(JAVA)/include -I$(JAVA)/include/linux
    OS := linux
    CC = gcc
    CFLAGS = -D_GNU_SOURCE $(INCLUDE_FLAGS)
else ifeq ($(shell uname), Darwin)
    TARGET=macosx
    INCLUDE_FLAGS=-I$(JAVA)/include -I$(JAVA)/include/darwin
    OS := macosx
    CC = gcc
    CFLAGS = -DDARWIN $(INCLUDE_FLAGS) 
else ifneq ($(shell uname), MINGW64_NT-10.0-20348)
    OS := windows
    CC = gcc
    CFLAGS = -DWIN32 -I$(JAVA)/include -I$(JAVA)/include/win32"
endif

ifeq ($(TARGET), ios)
    OS := ios
    CC = clang
    CFLAGS = -arch arm64 \
             -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
             -miphoneos-version-min=12.0 \
             -fobjc-arc \
             -O2 \
             -Wall -Wextra \
             -g \
             -framework Foundation \
             $(INCLUDE_FLAGS)
else ifeq ($(TARGET), android)
    OS := android
    CC = $(ANDROID_NDK_HOME)/toolchains/llvm/prebuilt/linux-x86_64/bin/clang
    CFLAGS = -target aarch64-linux-android \
             -DANDROID
else
endif


SRCDIR = src
DARWIN_SRCDIR = src/darwin
OBJDIR = build
LIBDIR = lib

SRCS = $(wildcard $(SRCDIR)/*.c)
ifeq ($(TARGET), macosx)
    SRCS = $(wildcard $(SRCDIR)/*.c) $(wildcard $(DARWIN_SRCDIR)/*.m)
#    SRCS += $(wildcard $(SRCDIR)/darwin/*.m)
    echo "SRCS = $(SRCS)"
endif
ifeq ($(TARGET), ios)
    SRCS = $(wildcard $(SRCDIR)/*.c) $(wildcard $(DARWIN_SRCDIR)/*.m)
#    SRCS += $(wildcard $(SRCDIR)/darwin/*.m)
    echo "SRCS = $(SRCS)"
endif

#OBJS = $(patsubst %.c,$(OBJDIR)/$(OS)/%.o,$(notdir $(SRCS)))
#OBJS += $(patsubst $(DARWIN_SRCDIR)/%.m,$(OBJDIR)/$(OS)/%.o,$(wildcard $(DARWIN_SRCDIR)/*.m))

OBJS_C = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/$(OS)/%.o,$(filter %.c,$(SRCS)))
OBJS_M = $(patsubst $(DARWIN_SRCDIR)/%.m,$(OBJDIR)/$(OS)/%.o,$(filter %.m,$(SRCS)))
OBJS = $(OBJS_C) $(OBJS_M)

JDKLIB = /tmp/libjdk.a
TEMP_DIR = /tmp/extractdir

ifeq ($(OS), windows)
    JDKLIB := C:/temp/libjdk.lib
    LIB = $(LIBDIR)/windows/staticjdk/lib/libvmone.lib
    AR = lib
    ARFLAGS = /OUT:
else
    LIB = $(LIBDIR)/$(OS)/staticjdk/lib/libvmone.a
    AR = ar
    ARFLAGS = rcs
endif

all: $(LIB)

$(LIB): $(OBJS)
	@mkdir -p $(LIBDIR)/$(OS)/staticjdk/lib
ifeq ($(OS), windows)
	if [ -s $(JDKLIB) ]; then \
		echo "Including $(JDKLIB) in lib"; \
		TMPDIR=$(LIBDIR)/$(OS)/temp_objs; \
		mkdir -p $$TMPDIR; \
		(cd $$TMPDIR && $(AR) x $(JDKLIB)); \
		$(AR) $(ARFLAGS) $@ $$TMPDIR/*.o $^; \
	else \
		echo "Existing library not found. Creating static library with object files only."; \
		$(AR) $(ARFLAGS) $@ $^; \
	fi
else
	if [ -s $(JDKLIB) ]; then \
		echo "Including $(JDKLIB) in lib"; \
		TMPDIR=$(LIBDIR)/$(OS)/temp_objs; \
		mkdir -p $$TMPDIR; \
		(cd $$TMPDIR && $(AR) x $(JDKLIB)); \
		$(AR) $(ARFLAGS) $@ $$TMPDIR/*.o $^; \
	else \
		echo "Existing library not found. Creating static library with object files only."; \
		$(AR) $(ARFLAGS) $@ $^; \
	fi
endif

debug:
	@echo "OS: $(OS)"
	@echo "SRCS: $(SRCS)"
	@echo "OBJS: $(OBJS)"
	@echo "OBJDIR: $(OBJDIR)"


$(OBJDIR)/$(OS)/%.o: $(SRCDIR)/%.c
	echo "Using Java from $(JAVA) and OS = $(OS) and OBJS = $(OBJS)"
	@mkdir -p $(OBJDIR)/$(OS)
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJDIR)/$(OS)/%.o: $(SRCDIR)/darwin/%.m
	@mkdir -p $(OBJDIR)/$(OS)
	$(CC) $(CFLAGS) -c $< -o $@

#$(OBJDIR)/$(OS)/%.o: $(SRCDIR)/darwin/%.m
#@mkdir -p $(OBJDIR)/$(OS)
#$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(OBJDIR) $(LIBDIR)
