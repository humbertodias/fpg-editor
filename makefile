# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor

# Build commands
BUILD_LINUX   = lazbuild --cpu=x86_64 --widgetset=qt5   --verbose $(LPI)
#BUILD_LINUX   = lazbuild --ws=qt6 --build-mode=DebugQT $(LPI)
BUILD_MACOS   = lazbuild --cpu=x86_64 --widgetset=cocoa --verbose $(LPI)
BUILD_WINDOWS = lazbuild --cpu=x86_64 --widgetset=win32 --verbose $(LPI)

# Targets
build/lin:
	$(BUILD_LINUX)

run/lin:
	GTK_PATH="" ./$(APP)

release/lin:
	tar cvfz $(APP).tar.gz $(APP) languages

build/mac:
	$(BUILD_MACOS)

run/mac:
	./$(APP)

release/mac:
	tar cvfz $(APP).tar.gz $(APP) languages

build/win:
	$(BUILD_WINDOWS)

run/win:
	./$(APP).exe

release/win:
	tar cvfz $(APP).tar.gz $(APP).exe languages

clean:
	rm -f *.res $(APP)
