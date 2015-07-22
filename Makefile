ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

TWEAK_NAME = Elite
Elite_FILES = Tweak.xm
Elite_FRAMEWORKS = UIKit
TARGET := iphone:8.0:8.0

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobilePhone"
