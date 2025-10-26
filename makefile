# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor

# Build commands
BUILD_LINUX   = lazbuild --cpu=x86_64 --widgetset=qt6   --verbose $(LPI)
BUILD_MACOS   = lazbuild --cpu=x86_64 --widgetset=cocoa --verbose $(LPI)
BUILD_WINDOWS = lazbuild --cpu=x86_64 --widgetset=win32 --verbose $(LPI)

# Targets
build/lin:
	$(BUILD_LINUX)

run/lin:
	GTK_PATH="" ./$(APP)

build/mac:
	$(BUILD_MACOS)

run/mac:
	./$(APP)

build/win:
	$(BUILD_WINDOWS)

run/win:
	./$(APP).exe

clean:
	rm -f *.res $(APP)
