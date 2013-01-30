include theos/makefiles/common.mk

TWEAK_NAME = CamTime
CamTime_FILES = AudioMaster.m Tweak.xm
CamTime_FRAMEWORKS = UIKit AVFoundation AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk
