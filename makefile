# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor
LANG_DIR = languages

# Build commands
BUILD_CMD = lazbuild --cpu=$(CPU) --widgetset=$(WIDGET) --verbose $(LPI)

# Platform-specific settings
LINUX = cpu=x86_64 WIDGET=gtk2
MACOS = cpu=x86_64 WIDGET=cocoa
WINDOWS = cpu=x86_64 WIDGET=win32

# Generic build, run, package targets
.PHONY: all clean build run package

build/lin: CPU=x86_64
build/lin: WIDGET=gtk2
build/lin:
	$(BUILD_CMD)

build/mac: CPU=x86_64
build/mac: WIDGET=cocoa
build/mac:
	$(BUILD_CMD)

build/win: CPU=x86_64
build/win: WIDGET=win32
build/win:
	$(BUILD_CMD)

run/lin:
	@if [ ! -f $(APP) ]; then $(MAKE) build/lin; fi
	GTK_PATH="" ./$(APP)

run/mac:
	@if [ ! -f $(APP) ]; then $(MAKE) build/mac; fi
	./$(APP)

run/win:
	@if [ ! -f $(APP).exe ]; then $(MAKE) build/win; fi
	./$(APP).exe

package/lin: build/lin
	tar cvfz $(APP)-lin.tar.gz $(APP) $(LANG_DIR)

package/mac: build/mac
	tar cvfz $(APP)-mac.tar.gz $(APP) $(LANG_DIR)

package/win: build/win
	tar cvfz $(APP)-win.tar.gz $(APP).exe $(LANG_DIR)

# Clean
clean:
	rm -f *.res $(APP) $(APP).exe
