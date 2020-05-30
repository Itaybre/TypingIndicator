TARGET = iphone:13.3:12.0

export GO_EASY_ON_ME=1

ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TypingNotification

TypingNotification_FILES = IBTIRootListController.m 
TypingNotification_INSTALL_PATH = /Library/PreferenceBundles
TypingNotification_FRAMEWORKS = UIKit
TypingNotification_PRIVATE_FRAMEWORKS = Preferences 
TypingNotification_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
TypingNotification_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/TypingNotification.plist$(ECHO_END)
