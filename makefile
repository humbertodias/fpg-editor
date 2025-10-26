build/linux:
	lazbuild --ws=qt6 --bm=DefaultQT --verbose pfpgeditor.lpi

run/linux:
	GTK_PATH="" ./fpg-editor
	
clean:
	rm *.res