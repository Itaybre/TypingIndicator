THEOS_DEVICE_IP = 192.168.1.133

include $(THEOS)/makefiles/common.mk

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS = Imagent Springboard typingnotification

include $(THEOS_MAKE_PATH)/aggregate.mk
