TARGET = :clang
ARCHS = armv7 armv7s arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ColorCodedLogs
ColorCodedLogs_FILES = Tweak.xm
ColorCodedLogs_FRAMEWORKS = UIKit
ColorCodedLogs_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
