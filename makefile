# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor

# Build commands
BUILD_LINUX = lazbuild --ws=qt6 --bm=DefaultQT --verbose $(LPI)
BUILD_MACOS = lazbuild --cpu=x86_64 --widgetset=cocoa --verbose $(LPI)

# Targets
build/linux:
	$(BUILD_LINUX)

run/linux:
	GTK_PATH="" ./$(APP)

build/macos:
	$(BUILD_MACOS)

run/macos:
	./$(APP)

clean:
	rm -f *.res $(APP)
