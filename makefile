build/linux:
	lazbuild --ws=qt6 --bm=DefaultQT --verbose pfpgeditor.lpi

run/linux:
	GTK_PATH="" ./fpg-editor

build/macos:
	lazbuild --cpu=x86_64 --widgetset=cocoa --verbose pfpgeditor.lpi

run/macos:
	./fpg-editor
	
clean:
	rm *.res fpg-editor