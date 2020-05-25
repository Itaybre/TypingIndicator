TARGET = iphone:13.3:12.0

export GO_EASY_ON_ME=1
ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TypingIndicatorSB

TypingIndicatorSB_FILES = Tweak.x
TypingIndicatorSB_CFLAGS = -fobjc-arc
TypingIndicatorSB_LIBRARIES = rocketbootstrap
TypingIndicatorSB_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
