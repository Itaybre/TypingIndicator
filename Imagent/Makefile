TARGET = iphone:13.3:12.0

export GO_EASY_ON_ME=1
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = imagent

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypingIndicatorImagent

TypingIndicatorImagent_FILES = Tweak.x
TypingIndicatorImagent_CFLAGS = -fobjc-arc
TypingIndicatorImagent_PRIVATE_FRAMEWORKS = IMSharedUtilities AppSupport
TypingIndicatorImagent_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk
