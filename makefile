# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor
LANG_DIR = languages
ARCH = x86_64

# Build commands
BUILD_CMD = lazbuild --cpu=$(ARCH) --widgetset=$(WIDGET) --verbose $(LPI)

# Platform-specific widgets
LINUX_WIDGET = gtk2
MACOS_WIDGET  = cocoa
WINDOWS_WIDGET = win32

.PHONY: all clean build run package

# Build targets
build/lin: WIDGET=$(LINUX_WIDGET)
build/lin:
	$(BUILD_CMD)

build/mac: WIDGET=$(MACOS_WIDGET)
build/mac:
	$(BUILD_CMD)

build/win: WIDGET=$(WINDOWS_WIDGET)
build/win:
	$(BUILD_CMD)

# Run targets
run/lin:
	@if [ ! -f $(APP) ]; then $(MAKE) build/lin; fi
	GTK_PATH="" ./$(APP)

run/mac:
	@if [ ! -f $(APP) ]; then $(MAKE) build/mac; fi
	./$(APP)

run/win:
	@if [ ! -f $(APP).exe ]; then $(MAKE) build/win; fi
	./$(APP).exe

# Package targets
package/lin: build/lin
	tar cvfz $(APP)-lin-$(ARCH).tar.gz $(APP) $(LANG_DIR)

package/mac: build/mac
	tar cvfz $(APP)-mac-$(ARCH).tar.gz $(APP) $(LANG_DIR)

package/win: build/win
	tar cvfz $(APP)-win-$(ARCH).tar.gz $(APP).exe $(LANG_DIR)

# Clean
clean:
	rm -f *.res $(APP) $(APP).exe
