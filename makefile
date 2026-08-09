# Variables
LPI = pfpgeditor.lpi
APP = fpg-editor
LANG_DIR = languages
ARCH = x86_64
WIDGET = qt6

# Build commands
BUILD_CMD = lazbuild --cpu=$(ARCH) --widgetset=$(WIDGET) --build-mode=DefaultQT --verbose $(LPI)

.PHONY: all clean build run package

# Build targets (Qt6 on all platforms)
build/lin:
	$(BUILD_CMD)

build/mac:
	$(BUILD_CMD)

build/win:
	$(BUILD_CMD)

# Run targets
run/lin:
	@if [ ! -f $(APP) ]; then $(MAKE) build/lin; fi
	./$(APP)

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

install/deps:
	sudo apt update
	sudo apt install -y fpc fp-compiler-3.2.2 libqt6pas-dev libqt6pas6 qt6-base-dev

# Clean
clean:
	rm -f *.res $(APP) $(APP).exe
