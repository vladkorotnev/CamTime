export ARCHS=armv7
export TARGET=iphone:6.1:5.0
export GO_EASY_ON_ME=1

include theos/makefiles/common.mk
TWEAK_NAME = CamTime
CamTime_FILES = AudioMaster.m Tweak.xm
CamTime_FRAMEWORKS = UIKit AVFoundation AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk
